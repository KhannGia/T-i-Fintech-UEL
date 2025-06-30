CÁC HÀNH VI RỬA TIỀN TRONG BLOCKCHAIN 

🔹 1. Giao dịch nhỏ, lặp lại để che giấu số tiền lớn (On-chain Smurfing)
 Mô tả:
 Tội phạm chia nhỏ một khoản tiền mã hóa lớn thành nhiều giao dịch nhỏ có giá trị dưới ngưỡng đáng chú ý, rồi thực hiện chuyển tiền liên tục đến các ví khác nhau. Hành vi này tương tự như “smurfing” trong ngân hàng truyền thống, nhưng diễn ra hoàn toàn trên blockchain.
 Ví dụ: Một hacker sau vụ tấn công DeFi có 500 ETH. Thay vì chuyển hết vào một ví, hắn chia thành 100 lần gửi 5 ETH đến 100 địa chỉ ví không liên quan.
 Mục đích:
Tránh hệ thống phân tích hành vi bất thường (on-chain behavior analytics).


Làm loãng dữ liệu, gây khó khăn cho việc phát hiện giao dịch lớn liên quan đến tội phạm.



🔹 2. Trộn coin bằng dịch vụ mixer/tumbler
 Mô tả:
 Mixers là các dịch vụ nhận coin từ nhiều người khác nhau, trộn chung và gửi lại coin cho người dùng từ pool khác, nhằm cắt đứt liên kết giao dịch giữa ví gửi và ví nhận.
 Ví dụ: Dịch vụ Tornado Cash trên Ethereum hoạt động bằng cách gửi ETH vào smart contract, sau thời gian trễ sẽ gửi số ETH tương đương đến địa chỉ người nhận nhưng không liên kết trực tiếp với giao dịch trước đó.
 Mục đích:
Ẩn danh tuyệt đối giao dịch.


Che giấu dòng tiền bất hợp pháp khỏi truy vết từ công cụ giám sát blockchain (như Chainalysis, TRM Labs).



🔹 3. Chuyển tiền qua nhiều ví trung gian (Layering)
 Mô tả:
 Tội phạm rửa tiền tạo ra nhiều lớp ví trung gian, mỗi lớp chỉ giữ tiền trong thời gian rất ngắn rồi chuyển tiếp. Hành vi này làm cho dòng tiền trở nên rối rắm, khó truy nguồn gốc.
 Ví dụ: Từ ví A (ban đầu), tiền được chuyển qua các ví B → C → D → E → F trong vòng vài phút, mỗi ví lại gửi tiền đi tiếp.
 Mục đích:
Làm gián đoạn đường phân tích giao dịch (transaction path tracing).


Tạo nhiều bước giả để đánh lạc hướng cơ quan điều tra.



🔹 4. Chuyển đổi tài sản giữa nhiều blockchain (Chain Hopping)
 Mô tả:
 Thay vì di chuyển tài sản trong một blockchain, tội phạm sử dụng cầu nối (cross-chain bridge) để chuyển tài sản giữa nhiều blockchain khác nhau, lợi dụng sự thiếu liên kết giữa các công cụ phân tích chuỗi để “chuyển tiền xuyên biên giới on-chain”.
 Ví dụ: ETH → cầu nối sang Binance Smart Chain (BTCB) → cầu nối sang Tron (USDT) → rút ra fiat.
 Mục đích:
Né tránh truy vết liên tục trên cùng một blockchain.


Tận dụng những blockchain ít được giám sát như Tron, Fantom, v.v.



🔹 5. Tạo token lừa đảo hoặc ICO giả (Fake Token / Scam ICO)
 Mô tả:
 Tội phạm tạo ra token mới (thường là ERC-20 hoặc BEP-20) gắn mác “dự án đầu tư” rồi tự mua bán giữa các ví để làm giả thanh khoản, tạo lòng tin, sau đó lôi kéo người khác đầu tư hoặc tự thu tiền mã hóa từ ví phụ.
 Ví dụ: Tạo token ABCDEFI, list lên DEX, ví A mua 100,000 token với giá cao từ ví B (cũng do tội phạm kiểm soát), tạo khối lượng giả, sau đó rút ETH về ví riêng.
 Mục đích:
Hợp thức hóa tiền bẩn thành tài sản đầu tư “sạch”.


Ngụy trang hành vi chiếm đoạt hoặc chuyển tiền bất hợp pháp.



🔹 6. Rửa tiền thông qua NFT (NFT Laundering)
 Mô tả:
 Tội phạm tạo NFT hoặc mua NFT vô giá trị rồi tự bán qua lại với các ví do mình kiểm soát để tạo ra doanh thu ảo, hợp thức hóa dòng tiền. Do thị trường NFT thiếu minh bạch và không có giá sàn, việc xác định giá trị thực rất khó.
 Ví dụ: Một bức ảnh PNG đơn giản được mint thành NFT, list lên OpenSea với giá 50 ETH. Tội phạm dùng ví phụ mua NFT này.
 Mục đích:
Biến tiền bẩn thành doanh thu “bán tác phẩm nghệ thuật”.


Rút tiền thông qua sàn NFT hỗ trợ rút fiat hoặc crypto.



🔹 7. Lạm dụng sàn phi tập trung (DEX)
 Mô tả:
 Sàn DEX không yêu cầu KYC, cho phép bất kỳ ai giao dịch hoán đổi token mà không cần định danh. Tội phạm có thể đổi token bẩn lấy stablecoin hoặc ngược lại.
 Ví dụ: Swap từ 10,000 DAI sang 30 loại altcoin khác nhau qua Uniswap, rồi chuyển mỗi loại về ví riêng.
 Mục đích:
Ẩn nguồn gốc tài sản gốc thông qua các bước swap liên tục.


Rút coin qua các sàn CEX khác nhau dễ dàng hơn sau khi được “làm sạch”.



🔹 8. Sử dụng đồng tiền ẩn danh (Privacy Coins)
 Mô tả:
 Monero, Zcash, Dash… có tính năng ẩn địa chỉ, ẩn số dư, ẩn lịch sử giao dịch. Tội phạm thường đổi tiền sang các coin này rồi chờ một thời gian để rút hoặc hoán đổi ngược lại.
 Ví dụ: Swap ETH → XMR trên sàn không KYC, giữ vài tuần, sau đó swap XMR → USDT và rút ra.
 Mục đích:
Làm “đứt chuỗi” phân tích blockchain.


Giao dịch không để lại lịch sử có thể kiểm chứng.



🔹 9. Wash Trading token hoặc NFT để tạo thanh khoản giả
 Mô tả:
 Tội phạm thực hiện các giao dịch mua bán khống giữa các ví có liên kết nhằm tạo cảm giác về thanh khoản cao hoặc lợi nhuận ảo.
 Ví dụ: Một token rác được mua bán giữa ví A ↔ B ↔ C trong 24h để tạo ra 1 triệu USD volume.
 Mục đích:
Đánh lừa nhà đầu tư hoặc hệ thống giám sát về tính hợp pháp của dự án/token.


Biến tiền bẩn thành tiền “lãi đầu tư”.



🔹 10. Lợi dụng flash loan trong DeFi để xáo trộn dòng tiền
 Mô tả:
 Flash loan cho phép vay hàng triệu USD mà không cần thế chấp nếu hoàn trả trong cùng một block. Tội phạm dùng kỹ thuật này để tạo hàng loạt bước giao dịch phức tạp, khiến dòng tiền khó phân tích.
 Ví dụ: Vay 5 triệu USDC → mua token A → chuyển sang sàn khác → swap → trả nợ → rút lãi sang ví mới.
 Mục đích:
Ngụy trang dòng tiền qua các giao dịch phức tạp và tức thời.


Hợp thức hóa số tiền đầu ra bằng hình thức “lãi DeFi”.
