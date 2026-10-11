# Concept A — PDF functional proof of concept

Ngày kiểm chứng: 2026-10-11. Nhánh `develop`, baseline
`1087b5ebf9dd51128fe5da98a9375229938a8550`. Ứng dụng độc lập tại
`examples/pdf_functional_poc/`, package `com.phucnote.pdf_functional_poc`.
Backend: **Android PdfRenderer**, một worker serialize open/render/close.
Không tích hợp vào màn hình hay lưu trữ production.

## Các checkpoint và thay đổi

A: đối chiếu tài liệu/source chính thức, kiểm tra Flutter 3.47.7, Dart 3.13.5,
Java 17 và Android 15 đang có; scaffold build thành công. Không nâng SDK/JDK.
So sánh pdfrx/pdfx và giới hạn thử nghiệm ở `PDF_BACKEND_DECISION.md`.

B/C: mở PDF gốc bằng byte, đọc metadata thật, render từng trang theo yêu cầu.
Điều hướng đầu/cuối/trước/sau/thumbnail; Fit-to-Page, Fit-to-Width, pinch zoom
và pan áp dụng transform thật. Cache tối đa hai bitmap, 24MiB decoded; native
raster tối đa 4 triệu pixel. Token tài liệu/request loại kết quả và lỗi cũ.
Mỗi native page, renderer và file descriptor có đường close rõ ràng.

D: adapter giữ nguyên ba model/geometry production, với kiểm tra byte identity.
Bút, highlighter, tẩy toàn nét, undo/redo và nét theo từng trang hoạt động trên
lớp riêng. Điểm/style bất biến; mực chỉ tồn tại trong phiên, PDF luôn chỉ đọc.
Gesture cancel/đổi trang giữ phần đã nhận và lịch sử. Không sửa serializer.

E: Split Study dùng cùng backend thật cho cả sáu slide; ba trang ghi chú trắng
trong bộ nhớ ở pane bên phải. Divider kéo được, preset 40:60/50:50/60:40.
Viewport, trang và lịch sử hai pane độc lập. Portrait dùng chọn Tài liệu/Ghi chú.
Navy/ivory/gold, nút 48dp và nhãn thao tác tiếng Việt được giữ.

F: 12 screenshot emulator thật, trace và contact sheet; chuyển PPTX thực bằng
PowerPoint đang cài; báo cáo, fixture chuyển đổi và source được review riêng.

## Kết quả theo ID

Quality gates đã thực thi trong example: `flutter analyze` PASS (0 issues),
`flutter test test/` PASS (7 test), `flutter drive ...all_test.dart` PASS (3
kịch bản; dòng framework +4 gồm tearDownAll), `flutter build apk --debug` PASS.
Kịch bản rendering chạy bổ sung với finger drag và hai-pointer pinch cũng PASS.
ADB HOME/resume trên APK entry point thường giữ cùng PID 6756, không có crash/ANR
đúng package. Đây là kiểm chứng thực thi; screenshot không thay thế assertion.

| ID | Kết quả | Assertion/bằng chứng |
| --- | --- | --- |
| PDF-01 | PASS | PDF thật có 4 trang, raster không trống |
| PDF-02 | PASS | 4 fingerprint raster khác nhau; đầu/cuối và thumbnail đổi trang đúng |
| PDF-03 | PASS | Đủ 6 fingerprint slide khác nhau |
| PDF-04 | PASS | Metadata A4 và 960/540; painter giữ tỷ lệ nguồn native |
| PDF-05 | PASS | Fit rộng đổi scale; chiều rộng thật bằng viewport trừ 32dp |
| PDF-06 | PASS | Scale 200% thật; ảnh zoom và phép inverse được kiểm tra |
| PDF-07 | PASS | Offset pan và inverse đúng; hỗ trợ touch scale gesture |
| PDF-08 | PASS | Chuỗi đổi trang nhanh kết thúc đúng trang; render/lỗi cũ bị loại |
| PDF-09 | PASS | PDF quét một trang render bằng backend native |
| PDF-10 | PASS | Byte không phải PDF trả lỗi tiếng Việt, handle native còn 0 |
| INK-01 | PASS | Stylus events được dispatch qua pointer listener tạo nét thật trong bộ nhớ; bút vật lý chưa thử |
| INK-02 | PASS | JSON/điểm giữ nguyên sau zoom/pan, cùng transform với bitmap |
| INK-03 | PASS | Trang 2 còn nét khi quay lại; trang 3 không có nét trang 2 |
| INK-04 | PASS | Tẩy chỉ đổi sheet; byte raster PDF không đổi |
| INK-05 | PASS | Ba chu kỳ undo/redo giữ đúng JSON, style và thứ tự |
| SPLIT-01 | PASS | Preset và kéo divider làm thay đổi kích thước render thật |
| SPLIT-02 | PASS | Sáu slide khác nhau ngay trong pane trái |
| SPLIT-03 | PASS | Trang/zoom/pan/mực ghi chú không đổi theo điều hướng PDF và ngược lại |
| SPLIT-04 | PASS | Xoay display thật, chọn tài liệu/ghi chú và không có layout exception |
| LIFE-01 | PASS | Ba vòng open/close, cache 0, native documents 0; active gesture unmount an toàn |
| LIFE-02 | PASS | ADB HOME rồi resume cùng PID, activity về foreground; không thấy crash/ANR đúng package |
| LIFE-03 | NOT EXECUTED | Production package không có trên AVD hiện tại; không thể hash dữ liệu notebook trong app |

Audit độc lập cho LIFE-03 xác nhận `lib/`, root pubspec/lock, Android production
và bốn fixture gốc không đổi so với baseline. Example không import NoteStorage,
BflySerializer hoặc đường dẫn dữ liệu production. Không tuyên bố kiểm thử runtime
notebook/`.bfly` đã chạy; production regressions không chạy lại vì không sửa
shared code. Số test PASS lịch sử trong báo cáo cũ được giữ nguyên như lịch sử.

## Phân loại bằng chứng

| Phân loại | Phạm vi |
| --- | --- |
| FUNCTIONALLY VERIFIED | PDF native, 4 trang/6 slide/scan, điều hướng/thumbnail, transform, giới hạn cache/close/error, live in-memory ink, history, Split Study, physical display rotation, background/resume |
| VISUALLY DEMONSTRATED ONLY | Thẩm mỹ Atelier, đọc bảng/sơ đồ bằng mắt, bố cục panel và màu mực; không phải đánh giá người dùng trên tablet 8.8 inch vật lý |
| FAILED / NOT IMPLEMENTED | Không có FAIL còn lại trong các test đã chạy; LIFE-03 runtime NOT EXECUTED. Bút vật lý, stress dài hạn, production integration, lưu annotation, export PDF, native PPTX engine không triển khai |

Các lỗi đã gặp được ghi nhận, không đổi assertion để cho qua: asset ngoài app
không vào APK; lỗi render cũ làm báo lỗi nhầm; lỗi asset đồng bộ không bị catch;
nút Split đặt sai vùng; kết thúc nét giữa build gây setState exception. Các đường
này đã sửa trong example và có regression tương ứng. Portrait từng thất bại vì
AVD `ignoreOrientationRequest=true`; tạm tắt chính sách để kiểm tra display thật,
giữ nguyên assertion độ rộng, sau đó khôi phục thiết lập AVD.

## Đo hiệu năng, bộ nhớ và kích thước

Các số chính xác và thời điểm của run cuối nằm ở `measurements.json` và
`acceptance-trace.json`; không phải benchmark thiết bị vật lý. Trace render trước
khi chuyển surface để chụp ảnh được tách khỏi trace screenshot vì capture làm
tăng chi phí frame. Open gồm asset/metadata, transition gồm render/PNG/decode.
Cache 24MiB là ngân sách bitmap giữ lại, **không phải** tổng RAM process: còn
native bitmap đang render, PNG truyền qua channel, decode, GPU và Flutter VM.
Normal-app `dumpsys meminfo` sau resume chỉ là một sample, không phải peak.

| Số đo | Giá trị quan sát |
| --- | --- |
| Open đầu tiên / các open tiếp theo | 1351.843ms / 45.581–131.801ms |
| Native render + PNG encode | 74.4521–569.3485ms |
| Render/channel/decode transition | 135.463–712.767ms |
| Raster quan sát | 1000×1413, 1682×2377, 2304×1296 |
| Cache lớn nhất tại các snapshot | 23,887,872 byte, 2 entries; budget 25,165,824 byte |
| Ghi chú rộng nhỏ nhất trong split | 492.8dp; 50:50 là 616dp mỗi pane, divider 48dp |
| RAM sau resume, sample debug | PSS 266,053KiB; RSS 391,252KiB |
| Scaffold / POC APK debug | 150,511,196 / 180,151,516 byte |
| Delta toàn bộ experiment | 29,640,320 byte; không phải delta backend riêng |

Raster bị chặn ở 4MP, width request tối đa 2304; zoom sâu có thể mềm chữ do
upscale. Không preload PDF ở độ phân giải đầy đủ. Thumbnail chỉ render item
đang xây dựng ở width 128, Flutter image cache 8 entries/2MiB.
Lịch sử mực và trace trong phiên chưa có giới hạn dài hạn; cần đo stress riêng.
Emulator/debug có skipped frames; không tuyên bố 60fps hay độ trễ bút tốt.

So với scaffold, APK debug tăng do **toàn bộ** experiment: Dart UI/localization,
test plugin và fixture. Không thể gán toàn bộ delta cho backend. ZIP xác nhận
không thêm `.so` PDF engine, các `.so` chung trùng byte, không có Document Lab
PNG trong example. Bridge Kotlin vẫn có chi phí DEX chưa đo riêng. Root asset
PNG lịch sử còn 2,600,751 byte trong APK cũ; không thêm asset POC vào production.

## Chuyển PPTX thực

PowerPoint 16.0 mở PPTX gốc read-only, `SaveAs(...,32)` ra một PDF riêng
`lecture_slides_network_security_converted.pdf`: 582,640 byte, sáu trang
960 × 540pt. Bốn fixture gốc không thay đổi. Converter script dùng đường dẫn
Windows đúng; các lần COM binding/path thất bại trước đó không được tính PASS.
API đối chiếu: [Presentation.SaveAs](https://learn.microsoft.com/en-us/office/vba/api/powerpoint.presentation.saveas)
và [ppSaveAsPDF = 32](https://learn.microsoft.com/en-us/office/vba/api/powerpoint.ppsaveasfiletype).

`conversion-trace.json` kiểm tra 108 đoạn/cell text, không thiếu mục nào; hai bảng
còn đầy đủ. Theme Calibri được embed thành Calibri/Calibri-Bold, mã nguồn dùng
CourierNewPSMT. Đã xem contact sheet cả sáu trang: khối sơ đồ mạng, bảng, ô nội
dung và code còn nguyên, không thấy clipping rõ ràng. Không thấy font bị thay
trong phạm vi font đã kiểm tra; đây không phải kiểm tra mọi font/PPTX khác.
PDF slide cũ sinh độc lập có typography khác; không dùng nó làm ground truth
pixel cho conversion. Một ký hiệu toán trong PDF A4 gốc đã thành ô vuông cả
khi render bằng pymupdf; không sửa fixture nguồn hay quy lỗi đó cho viewport.

## Tái lập và đề nghị production

README example cung cấp lệnh prepare/analyze/test/drive/build. Traces:
`acceptance-trace.json`, `lifecycle-trace.json`, `conversion-trace.json`,
`measurements.json`, `rendering-trace.json` tại `artifacts/pdf-functional-poc/`. 12 PNG native đã tối ưu
lossless, giữ kích thước 2560×1600 và 1600×2560; không thêm vào runtime assets.
`PDF_FUNCTIONAL_POC_CONTACT_SHEET.png` là overview từ đúng các capture đó.

Giữ POC tách biệt. Chỉ xem xét tích hợp sau khi có chấp thuận mới, kiểm thử bút
vật lý/compact tablet, dữ liệu production thật, profile/release memory/latency,
khả năng hỗ trợ Android khác và bảo vệ khi nhận PDF không tin cậy. Backend hiện
chỉ xử lý fixture tin cậy trong process app; chưa xây sandbox PDF. Không lưu mực
qua restart, không export hay migration, không merge main.
