# Direction approved

- Ngày: 2026-10-12
- Các bản đã bày:
  - A — vòng quay #15 Utility-First Colorful Docs (sidebar năm + lưới sách + cột "On this page") · `a-roulette.html` · `shots/a-roulette-screen-*.jpg`
  - B — tham chiếu Day One (Apple Design Award 2014; khung 3 ô drawer → timeline → khung chi tiết) · `b-reference.html` · `shots/b-reference-screen-*.jpg`
  - C — nhà thiết kế Irma Boom (chồng sách vẽ theo tỉ lệ + thumb index mép phải) · `c-designer.html` · `shots/c-designer-screen-*.jpg`
- Người dùng chọn (nguyên văn): "Chọn phương án B"
- Hướng chốt: **B**
- Thay thế: hướng "dark-premium" khóa ngày 2026-09-12 ở `app/.revamp/design-direction.md` (Syne + Inter, nền slate, vàng #D4AF37) — hướng đó hết hiệu lực cho phần vỏ app.

## Ghi chú cho bước triển khai

### Khung bố cục (giữ)
- **Desktop/web ≥1200px:** 3 ô kiểu Day One.
  - Thư viện = drawer (brand, New Book, nav Library / Journey stats / Settings, Shelves theo năm, dòng riêng tư ở đáy) → danh sách sách theo năm (header năm dính, cột ngày lớn, sách mini có gáy + mép giấy dày theo số ảnh) → khung cuốn đang chọn phủ màu vải của nó (bìa cứng + ruy-băng, số liệu, "Open the book", khối "Continue" cho các ngày chưa viết ký ức).
  - Trang chuyến đi = drawer thu thành rail 72px (icon nav + chip màu từng cuốn) → header phủ màu sách + sơ đồ vòng lặp + hành động → tab Chapters · Photos · Route → danh sách chương (ruy-băng đánh dấu chương đang mở) → bên phải là ký ức dàn hai trang (ảnh dọc trái, chữ serif phải, dòng EXIF, "More from Day N", chân trang metadata).
- **Tablet/mobile (cần thiết kế ở bước sau):** gập theo mẫu Day One — drawer → list → detail thành 3 màn đẩy chồng; rail thành bottom bar hoặc drawer trượt.

### Màu (token, lấy nguyên từ `b-reference.html`)
- Giấy: `--paper-0 #FCFAF6` (trang), `--paper-1 #F8F3EC` (cột timeline), `--paper-2 #EFE9DF` (drawer), `--line #DED6CC`.
- Mực: `--ink-1 #2C1E18`, `--ink-2 #51453D`, `--ink-3 #6C6158` (≥4.99:1 trên paper-2).
- Màu hành động duy nhất: `--sun #A64F2B` (chữ trắng 5.56:1); dùng làm chữ: `--sun-ink #9A4825`.
- Vải bìa theo cuốn (lấy mẫu từ ảnh bìa): Hà Giang `#2F5649` (deep `#132821`), Hội An `#AC853F`, Kyoto `#9D3629`, Đà Lạt `#576574`, Luang Prabang `#AF7033`, Côn Đảo `#6E8D90`.
  - Trong app thật màu này phải **tính tự động từ ảnh bìa** (palette extraction → ép về oklch L≈0.42–0.64, C≤0.14), kèm biến thể deep (L≈0.25) cho nền khung chi tiết.
- Nhũ: `--gold #D1BB92`; chữ trên vải tối: `--parch #F3EAD9`, phụ `--parch-mute #B6C2B3`.
- Dark mode chưa thiết kế — làm ở bước triển khai, không đảo màu máy móc.

### Chữ
- **Literata** (serif, tiêu đề, ngày lớn, chữ ký ức, số liệu) + **Be Vietnam Pro** (UI). Cả hai OFL, có subset vietnamese.
- Flutter: bundle cả hai vào `app/assets/fonts/` (thay Syne/Inter/Playfair cho phần vỏ; giữ font riêng của trang sách in nếu muốn).
- Thân 15px, ký ức 19px / line-height 1.74; nhãn ≥12px.

### Giữ
- Mỗi cuốn một màu vải; sách mini có độ dày theo số ảnh; ruy-băng đánh dấu (cuốn/chương đang dở).
- Khối "Continue · 2 of 4 days still have no memory written" + nút "Write a memory" theo từng ngày — đây là UX chính cho lúc vừa đi về.
- Ký ức dàn hai trang (ảnh + chữ), dòng EXIF.
- Dòng riêng tư "Kept on this device. No account, no cloud."
- Icon Lucide nét mảnh (app đã dùng `lucide_icons`).

### Bỏ / sửa khi triển khai
- Minh họa unDraw ở trạng thái trống → thiết kế lại empty state theo khung 3 ô (drawer + một cuốn sách trống "New Book").
- Drawer trống ~300px giữa Shelves và dòng riêng tư → lấp bằng nội dung thật (vd. "On this day" một năm trước) hoặc rút gọn chiều cao.
- Tiêu đề Hà Giang lặp ở bìa sách và cột thông tin (màn 1) → chọn một chỗ.
- Thumbnail Day 2 (cờ Lũng Cú) cắt ra toàn trời trắng → cho người dùng chọn ảnh đại diện chương / tự chọn ảnh ít trời.
- Sơ đồ vòng lặp là schematic: với dữ liệu GPS thật (EXIF) hãy vẽ từ tọa độ; không có GPS thì ẩn.
- Tab Photos / Route và "Memory 1 of 5" là chữ subagent tự thêm — xác nhận có trong phạm vi hay không.
- Nhãn "Journey stats" (spec ghi "Journeys stats") — chốt một tên.
- Trình đọc sách lật trang (bìa da, giấy ngà) giữ nguyên; chỉ đổi phần vỏ.

## Bước 1 — mobile + dark mode (2026-10-12)

- Người dùng (nguyên văn): "làm bước 1 rồi vào bước 2"
- `b-reference.html`: bản desktop đã sửa theo danh sách ở trên. Thêm theme tối (`#dark`) và màn `#screen-empty`.
- `b-mobile.html`: 4 khung 390×844 (`m-library`, `m-trip`, `m-memory`, `m-empty`), sáng và tối (`#dark`).
- `b-tokens.md`: token sáng/tối kèm tỉ lệ tương phản, quy tắc tính màu vải từ ảnh bìa (OKLCH), thang chữ, breakpoint, thành phần.
- Ảnh chụp: `shots/b-reference.src-[dark-]screen-*.jpg`, `shots/b-mobile-[dark-]m-*.jpg`.

## Bước 2 — triển khai Flutter (2026-10-12)

- Nhánh `ui-revamp/2026-10-12-1647`, gốc `75531dd`. Báo cáo: `app/.revamp/report.md`.
- Lệch có chủ ý so với thiết kế:
  - Tựa sách đặt ở cột thông tin, không ép nhũ trên bìa. Bìa chỉ mang tháng/năm (mực foil hoặc deep, theo tương phản).
  - Không có tab Route: app chưa có dữ liệu chặng đường.
  - Ký ức theo ngày hiện chồng lên nhau, không lật "Memory 1 of 5".
