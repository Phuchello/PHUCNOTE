# PHUCNOTE — CONCEPT A: DOCUMENT EXPERIENCE LAB REPORT
**Atelier Academic Document Reader, 16:9 Slide Workspace & PDF Annotations**

- **Date:** 2026-10-11
- **Repository:** `Phuchello/PHUCNOTE`
- **Branch:** `develop`
- **Design Concept:** Concept A — Academic Atelier (Oxford Navy, Warm Ivory `#FAF7F0`, Restrained Gold `#D4AF37`)
- **Validation Environment:** Android Tablet Emulator (`medium_tablet`, 2560×1600 @ 320 DPI, API 35, Android 15.0)

---

## 1. TỔNG QUAN VÀ ĐỊNH HƯỚNG SẢN PHẨM (EXECUTIVE SUMMARY)

Dựa trên sự lựa chọn của người dùng đối với **Concept A — Academic Atelier**, checkpoint này mở rộng toàn diện hệ sinh thái giao diện để chứng minh tính khả thi của việc xử lý tài liệu học thuật trong PHUCNOTE:
1. **Trình đọc tài liệu chuẩn học thuật (Document Reader):** Hỗ trợ tài liệu A4 đa trang, bài giảng trình chiếu 16:9, và bản thảo lưu trữ quét (scanned raster).
2. **Không gian ghi chú trực tiếp (Document Annotation):** Lớp vẽ vector độc lập trên tài liệu, hỗ trợ bút mực, bút dạ quang, tẩy chính xác, không làm biến dạng nội dung nguồn.
3. **Không gian học tập chia đôi (Split Study Workspace):** Đặt song song tài liệu bài giảng (Trái) và sổ tay viết tay PHUCNOTE (Phải) với thanh phân cách Atelier bằng đồng có thể điều chỉnh tỷ lệ linh hoạt.
4. **Thư viện học thuật mở rộng (Academic Library):** Quản lý đồng nhất sổ tay viết tay `.bfly`, tài liệu PDF, bài giảng Slide và bản quét với thẻ phân loại màu sắc riêng biệt.

> [!IMPORTANT]
> **Toàn bộ 12 trạng thái màn hình đã được render và chụp thực tế từ Android tablet emulator.**
> Bảng tổng hợp thị giác chính thức: [`artifacts/concept-a-document-lab/DOCUMENT_LAB_CONTACT_SHEET.png`](file:///c:/Users/lyle3/Music/Phucnote/artifacts/concept-a-document-lab/DOCUMENT_LAB_CONTACT_SHEET.png).

---

## 2. DANH MỤC 12 ẢNH CHỤP MÀN HÌNH THỰC TẾ (VERIFIED ARTIFACTS)

| TT | Tệp ảnh chụp | Kích thước | Hướng | Mô tả giao diện Concept A | Trạng thái |
|---|---|---|---|---|---|
| **01** | [`concept_a_library_mixed.png`](file:///c:/Users/lyle3/Music/Phucnote/artifacts/concept-a-document-lab/concept_a_library_mixed.png) | 2560×1600 | Ngang | Thư viện hỗn hợp: kệ "Tài liệu mở gần đây", lưới tài liệu với huy hiệu `.bfly`, `PDF A4`, `SLIDE 16:9`, `SCAN` | **VERIFIED** |
| **02** | [`concept_a_pdf_reader_landscape.png`](file:///c:/Users/lyle3/Music/Phucnote/artifacts/concept-a-document-lab/concept_a_pdf_reader_landscape.png) | 2560×1600 | Ngang | Đọc PDF A4: Tiêu đề tiếng Việt, công thức Toán Rời Rạc & Dijkstra, thanh khay bàn Atelier phía dưới | **VERIFIED** |
| **03** | [`concept_a_pdf_reader_portrait.png`](file:///c:/Users/lyle3/Music/Phucnote/artifacts/concept-a-document-lab/concept_a_pdf_reader_portrait.png) | 1200×1600 | Dọc | Đọc PDF A4 chế độ dọc: Trang A4 hiển thị trọn vẹn, căn giữa, không tràn RenderFlex | **VERIFIED** |
| **04** | [`concept_a_pdf_annotated.png`](file:///c:/Users/lyle3/Music/Phucnote/artifacts/concept-a-document-lab/concept_a_pdf_annotated.png) | 2560×1600 | Ngang | Chú thích PDF: Mực đỏ khoanh vùng công thức, dạ quang vàng, mũi tên ghi chú góc trang, vòng tẩy | **VERIFIED** |
| **05** | [`concept_a_pdf_thumbnails.png`](file:///c:/Users/lyle3/Music/Phucnote/artifacts/concept-a-document-lab/concept_a_pdf_thumbnails.png) | 2560×1600 | Ngang | Ngăn kéo trang nhỏ (Thumbnails Drawer): Danh sách 4 trang A4 kèm viền vàng nhũ trang hiện hành | **VERIFIED** |
| **06** | [`concept_a_slide_landscape.png`](file:///c:/Users/lyle3/Music/Phucnote/artifacts/concept-a-document-lab/concept_a_slide_landscape.png) | 2560×1600 | Ngang | Đọc Slide 16:9: Giữ nguyên tỷ lệ chuẩn bài giảng "Kiến trúc An toàn Mạng", không méo A4 | **VERIFIED** |
| **07** | [`concept_a_slide_portrait.png`](file:///c:/Users/lyle3/Music/Phucnote/artifacts/concept-a-document-lab/concept_a_slide_portrait.png) | 1200×1600 | Dọc | Đọc Slide 16:9 chế độ dọc: Letterbox cân đối trên dưới, công cụ điều hướng thu gọn an toàn | **VERIFIED** |
| **08** | [`concept_a_slide_annotated.png`](file:///c:/Users/lyle3/Music/Phucnote/artifacts/concept-a-document-lab/concept_a_slide_annotated.png) | 2560×1600 | Ngang | Chú thích Slide: Dạ quang xanh cyan làm nổi bật mục tiêu, khung mực đỏ ghi chú mã hóa bất đối xứng | **VERIFIED** |
| **09** | [`concept_a_split_slide_study.png`](file:///c:/Users/lyle3/Music/Phucnote/artifacts/concept-a-document-lab/concept_a_split_slide_study.png) | 2560×1600 | Ngang | Split Study Slide: Trái là Slide 16:9; Phải là Sổ tay PhucNote ghi chép nguyên lý Kerckhoffs & RSA | **VERIFIED** |
| **10** | [`concept_a_split_pdf_study.png`](file:///c:/Users/lyle3/Music/Phucnote/artifacts/concept-a-document-lab/concept_a_split_pdf_study.png) | 2560×1600 | Ngang | Split Study PDF: Trái là tài liệu A4; Phải là Sổ tay kẻ ngang ghi thuật toán Dijkstra kèm sơ đồ đồ thị S-B-C-T | **VERIFIED** |
| **11** | [`concept_a_doc_reader_dark.png`](file:///c:/Users/lyle3/Music/Phucnote/artifacts/concept-a-document-lab/concept_a_doc_reader_dark.png) | 2560×1600 | Ngang | Chế độ ban đêm (Dark Atelier): Nền đá phiến sâu `#0B0F14`, giấy tối `#161D26`, nét dạ quang & nhũ vàng tương phản cao | **VERIFIED** |
| **12** | [`concept_a_compact_narrow.png`](file:///c:/Users/lyle3/Music/Phucnote/artifacts/concept-a-document-lab/concept_a_compact_narrow.png) | 1200×1600 | Dọc | Khung nhìn máy tính bảng 8.8 inch / cửa sổ thu hẹp: Thanh tiêu đề và công cụ tự động co giãn không tràn | **VERIFIED** |

---

## 3. TÀI LIỆU THỬ NGHIỆM TỔNG HỢP (SYNTHETIC FIXTURES PIPELINE)

Để đảm bảo tính tái lập (reproducibility) 100% cục bộ mà không sử dụng tài liệu có bản quyền trên mạng, kịch bản Python [`scripts/generate_document_fixtures.py`](file:///c:/Users/lyle3/Music/Phucnote/scripts/generate_document_fixtures.py) đã tạo 4 tài liệu gốc hoàn chỉnh:

1. **`fixtures/document_lab/lecture_notes_discrete_math.pdf` (41.5 KB):**
   - Định dạng: 4 trang A4 (210 × 297 mm) tiêu chuẩn đại học.
   - Nội dung: Học phần Toán Rời Rạc & Lý thuyết Đồ thị. Bao gồm tiếng Việt có dấu đầy đủ (`Arial.ttf` nhúng Unicode), định lý Euler, ma trận kề, thuật toán Dijkstra và sơ đồ mạng đồ thị.
2. **`fixtures/document_lab/lecture_slides_network_security.pptx` (39.8 KB):**
   - Định dạng: 6 slide tỷ lệ 16:9 chuẩn trình chiếu hiện đại.
   - Nội dung: Học phần Kiến trúc Mạng & Mật mã học. Bao gồm mô hình OSI 7 tầng, sơ đồ khối mã hóa đối xứng AES vs bất đối xứng RSA, bảng so sánh và công thức $C = M^e \pmod n$.
3. **`fixtures/document_lab/lecture_slides_network_security.pdf` (30.5 KB):**
   - Bản xuất PDF trung thực 16:9 của cùng 6 slide bài giảng trên.
4. **`fixtures/document_lab/scanned_historical_notes.pdf` (176.0 KB):**
   - Bản quét giả lập tài liệu lưu trữ năm 1984: Có nền giấy ố vàng cổ điển, hạt nhiễu cơ học (film grain noise), và con dấu mộc tròn lưu trữ văn thư.

---

## 4. ĐÁNH GIÁ TÍNH KHẢ THI KỸ THUẬT (PHASE 7 TECHNICAL FEASIBILITY)

### 4.1. Khả năng kết xuất trang PDF thực tế (Real PDF Page Rendering)
- **Nền tảng Android Native:** Android hỗ trợ API chuẩn `android.graphics.pdf.PdfRenderer` từ Android 5.0 (API 21+). API này cho phép mở tài liệu PDF từ `ParcelFileDescriptor` và render từng trang ra `Bitmap` với độ phân giải tùy chọn (thông qua `Page.render(bitmap, null, null, Page.RENDER_MODE_FOR_DISPLAY)`).
- **Giải pháp Flutter:**
  - *Phương án A (Plugin PDFium nhẹ như `pdfx` / `pdfrx`):* Sử dụng thư viện C++ Google PDFium biên dịch sẵn. Hỗ trợ zoom đa mức mượt mà, nhưng tăng dung lượng APK khoảng 8–12 MB cho các kiến trúc `arm64-v8a` và `x86_64`.
  - *Phương án B (Platform Channel native gọi `PdfRenderer`):* Không tốn thêm dung lượng nhị phân nào, tận dụng engine có sẵn của hệ điều hành Android tablet.
- **Kết luận:** Hoàn toàn khả thi trên Android mà không cần dịch vụ đám mây.

### 4.2. Điều hướng đa trang và chiến lược bộ nhớ (Multi-Page Navigation & Memory Budget)
- **Vấn đề tiềm ẩn:** Một tài liệu PDF 100 trang nếu render tất cả ra Bitmap 2560×1600 (320 DPI) sẽ tiêu tốn:
  $$100 \times (2560 \times 1600 \times 4\text{ bytes}) \approx 1.638\text{ GB RAM}$$
  Điều này sẽ gây lỗi tràn bộ nhớ (Out-Of-Memory — OOM) ngay lập tức trên máy tính bảng Android phổ thông.
- **Giải pháp khả thi:**
  - Áp dụng kỹ thuật **Virtualization (Cửa sổ trượt)**: Chỉ duy trì trong bộ nhớ tối đa 3 trang (trang trước, trang hiện tại, trang sau).
  - Sử dụng **Thumbnail cache** độ phân giải thấp (120×170 px $\approx$ 80 KB/trang) cho ngăn kéo điều hướng.

### 4.3. Kết xuất PDF Vector so với Raster Image
- **So sánh:**
  - *PDF Vector:* Khi phóng to 300%–500% để đọc công thức hoặc biểu đồ nhỏ, văn bản vector giữ độ sắc nét tuyệt đối.
  - *Pre-rendered Image (như prototype hiện tại):* Dễ tích hợp, tải tức thì, nhưng khi zoom sâu vào chi tiết sẽ xuất hiện hiện tượng vỡ hạt điểm ảnh.
- **Khuyến nghị kiến trúc:** Khi chuyển sang giai đoạn sản xuất, sử dụng pipeline render ngói (Tiled PDF rendering) khi người dùng zoom sâu quá $1.5\times$.

### 4.4. Khả năng chuyển đổi và đọc bài giảng PPTX
- **Hiện trạng:** Định dạng `.pptx` là một gói nén ZIP chứa các tệp XML (Office Open XML). Android không có engine tích hợp sẵn để render trực tiếp PPTX sang đồ họa vector Canvas.
- **Đánh giá chuyển đổi:**
  - Cố gắng nhúng một bộ phân tích OOXML toàn diện vào app sẽ tăng độ phức tạp khổng lồ và độ trung thực bố cục thấp (lỗi font chữ, lệch bảng biểu).
  - **Khuyến nghị chính thức:** PHUCNOTE nên hỗ trợ luồng "Nhập bài giảng Slide dưới dạng PDF" (hầu hết giảng viên và sinh viên đều xuất PPTX sang PDF trước khi nhập vào tablet ghi chú). Đối với tệp PPTX gốc, cung cấp thông báo rõ ràng: *"Vui lòng lưu bài giảng dạng PDF để có chất lượng hiển thị tốt nhất trên máy tính bảng"*.

### 4.5. Ánh xạ tọa độ nét vẽ ghi chú (Coordinate Mapping for Ink Annotations)
- **Nguyên lý bất biến tọa độ:** Nét viết tay tuyệt đối không được neo vào pixel màn hình ($X_{screen}, Y_{screen}$), mà phải neo vào không gian tài liệu chuẩn ($X_{doc}, Y_{doc}$):
  $$\begin{bmatrix} X_{doc} \\ Y_{doc} \end{bmatrix} = M_{viewport}^{-1} \cdot \begin{bmatrix} X_{screen} \\ Y_{screen} \end{bmatrix}$$
- **Chuẩn hóa kích thước trang:** Tọa độ nét vẽ của mỗi trang được lưu trong khoảng tỉ lệ $[0.0, 1.0]$ hoặc theo đơn vị điểm chuẩn PDF Points ($72\text{ pt/inch}$, ví dụ khổ A4 là $595.28 \times 841.89\text{ pt}$). Nhờ đó, dù hiển thị ở chế độ dọc, ngang, hoặc thu phóng bất kỳ, nét mực luôn nằm đúng vị trí từ chữ cái đến công thức mà không bao giờ bị lệch.

### 4.6. Tách biệt lưu trữ và tương thích định dạng `.bfly`
- **Tính an toàn tuyệt đối:**
  - Tệp PDF nguồn được đối xử như một tài nguyên **chỉ đọc (immutable read-only)**. PHUCNOTE không ghi đè hay biến đổi tệp PDF gốc.
  - Các nét chú thích của người dùng được lưu trữ trong một lớp vector đi kèm (`.bfly` sidecar container hoặc metadata layer).
  - Tương thích 100% với schema sổ tay hiện tại: Định dạng `.bfly` sẵn có các khối `strokes` và `transforms`; việc bổ sung khóa `document_ref` (đường dẫn tài liệu và số trang) là phần mở rộng tự nhiên mà không phá vỡ cấu trúc giải tuần tự.

---

## 5. PHÂN LOẠI MINH BẠCH THEO YÊU CẦU ĐẶT HÀNG

Theo chỉ thị nghiêm ngặt của dự án, các thành phần được phân tách rõ ràng thành 3 cấp độ:

```
┌────────────────────────────────────────────────────────────────────────┐
│                        PHÂN CẤP TÍNH KHẢ THI                           │
├────────────────────────────────┬───────────────────────────────────────┤
│ 1. VISUALLY DEMONSTRATED       │ • Giao diện Concept A Academic Atelier│
│    (Đã minh chứng thị giác     │ • Trình đọc PDF A4 (Ngang & Dọc)      │
│     trên Emulator thực tế)     │ • Trình đọc Slide 16:9 (Ngang & Dọc)  │
│                                │ • Chú thích bút mực & dạ quang        │
│                                │ • Vòng chỉ báo tẩy không phá hủy gốc  │
│                                │ • Thumbnails drawer chọn trang        │
│                                │ • Split Study Slide + Sổ tay          │
│                                │ • Split Study PDF + Sổ tay            │
│                                │ • Thanh chia tỷ lệ động bằng đồng     │
│                                │ • Thư viện học thuật hỗn hợp          │
│                                │ • Chế độ Dark Atelier                 │
│                                │ • Giao diện hẹp Compact 8.8 inch      │
├────────────────────────────────┼───────────────────────────────────────┤
│ 2. FUNCTIONALLY VERIFIED       │ • Kịch bản tạo 4 fixture tài liệu     │
│    (Đã kiểm thử chức năng &    │ • Font nhúng Unicode tiếng Việt sạch  │
│     chạy tự động thành công)   │ • Asset pipeline nạp ảnh 180 DPI      │
│                                │ • Tỷ lệ 16:9 và A4 giữ nguyên         │
│                                │ • Thanh công cụ co giãn không lỗi     │
│                                │ • 12/12 kiểm thử capture PASS 100%    │
│                                │ • 114 unit/widget tests hồi quy PASS  │
│                                │ • flutter analyze: 0 lỗi, 0 cảnh báo  │
├────────────────────────────────┼───────────────────────────────────────┤
│ 3. NOT IMPLEMENTED             │ • Bộ phân tích tệp PPTX native        │
│    (Chưa triển khai vào        │ • Động cơ C++ PDFium vào editor chính │
│     mã nguồn sản xuất)         │ • Persistence lưu chú thích vào .bfly │
│                                │ • Xuất tệp PDF kèm nét vẽ đã gộp      │
│                                │ • Bút viết thời gian thực trên PDF    │
└────────────────────────────────┴───────────────────────────────────────┘
```

---

## 6. BẢO TOÀN AN TOÀN HỆ THỐNG SẢN XUẤT (SAFETY & ISOLATION)

- **Cô lập mã nguồn:** Toàn bộ nguyên mẫu Document Lab được đặt biệt lập trong thư mục `lib/design_preview/document_lab/`. Không có bất kỳ tệp sản xuất cốt lõi nào (`lib/ui/`, `lib/core/`, `lib/drawing/`) bị thay đổi logic hay thêm nút bấm mới.
- **Bảo toàn chức năng đã hoàn thành:** Các tính năng cốt lõi đã được nghiệm thu trước đó:
  - Khổ giấy A4 và đường gióng lưới.
  - Phuc Pen Studio và bảng điều khiển.
  - Hệ thống lưu tự động ngầm (Autosave Engine).
  - Chế độ tập trung (Zen Mode) và hoàn tác (Undo/Redo).
  - Toàn bộ 114 bài kiểm tra tự động đều chạy thành công mỹ mãn.

---

## 7. KẾT LUẬN VÀ BƯỚC TIẾP THEO

Nguyên mẫu **Concept A: Document Experience Lab** đã chứng minh rằng phong cách **Academic Atelier** (Oxford Navy, Giấy Ngà Ấm, Nhũ Vàng Thao Khảm) hoàn toàn vượt trội trong việc đem lại cảm giác học thuật chuyên sâu, cao cấp và khác biệt cho người dùng máy tính bảng. 

Tất cả 12 ảnh chụp màn hình chất lượng cao và bảng đối chiếu tổng hợp đã sẵn sàng để người dùng đánh giá thẩm mỹ trực tiếp.
