# Hướng B (Day One): token & thành phần, bàn giao Flutter

- Nguồn: `b-reference.html` (desktop 1440×900, 3 màn) và `b-mobile.html` (390×844, 4 màn). Khối token trong hai file **giống hệt nhau** (mobile chép nguyên văn giữa hai dấu `/*@TOKENS-BEGIN…*/` và `/*@TOKENS-END@*/`).
- Theme tối: thêm `#dark` vào URL, script đặt `html[data-theme="dark"]`.
- Mọi tỉ lệ tương phản dưới đây đều tính theo WCAG 2.x (sRGB), và đã đo lại trên ảnh render bằng `audit.py`: 0 lỗi ở cả 7 màn × 2 theme.
- Flutter: gom mọi thứ vào một `ThemeExtension<BookTokens>` (light/dark), cộng thêm một `ClothTheme` (InheritedWidget) cho từng cuốn. Chỉ map vào `ColorScheme` những vai trò có sẵn tương đương: `primary = sun`, `onPrimary = on-sun`, `surface = paper-1`, `onSurface = ink-1`, `onSurfaceVariant = ink-2`, `outline = line`. Phần còn lại không gán vào vai trò M3 vì `paper-0` sáng hơn `paper-1` ở **cả hai** theme, ngược với quy ước surfaceContainer.

## 1. Màu nền và chữ (light / dark)

| Token | Light | Dark | Vai trò | Tương phản light | Tương phản dark |
|---|---|---|---|---|---|
| `paper-0` | `#FCFAF6` oklch(.985 .006 80) | `#231E19` oklch(.239 .012 67) | Bề mặt nổi: trang ký ức, ô tìm kiếm, pill đang chọn, slip (dark) | nền | nền |
| `paper-1` | `#F8F3EC` (.966 .011 80) | `#1B1713` (.208 .010 67) | Nền gốc: cột danh sách, nền app | nền | nền |
| `paper-2` | `#EFE9DF` (.936 .015 78) | `#15110D` (.181 .010 67) | Bề mặt lõm: drawer, rail, tab bar, rãnh segmented | nền | nền |
| `line` | `#DED6CC` | `#3C352F` | Hairline 1px | 1.30 với p1 | 1.48 với p1 |
| `line-soft` | `#E8E2D9` | `#2F2924` | Vạch chia giữa các dòng sách | n/a | n/a |
| `tint` | `rgba(44,30,24,.06)` | `rgba(237,229,216,.07)` | Lớp phủ nhạt cho dòng shelf đang chọn | n/a | n/a |
| `ink-1` | `#2C1E18` | `#EDE5D8` (.925 .019 80) | Chữ chính | 15.4 / 14.6 / 13.3 | 13.2 / 14.3 / 15.0 |
| `ink-2` | `#51453D` | `#CBC1B3` (.815 .022 76) | Chữ phụ | 8.9 / 8.4 / 7.7 | 9.3 / 10.0 / 10.6 |
| `ink-3` | `#6C6158` | `#A99E91` (.705 .023 72) | Meta, nhãn caps | 5.8 / 5.5 / **5.0** | 6.3 / 6.8 / 7.1 |
| `sun` | `#A64F2B` (.53 .125 42) | `#DF8D64` (.719 .115 47) | Màu hành động duy nhất: nút chính, ruy-băng | fill so với p1: 5.0 | fill so với p1: 6.9 |
| `on-sun` | `#FFFFFF` | `#25150E` (.215 .03 44) | Chữ trên nút `sun` | **5.56** | **6.82** |
| `sun-ink` | `#9A4825` | `#E8A87C` (brand sunrise) | `sun` dùng làm chữ: link, kicker, "Write one" | 6.1 / 5.7 / 5.2 | 8.1 / 8.8 / 9.2 |
| `dawn` | `#E8A87C` | `#E8A87C` | Chặng/địa điểm đang mở trên nền vải tối, ngày trống trên ContinueCard | 7.6 trên hg-deep | 7.6 |
| `edge-1 / edge-2` | `#F6EFE2 / #DCD2C2` | `#CEC6B9 / #9D9488` | Sọc mép giấy của sách mini (dark hạ sáng để đỡ chói) | n/a | n/a |
| `edge-big-1 / -2` | `#F3EAD9 / #CFC4B0` | `#D8CFBF / #A39882` | Mép giấy bìa cứng lớn | n/a | n/a |
| `slip` + `slip-edge` | `paper-1` + không viền | `paper-0` + viền 1px `line` | Tờ "Continue" kẹp dưới sách | n/a | n/a |

Bộ ba số là tương phản trên `paper-0 / paper-1 / paper-2`. Mọi cặp chữ/nền đều ≥4.5:1. Cặp thấp nhất là `ink-3` trên `paper-2` (light) = 4.99.

**Dark được thiết kế lại, không đảo màu:** giấy là nâu-đen ấm (hue ~67, chroma .010–.012, không xanh slate, không `#0D1117`, không glow). Thứ tự độ sáng giữ nguyên ý nghĩa (nổi > gốc > lõm). `sun` nâng về gần màu bình minh của brand và **chữ trên nút đổi sang nâu đậm**. Vải hạ L .03. Nền vải đậm (`*-deep`), nhũ và ảnh **giữ nguyên** ở cả hai theme. Bóng đổi sang đen, alpha cao hơn. Pill đang chọn dùng viền 1px thay cho bóng.

## 2. Vải bìa theo cuốn

| Cuốn | `cloth` light | `cloth` dark (L−.03, C×.95) | `deep` (cả 2 theme) | `mute` trên deep | `mark` dark | Chữ tựa trên bìa |
|---|---|---|---|---|---|---|
| Hà Giang `hg` | `#2F5649` (.42 .05 170) | `#294D41` | `#132821` | `#B6C2B3` 8.4 | `#599480` 4.7 | foil 4.85 |
| Hội An `ha` | `#AC853F` (.64 .10 80) | `#A17C3B` | `#2C210E` | `#DECBAB` 9.9 | `#A67F39` 4.5 | deep 4.64 |
| Kyoto `ky` | `#9D3629` (.48 .14 30) | `#903024` | `#321C19` | `#DDB4A2` 8.5 | `#C4685A` 4.3 | foil 4.13 |
| Đà Lạt `dl` | `#576574` (.50 .03 250) | `#4F5C6A` | `#1C242B` | `#C2C0BA` 8.6 | `#668AAF` 4.6 | foil 3.51 |
| Luang Prabang `lp` | `#AF7033` (.60 .11 62) | `#A3682F` | `#2F1F11` | `#E0C5A8` 9.6 | `#B57639` 4.4 | deep 3.92 |
| Côn Đảo `cd` | `#6E8D90` (.62 .035 205) | `#678486` | `#162627` | `#CACDC3` 9.7 | `#4E9399` 4.7 | deep 4.38 |
| Chưa có bìa `earth` | `#63453A` (.42 .045 41) | `#593D33` | `#2E1E19` | `#C6B5A6` 8.0 | n/a | foil 5.06 |

Dùng chung trên vải: `parch #F3EAD9` (chữ chính trên deep, ≥12.99:1 với mọi cuốn), `gold #D1BB92` (đường kẻ, viền ảnh, caps trên deep, ≥8.3:1), `foil #DAC49D` (chữ ép trên bìa `cloth`), `on-cloth-line rgba(243,234,217,.18)`, `on-cloth-ghost rgba(243,234,217,.38)` (viền nút ghost).

**Quy tắc tính màu vải từ ảnh bìa** (thay cho bảng tay ở trên khi chạy thật):
1. Thu ảnh bìa về 64×64. Bỏ pixel có oklch L < .15 hoặc > .92 (bóng tối, trời trắng). Gom màu bằng k-means hoặc `PaletteGenerator`, ~12 cụm.
2. Chọn cụm có điểm cao nhất theo `số pixel × chroma`. Lấy trung bình của 1/3 pixel có chroma cao nhất trong cụm đó (đúng cách đã lấy mẫu tay).
3. Ép về khoảng: **L ∈ [.42, .64]**, **C ∈ [.03, .14]**, giữ nguyên H. Nếu lọt ra ngoài gamut sRGB thì giảm C.
4. `cloth-dark = oklch(L−.03, C×.95, H)`; `deep = oklch(.255, min(C×.6, .035), H)`, dùng cho nền khung chi tiết, header chuyến đi, dòng đang chọn, ContinueCard.
5. `mute = mix(parch, cloth, 30%)` trong không gian oklab. Với Hà Giang, phép trộn này ra `#B5BBAB`, gần như trùng `#B6C2B3` đã duyệt.
6. `mark` (vạch trạng thái nhỏ trên giấy): light = `cloth` (≥3.08:1, đủ mức 3:1 cho thành phần không phải chữ); dark = `oklch(.62, clamp(C,.07,.12), H)`.
7. Chữ tựa trên bìa (≥24px nên ngưỡng là 3:1): dùng `foil` hay `deep`, tùy cái nào tương phản cao hơn với `cloth`. Dòng ngày 12px dưới tựa chỉ hiện khi mực đó đạt ≥4.5:1 (trong bảng chỉ `hg`, `earth` đạt). Dòng này là bản trùng của ngày đã có ở cột thông tin, nên bọc `ExcludeSemantics`.
8. Chưa có ảnh bìa → `earth`.

## 3. Thang chữ

Literata (serif, có trục opsz 7–72, subset vietnamese) và Be Vietnam Pro (UI). Bundle cả hai vào `app/assets/fonts/`. Mọi con số dùng `FontFeature.tabularFigures()` + lining.

| Vai trò | Font / weight | Desktop size / line-height | Mobile | Ghi chú |
|---|---|---|---|---|
| display (tựa chuyến đi) | Literata 600, −0.02em | 52 / 1.0 | 30 / 1.05 | |
| h1 (tựa màn) | Literata 600, −0.01em | 32 / 1.1 | 34 / 1.1 | mobile dùng large title |
| headline trống | Literata 600 | 34 / 1.12 | 28 / 1.15 | "Turn your trips into books" |
| h2 (tựa ký ức) | Literata 600, −0.01em | 30 / 1.15 | 26 / 1.15 | |
| foil trên bìa | Literata 600, +0.01em | 25 / 1.15 | 19 | `foil` |
| h3 (tựa slip/Continue) | Literata 600 | 20 / 1.3 | 18 / 1.3 | |
| row title (sách / chương) | Literata 600 | 18 / 1.25; chương 19 | 17 / 1.25, tối đa 2 dòng | địa danh dính liền, xem mục 7 |
| số ngày lớn | Literata 500 | 21 (sách), 28 (chương) | 19 / 24 | |
| số liệu (StatsRow) | Literata 500 | 24 | 22 | |
| blurb in nghiêng | Literata italic 400 | 16–17 / 1.55 | (không dùng) | |
| memory body | Literata 400 | **19 / 1.74** | **17 / 1.68** | `lang=vi` |
| body | Be Vietnam Pro 400 | 15 / 1.5 | 15–16 / 1.5 | sàn của chữ thân |
| secondary | Be Vietnam Pro 400/500 | 14 / 1.45 | 14 | nơi chốn, địa điểm |
| meta | Be Vietnam Pro 400 | 13 / 1.45 | 13 | số ảnh/ký ức, dòng riêng tư |
| label caps | Be Vietnam Pro 600, +0.09em, UPPER | 12 | 12 | sàn của nhãn |
| button | Be Vietnam Pro 600 | 14 (cao 40–44) | 15 (cao 44–48); 13 cho nút xếp dọc | |
| tab label | Be Vietnam Pro 500, đang chọn 600 | | 12 | |
| EXIF | Be Vietnam Pro 400, tabular | 12 / 1.45 | 12 | không dùng font mono |

## 4. Spacing, radius, viền, bóng

| Nhóm | Giá trị |
|---|---|
| Spacing (lưới 4) | 4 · 8 · 12 · 16 · 20 · 24 · 32 · 40 · 52. Mock có dùng 6/10/14/18/22 để căn quang học; khi dựng Flutter thì làm tròn về lưới. Lề cột: desktop 24 (danh sách) / 32 (header) / 40 (trang ký ức); mobile 16 (danh sách) / 20 (nội dung). |
| Radius | 2 ảnh lớn, gáy · 3 thumb · 4 slip, kbd · 6 nút, nav item, mép phải bìa · 8 ô tìm kiếm, card mobile, segmented, icon button · 14 pill tab · 22 nút tròn trên ảnh · 999 chip sort |
| Viền | hairline 1px `line`; vòng tick ngày trống 1.5px inset; ô trống 1px **dashed** (`ink-3` trên giấy, `gold`/`foil` trên vải); chip rail đang chọn: outline 2px `ink-1`, offset 3 |
| Bóng light | `sh-pill 0 1 2 rgba(44,30,24,.12)` · `sh-chip 0 1 2 /.25` · `sh-mini 0 2 3 /.18` · `sh-book 0 30 50 −18 rgba(0,0,0,.65)` + inset 0 2 0 trắng .06 · `sh-book-sm 0 14 22 −10 /.7` · `sh-book-xs 0 6 10 −4 /.6` · `sh-pages 0 20 30 −14 /.6` · `sh-slip 0 18 40 −20 /.7` |
| Bóng dark | `sh-pill` → viền 1px `line` · `sh-chip /.6` · `sh-mini rgba(0,0,0,.55)` · `sh-book /.85` · `sh-book-sm /.85` · `sh-book-xs /.75` · `sh-pages /.8` · `sh-slip /.9` |
| Scrim ảnh | `scrim-top`: gradient 0→130px, `rgba(14,10,8,.62 → .28 → 0)`; `scrim-btn rgba(20,14,10,.6)` làm nền nút tròn trên ảnh. Không dùng backdrop-filter. |
| Chất liệu | Vân vải: 2 lớp sọc 1px/3px (`weave-hi` trắng .025, `weave-lo` đen .04), vẽ bằng CustomPaint hoặc bỏ. Gáy: gradient ngang `spine-shade`. Ruy-băng: ClipPath đa giác, khía đuôi 18–24%. Ảnh sách cũ: ColorFilter.matrix (1 năm: sat .92 sepia .04; 2 năm: .84/.09; ≥3 năm: .76/.14). |

## 5. Breakpoint và hành vi khung

| Bề rộng | Khung | Chi tiết |
|---|---|---|
| ≥1200 | **3 ô**: drawer 256 · danh sách · chi tiết | Danh sách = clamp(400, 36%·W, 520). Chi tiết lấy phần còn lại. Chi tiết <640 thì bìa thu 0.8× và cột thông tin xuống dưới bìa. Màn chuyến đi: rail 72 · cột chương 560–640 · trang ký ức. Trang ký ức <640 thì ảnh nằm trên chữ. |
| 720–1199 | **2 ô + rail 72** | Rail: logo, mở drawer (dạng overlay), Library / Journey stats / Settings, chip màu từng cuốn. Ô 1 = danh sách sách hoặc chương (320–420); ô 2 = chi tiết. |
| <720 | **1 ô đẩy chồng + tab bar dưới** | Library (tab) → push Trip → push Memory. Tab bar chỉ hiện ở màn cấp cao nhất (Library, Journey stats, Settings) và ẩn ở màn push. Back nằm trên trái; Memory có thanh trước/sau ở đáy. Chừa safe area (status 47, home indicator 34). |

## 6. Thành phần

| Thành phần | Kích thước | Trạng thái / quy tắc |
|---|---|---|
| **BookMini** | desktop 62×76 (gáy 8 + bìa 46 + mép giấy); mobile 58×70 (7 + 44) | Mép giấy rộng `clamp(round(1.5 + ảnh/36), 2, 8)` px, khớp cả 6 cuốn. Ảnh lão hóa theo tuổi. **blank**: bìa = `cloth` + ô dashed + icon image-plus. |
| **Hardcover + ribbon** | lớn 246×344 + mép 14 + ruy-băng 14×48; nhỏ 72×100 (mobile header, không có tựa); trống 160×212 (mobile) | Cửa sổ ảnh 176×144, outline 1px gold, offset 4. Gáy 24 với 2 đai nhũ. Ruy-băng = cuốn/chương đang dở. **empty**: cửa sổ dashed + "Cover photo", tựa "New Book", vải `earth`. Tựa chỉ xuất hiện **một lần** trên màn (ở bìa). |
| **ContinueCard** | desktop: slip giấy trong khung vải, 584×340; mobile: card `deep`, rộng 358, radius 8 | Hiện khi một cuốn còn ngày chưa có ký ức. DayTicks 30–34×8: đã viết = `mark` (giấy) / `gold` (vải); trống = viền 1.5 `sun`/`dawn` + nhãn cùng màu. Mỗi ngày trống một dòng: thumb (92×72 / 52×52) + caps ngày + chặng + nút "Write a memory" (desktop 38) / "Write" (mobile 44). Mất hẳn khi đủ ký ức. |
| **ChapterRow** | desktop cao 111, lưới 52 / 1fr / thumb 150×88; mobile lưới 44 / 1fr / thumb 76×76, cao ≥106 | Mặc định · **chưa có ký ức**: "no memory yet" + link "Write one" (mobile vùng chạm 44) · **đánh dấu**: ruy-băng 14×26 (12×22) trên cột ngày + kicker `sun-ink` · **đang chọn** (chỉ desktop): nền `paper-0` lấn 1px qua đường chia. Dòng địa điểm chỉ 1 dòng, dư thì "…". |
| **MemorySpread** | desktop: ảnh dọc 300×533 + cột chữ, dải "More from Day N" 4×90, footer meta 56; mobile: ảnh tràn 390×296 có scrim, chữ 17/1.68, dải 4×60, thanh trước/sau 52 + 34 | EXIF dưới ảnh. Thanh mobile: ‹ · "Memory 1 of 5" + "Hà Giang Loop · Day 3 of 4" · ›. Nút trên ảnh là vòng tròn 44 dùng `scrim-btn`. |
| **RouteLoop** | 220×250 (desktop header chuyến đi) | Chặng thường: `gold` 60%, 2px. Ngày đang mở: `dawn` 3.5px. Điểm qua đêm: vòng r4. Địa điểm r3.5, đang mở r4.5 `dawn`. Điểm đầu/cuối: ô vuông 12 `parch`. Nhãn 12px `mute` / `dawn` 600. Vẽ từ GPS trong EXIF; không có GPS thì ẩn. Mobile để ở tab Route, không đặt trong header. |
| **Drawer / Rail / TabBar** | drawer 256 (pad 22/20); rail 72; tab bar 56 + safe area | Drawer: brand 40 · New Book 42 · nav 38 (desktop dùng chuột; cảm ứng thì ≥44) · Shelves (All books 40, năm 48 hai dòng "N days · N photos") · Countries (40) · dòng riêng tư ghim đáy, có hairline. Rail: nút 40, chip vải 28×36, chip đang chọn có outline. Tab: pill chỉ báo 56×28 `paper-0` + viền 1px `line`. |
| **StatsRow** | 4 cột | Số Literata 24/22 `parch` + nhãn 13 `mute`. Hairline `on-cloth-line` ở trên. Desktop căn space-between, mobile 4 cột đều. |
| **ActionButtons** | primary 40/44/48; mobile 3 nút xếp dọc cao 48 | Primary `sun`/`on-sun`; ghost trên vải: viền `on-cloth-ghost`, chữ `parch`; ghost trên giấy: viền `line` + nền `paper-0`; text button: `ink-2`. Header mobile: "Open the book" rộng hết, bên dưới là Add photos · Write a memory · Export PDF. Edit nằm trên nav bar. |
| **Segmented (Chapters/Photos/Route)** | desktop cao 32 trong rãnh 3px; mobile cao 44 | Rãnh `paper-2`; đang chọn `paper-0` + `sh-pill`. |
| **EmptyBook** | desktop: khung chi tiết `earth-deep`, bìa ở top 250; mobile: dải vải 300 | Đi kèm headline "Turn your trips into books", lede (câu có sẵn trong app), CTA "Create your first book" (chuỗi có sẵn trong `home_screen.dart`), dòng riêng tư. Desktop có thêm một dòng "New Book · No photos yet" đang chọn trong danh sách. Không minh họa. |

## 7. Quy tắc nội dung ảnh hưởng tới layout

- Địa danh không được ngắt giữa chừng: nối các chữ trong một tên bằng U+00A0 (`Mèo Vạc`, `Du Già`) và dính `→` vào tên đứng trước, để không dòng nào bắt đầu bằng mũi tên.
- Tên điều hướng đã chốt: **Journey stats** (bỏ "Journeys stats").
- Chưa thiết kế: hover/pressed/disabled/focus ring, chữ phóng to (text scale ≥1.3), RTL. Cần làm ở bước triển khai.
