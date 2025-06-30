// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract AntiPhishingAML_Upgraded is ReentrancyGuard {
    enum RiskLevel { Safe, Suspicious, Blacklisted }

    struct ActivityLog {
        address from;
        address to;
        address token;         // address(0) = ETH, còn lại là ERC20
        uint256 amount;
        uint256 timestamp;
        RiskLevel risk;
    }

    struct ActivityBuffer {
        mapping(uint256 => ActivityLog) logs;
        uint256 head;
        uint256 size;
    }

    struct SuspiciousTrack {
        uint256 count;
        uint256 lastSuspiciousTime;
    }

    struct DailyTransfer {
        uint256 date;
        uint256 sumAmount;
    }

    address public admin;
    uint256 public suspiciousThreshold = 10 ether;
    uint256 public suspiciousLimit = 3;
    uint256 public maxLogSize = 100;
    uint256 public suspiciousResetDays = 7;

    mapping(address => RiskLevel) public riskStatus;
    mapping(address => SuspiciousTrack) public suspiciousTrack;
    mapping(address => ActivityBuffer) private activityHistory;
    mapping(address => mapping(address => DailyTransfer)) public dailyTransferSum;

    // Freeze & Whitelist
    mapping(address => bool) public frozen;
    mapping(address => bool) public whitelist;

    // --- Events ---
    event TransferLogged(address indexed from, address indexed to, address indexed token, uint256 amount, RiskLevel risk);
    event AddressFlagged(address indexed user, RiskLevel risk);
    event AddressFrozen(address indexed user, bool frozen);
    event AddressWhitelisted(address indexed user, bool whitelisted);
    event Received(address indexed from, uint256 amount);
    event AdminChanged(address indexed oldAdmin, address indexed newAdmin);
    event ConfigUpdated(string param, uint256 newValue);

    // --- Modifiers ---
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    modifier notFrozen(address user) {
        require(!frozen[user], "Account is frozen");
        _;
    }

    // --- Constructor ---
    constructor() {
        admin = msg.sender;
    }

    // --- Admin: Freeze/Unfreeze ---
    function freezeAccount(address user, bool _freeze) external onlyAdmin {
        frozen[user] = _freeze;
        emit AddressFrozen(user, _freeze);
    }

    // --- Admin: Whitelist management ---
    function setWhitelist(address user, bool isWhitelisted) external onlyAdmin {
        whitelist[user] = isWhitelisted;
        emit AddressWhitelisted(user, isWhitelisted);
    }

    function batchSetWhitelist(address[] calldata users, bool isWhitelisted) external onlyAdmin {
        for (uint256 i = 0; i < users.length; i++) {
            whitelist[users[i]] = isWhitelisted;
            emit AddressWhitelisted(users[i], isWhitelisted);
        }
    }

    // --- Admin Functions (cũ) ---
    function setRiskStatus(address user, RiskLevel level) external onlyAdmin {
        riskStatus[user] = level;
        emit AddressFlagged(user, level);
    }

    function setSuspiciousThreshold(uint256 newThreshold) external onlyAdmin {
        suspiciousThreshold = newThreshold;
        emit ConfigUpdated("suspiciousThreshold", newThreshold);
    }

    function setSuspiciousLimit(uint256 newLimit) external onlyAdmin {
        suspiciousLimit = newLimit;
        emit ConfigUpdated("suspiciousLimit", newLimit);
    }

    function setMaxLogSize(uint256 newSize) external onlyAdmin {
        require(newSize > 0, "Must be greater than 0");
        maxLogSize = newSize;
        emit ConfigUpdated("maxLogSize", newSize);
    }

    function setSuspiciousResetDays(uint256 days_) external onlyAdmin {
        require(days_ > 0, "Must be greater than 0");
        suspiciousResetDays = days_;
        emit ConfigUpdated("suspiciousResetDays", days_);
    }

    function changeAdmin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0), "Invalid address");
        emit AdminChanged(admin, newAdmin);
        admin = newAdmin;
    }

    // --- ETH monitored transfer ---
    function monitoredTransfer(address payable recipient)
        external
        payable
        nonReentrant
        notFrozen(msg.sender)
        notFrozen(recipient)
    {
        _checkedTransfer(msg.sender, recipient, address(0), msg.value);
        (bool success, ) = recipient.call{value: msg.value}("");
        require(success, "ETH transfer failed");
    }

    // --- ERC20 monitored transfer ---
    function monitoredTransferERC20(
        address token,
        address recipient,
        uint256 amount
    )
        external
        nonReentrant
        notFrozen(msg.sender)
        notFrozen(recipient)
    {
        require(token != address(0), "Invalid ERC20 token address");
        _checkedTransfer(msg.sender, recipient, token, amount);
        require(IERC20(token).transferFrom(msg.sender, recipient, amount), "ERC20 transfer failed");
    }

    // --- Core checked transfer for both ETH/ERC20 ---
    function _checkedTransfer(
        address sender,
        address recipient,
        address token,
        uint256 amount
    ) internal {
        require(amount > 0, "No value sent");

        // --- Whitelist skip risk checks ---
        if (whitelist[sender] || whitelist[recipient]) {
            _logActivityBoth(sender, recipient, token, amount, RiskLevel.Safe);
            return;
        }

        require(riskStatus[sender] != RiskLevel.Blacklisted, "Sender is blacklisted");
        require(riskStatus[recipient] != RiskLevel.Blacklisted, "Recipient is blacklisted");

        RiskLevel risk = RiskLevel.Safe;
        _tryResetSuspicious(sender);

        bool isDailyOverThreshold = _updateAndCheckDailySum(sender, token, amount);

        if (amount >= suspiciousThreshold || isDailyOverThreshold) {
            risk = RiskLevel.Suspicious;
            suspiciousTrack[sender].count += 1;
            suspiciousTrack[sender].lastSuspiciousTime = block.timestamp;
            if (suspiciousTrack[sender].count >= suspiciousLimit) {
                riskStatus[sender] = RiskLevel.Blacklisted;
                emit AddressFlagged(sender, RiskLevel.Blacklisted);
            }
        }
        _logActivityBoth(sender, recipient, token, amount, risk);
    }

    function _logActivityBoth(
        address sender,
        address recipient,
        address token,
        uint256 amount,
        RiskLevel risk
    ) internal {
        ActivityLog memory log = ActivityLog({
            from: sender,
            to: recipient,
            token: token,
            amount: amount,
            timestamp: block.timestamp,
            risk: risk
        });
        logActivity(sender, log);
        logActivity(recipient, log);
        emit TransferLogged(sender, recipient, token, amount, risk);
    }

    // --- Circular buffer logging for each user ---
    function logActivity(address user, ActivityLog memory log) internal {
        ActivityBuffer storage buffer = activityHistory[user];
        uint256 index = (buffer.head + buffer.size) % maxLogSize;
        buffer.logs[index] = log;

        if (buffer.size < maxLogSize) {
            buffer.size++;
        } else {
            buffer.head = (buffer.head + 1) % maxLogSize; // overwrite old log
        }
    }

    // --- View activity logs ---
    function getActivityHistory(address user) external view returns (ActivityLog[] memory) {
        ActivityBuffer storage buffer = activityHistory[user];
        ActivityLog[] memory logs = new ActivityLog[](buffer.size);

        for (uint256 i = 0; i < buffer.size; i++) {
            uint256 index = (buffer.head + i) % maxLogSize;
            logs[i] = buffer.logs[index];
        }
        return logs;
    }

    // --- Daily sum check ---
    function _updateAndCheckDailySum(
        address user,
        address token,
        uint256 amount
    ) internal returns (bool) {
        uint256 currentDate = block.timestamp / 1 days;
        DailyTransfer storage dts = dailyTransferSum[user][token];
        if (dts.date != currentDate) {
            dts.date = currentDate;
            dts.sumAmount = amount;
        } else {
            dts.sumAmount += amount;
        }
        return dts.sumAmount >= suspiciousThreshold;
    }

    // --- Suspicious count reset if time out ---
    function _tryResetSuspicious(address user) internal {
        if (
            suspiciousTrack[user].count > 0 &&
            block.timestamp > suspiciousTrack[user].lastSuspiciousTime + suspiciousResetDays * 1 days
        ) {
            suspiciousTrack[user].count = 0;
        }
    }

    // --- View daily transfer sum ---
    function getDailyTransferSum(address user, address token)
        external
        view
        returns (uint256 date, uint256 sumAmount)
    {
        DailyTransfer storage dts = dailyTransferSum[user][token];
        return (dts.date, dts.sumAmount);
    }

    // --- Fallback to receive ETH ---
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
}
