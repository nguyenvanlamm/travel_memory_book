# Spec chung — Travel Memory Book · 3 hướng UI/UX

> Đầu vào DUY NHẤT cho cả 3 bản nháp (A · vòng quay, B · tham chiếu, C · nhà thiết kế).
> Ngày: 2026-10-12. Các mục đánh dấu **[giả định]** là do người dùng chưa trả lời câu hỏi làm rõ.

## 1. Dự án là gì

**Travel Memory Book** (tên tiếng Việt: *Cuốn Sách Hành Trình*) là một app cá nhân biến mỗi chuyến đi thành một **cuốn sách ảnh** để lật lại nhiều năm sau. Đây **không phải mạng xã hội**: không like, không comment, không follower, không feed, không chia sẻ. Người đọc duy nhất là chính chủ. Mọi thứ offline, không tài khoản, không cloud.

Câu định vị (từ PRD, giữ nguyên): *"Many years from now, you can open this app, pick an old trip, and feel like you're reading back a part of your life."*

Ẩn dụ cấu trúc của sản phẩm (từ PRD): **mỗi chuyến đi là một cuốn sách, mỗi ngày là một chương, mỗi địa điểm là một phần câu chuyện, mỗi bức ảnh là một trang ký ức.**

Hiện trạng: Flutter app (Android/iOS) + bản web demo deploy Netlify. Có trình đọc sách lật trang 3D (bìa da, giấy parchment, chữ nhũ vàng), xuất PDF để in. Giao diện web hiện tại khá chung chung: thanh nav trên, minh họa unDraw hai người cầm vali, tiêu đề Syne, thân Inter, nút nâu. Ba bản nháp này là để chọn **hướng mới** cho phần "vỏ" của app (thư viện + trang chuyến đi), không phải trang marketing.

## 2. Khán giả và bối cảnh dùng

- Chủ app (Lãm, developer, 25–35 tuổi, đi 3–5 chuyến/năm, chụp rất nhiều ảnh) và những người giống vậy: muốn một chỗ riêng tư, đẹp, có tổ chức — chán Google Photos (quá chung chung) và Instagram (quá "trình diễn").
- Hai khoảnh khắc dùng chính:
  1. **Sau chuyến đi** (tối ở nhà, laptop): nhập ảnh, sắp theo ngày, viết vài dòng ký ức. → cần rõ ràng, nhanh, ít ma sát.
  2. **Nhiều năm sau** (thư thả, hoài niệm): mở thư viện, chọn một cuốn cũ, lật đọc. → cần cảm xúc, chậm rãi, giống cầm một cuốn sách thật.
- Thiết kế phải phục vụ cả hai: **thư viện là nơi chọn sách**, **trang chuyến đi là mục lục + bàn làm việc của một cuốn**.

## 3. Thông điệp chính + cảm xúc

- Thông điệp: *Chuyến đi của bạn là những cuốn sách, không phải một cái feed.*
- Từ khóa khí chất (từ idea.md): **warm, personal, minimal, cinematic, nostalgic — like a coffee-table photo book, not Instagram.**
- Cảm giác cần tránh: dashboard SaaS, mạng xã hội, app du lịch đặt phòng, "tech demo".

## 4. Định dạng và kích thước (bắt buộc giống nhau ở cả 3 bản)

- **Web app desktop, khung 1440×900.** [giả định — bản web là thứ đang deploy; mobile sẽ suy ra sau khi chốt hướng]
- Mỗi bản là **1 file HTML/CSS thuần** gồm **2 màn hình xếp dọc**, mỗi màn đúng **1440×900**:
  - `<section id="screen-library">` — màn 1: Thư viện (Home)
  - `<section id="screen-trip">` — màn 2: Một cuốn sách (Trip detail của "Hà Giang Loop")
- `body { width:1440px; margin:0 }`, mỗi section `width:1440px; height:900px; overflow:hidden; position:relative`. Không có gì tràn ra ngoài khung; màn 2 bắt đầu đúng y=900.
- Ngôn ngữ: **giao diện (chrome) tiếng Anh** như sản phẩm hiện tại; **tên địa danh giữ dấu tiếng Việt**; **đoạn ký ức do người dùng viết là tiếng Việt** (nội dung cá nhân). [giả định] → font bắt buộc hỗ trợ subset **vietnamese** (kiểm tra trên Google Fonts; vd. Be Vietnam Pro, Newsreader, Lora, EB Garamond, Cormorant Garamond, Source Serif 4, Bricolage Grotesque, Montserrat… — tự kiểm, đừng tin danh sách này mù quáng).
- Font tải từ Google Fonts qua `<link>` là được. Icon: inline SVG theo nét Lucide (app đang dùng Lucide), không emoji.

## 5. Nội dung thật (dữ liệu demo — dùng y nguyên, không Lorem ipsum)

Lưu ý: app chưa có dữ liệu người dùng; đây là **thư viện demo** soạn sẵn để thiết kế có nội dung thật. Ảnh là ảnh thật từ Wikimedia Commons (xem `assets/CREDITS.md`).

### Màn 1 — Library

- Thương hiệu: logo mark `assets/logo-mark.svg` (cuốn sách mở + mặt trời mọc) + chữ "Travel Memory Book".
- Điều hướng: **Library** (đang chọn) · **Journeys stats** hoặc **Profile** · **Settings**; nút chính **New Book**. Có thể có ô tìm kiếm ("Search memories, places…").
- Số liệu tổng (đã cộng đúng từ 6 cuốn bên dưới): **6 books · 29 days · 3 countries · 758 photos · 37 memories**.
- Sắp xếp: Newest first · Oldest first · By year · By country.
- Gợi ý "tiếp tục": *Hà Giang Loop — 2 of 4 days still have no memory written.* (Day 1 và Day 4 chưa có ký ức)
- Sáu cuốn sách (mới → cũ):

| # | Tiêu đề | Nơi | Ngày | Số ngày | Ảnh | Ký ức | Ảnh bìa |
|---|---|---|---|---|---|---|---|
| 1 | Hà Giang Loop | Hà Giang, Vietnam | 14–17 Mar 2026 | 4 | 186 | 9 | `assets/photos/hagiang-cover-tham-ma-pass.jpg` |
| 2 | Hội An by Lantern Light | Hội An, Vietnam | 24–27 Jan 2026 | 4 | 112 | 5 | `assets/photos/hoian-cover-lantern-street.jpg` |
| 3 | Kyoto in Late Autumn | Kyoto, Japan | 18–24 Nov 2025 | 7 | 241 | 12 | `assets/photos/kyoto-cover-fushimi-inari.jpg` |
| 4 | Đà Lạt, Cold Mornings | Đà Lạt, Vietnam | 20–23 Dec 2024 | 4 | 58 | 3 | `assets/photos/dalat-cover-xuan-huong-lake.jpg` |
| 5 | Slow Days in Luang Prabang | Luang Prabang, Laos | 8–13 Feb 2024 | 6 | 97 | 6 | `assets/photos/luangprabang-cover-haw-pha-bang.jpg` |
| 6 | Côn Đảo, First Swim of Summer | Côn Đảo, Vietnam | 1–4 Jul 2023 | 4 | 64 | 2 | `assets/photos/condao-cover-beach.jpg` |

Ảnh phụ (tùy dùng): `assets/photos/kyoto-arashiyama-bamboo.jpg`, `assets/photos/hoian-yellow-houses.jpg`.

### Màn 2 — Trip: Hà Giang Loop

- Tiêu đề: **Hà Giang Loop** · Hà Giang, Vietnam · 14–17 Mar 2026
- Mô tả chuyến (người dùng viết): *Four days on the back of a motorbike around the karst plateau, from Quản Bạ to Mèo Vạc and back.*
- Số liệu: **4 days · 186 photos · 9 memories · 7 places**
- Hành động: **Open the book** (chính — mở trình đọc lật trang) · **Add photos** · **Write a memory** · **Export PDF** · Edit
- Các chương (ngày):

| Ngày | Thứ | Chặng | Ảnh | Địa điểm nổi bật | Ảnh | Ký ức |
|---|---|---|---|---|---|---|
| Day 1 | Sat 14 Mar | Hà Giang → Yên Minh | 38 | Quản Bạ Heaven's Gate, Bắc Sum Pass | `hagiang-d1-yen-minh-terraces.jpg` | chưa có |
| Day 2 | Sun 15 Mar | Yên Minh → Đồng Văn | 52 | Thẩm Mã Pass, Lũng Cú Flag Tower | `hagiang-d2-lung-cu-flag.jpg` (+ cover) | 4 |
| Day 3 | Mon 16 Mar | Đồng Văn → Mèo Vạc | 61 | Mã Pí Lèng Pass, Nho Quế River | `hagiang-d3-nho-que-river.jpg`, `hagiang-d3-ma-pi-leng-portrait.jpg` (dọc), `hagiang-d3-ma-pi-leng-road.jpg`, `hagiang-d3-nho-que-green.jpg` | 5 |
| Day 4 | Tue 17 Mar | Mèo Vạc → Du Già → Hà Giang | 35 | Du Già | `hagiang-d4-terraced-fields.jpg` | chưa có |

(38+52+61+35 = 186 ảnh; 4+5 = 9 ký ức. 7 places = Quản Bạ, Bắc Sum, Thẩm Mã, Lũng Cú, Mã Pí Lèng, Nho Quế, Du Già.)

- Ký ức nổi bật (Day 3, người dùng viết, giữ nguyên tiếng Việt):

  > **Mã Pí Lèng, 7 giờ sáng**
  > Dừng xe ở Mã Pí Lèng lúc sương còn vắt ngang vách núi. Sông Nho Quế bên dưới xanh như ai đổ mực, nhỏ đến mức tưởng chỉ là một sợi chỉ. Anh Páo — người chở mình suốt bốn ngày — bảo mùa này nước đẹp nhất. Mình đứng đó gần nửa tiếng, không chụp thêm tấm nào, chỉ muốn nhớ cảm giác gió lạnh tạt vào mặt.

- Chú thích ảnh kiểu EXIF (cho ảnh Mã Pí Lèng): *16 Mar 2026 · 07:12 · f/5.6 · 1/500s · ISO 200*

## 6. Ràng buộc đã biết

- **Bắt buộc**: logo mark `assets/logo-mark.svg` (của dự án, không vẽ lại); đủ 6 cuốn ở màn 1; màn 2 có đủ 4 ngày, đoạn ký ức Day 3, nút "Open the book".
- **Màu thương hiệu hiện có** (nguồn lấy mẫu, KHÔNG phải lồng sắt): nâu đất `#3E2723`/`#5D4037`, bình minh `#E8A87C`, hoàng hôn `#C38D9E`, giấy parchment `#F4E4C1`, vàng nhũ `#D4AF37`/`#D4B98C`. Trình đọc sách có bìa da nâu + giấy ngà + chữ nhũ vàng.
- **Cấm**: minh họa người/vật bằng SVG (bỏ hẳn kiểu unDraw hiện tại); emoji làm icon; gradient tím; thẻ bo góc + viền trái màu; Inter/Roboto/Syne/Playfair làm font tiêu đề; nền `#0D1117` + glow neon; số liệu bịa ngoài bảng trên; like/share/follower hay bất cứ gì có mùi mạng xã hội.
- **Sàn chất lượng**: chữ thân ≥14px, nhãn ≥12px, tương phản chữ thân ≥4.5:1; chữ đặt trên ảnh phải có scrim/nền đủ tương phản; khoảng trắng phải có điểm neo, không trông như lỗi render.
- Ảnh dùng đúng file đã cấp, `object-fit: cover`, không méo. Đường dẫn ảnh/logo dùng **tương đối** (`assets/...`) — người điều phối sẽ nhúng base64 sau.

## 7. Nhu cầu ảnh

Ảnh là **nội dung bắt buộc** (app ảnh du lịch — bỏ ảnh là mất thông tin). 15 ảnh thật đã lấy về `design-demos/assets/photos/`. Không thêm ảnh trang trí; texture/hoa văn chỉ được làm bằng CSS.

## 8. Mô-típ thị giác (hạt giống hình thức — chỉ nội dung này mới có)

- **Cuốn sách như vật thể**: gáy sách, mép giấy, độ dày (nhiều ảnh = sách dày hơn), bìa vải/da, chữ ép nhũ, dải ruy-băng đánh dấu trang.
- **Ngày = chương**: số chương, mục lục, đầu trang chạy (running head), số trang.
- **Thời gian trôi**: năm tháng như chỉ mục; sách cũ hơn thì "cũ" hơn (bạc màu nhẹ?).
- **Vòng lặp Hà Giang**: chuyến đi là một *vòng* khép kín — đường đi có thể là một mô-típ ở màn 2.
- **Ký ức viết tay vs. ảnh**: hai chất liệu — ảnh (ánh sáng, màu thật) và chữ (riêng tư, chậm).
- **Mặt trời mọc trên trang sách mở** (logo) — chân trời, bình minh.

Mỗi hướng tự chọn mô-típ nào để phóng lớn; không bắt buộc dùng hết.
