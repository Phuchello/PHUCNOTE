# Kiểm chứng tọa độ PDF và mực trong phiên

Baseline: `1087b5ebf9dd51128fe5da98a9375229938a8550`, Android 15
`medium_tablet`, Flutter 3.47.7 / Dart 3.13.5. Mã chỉ nằm trong ứng dụng mẫu.

## Hệ tọa độ duy nhất

`PageViewport` dùng kích thước trang do Android `PdfRenderer.Page` trả về.
API này trả số nguyên: PDF A4 mẫu là 595 × 841, slide là 960 × 540.
MediaBox gốc A4 có số lẻ 595.3 × 841.9pt; POC không tuyên bố tọa độ xuất PDF
chính xác tới phần lẻ đó. Không có xuất PDF hay lưu `.bfly` ở checkpoint này.

Với `p` là tọa độ trang, `s` là tọa độ Flutter local logical pixel:

```
s = p * scale + offset
p = (s - offset) / scale
physicalPixel = s * devicePixelRatio
```

PointerEvent.localPosition đã là logical pixel; không chia DPR lần nữa.
Chỉ yêu cầu độ phân giải raster mới nhân DPR. Bitmap và StrokeGeometry cùng
dùng một transform; vùng letterbox nằm ngoài pageBounds không nhận nét mới.
Mực không chứa vị trí global screen hay offset của toolbar.

Vừa trang lấy tỷ lệ nhỏ nhất theo hai chiều, trừ lề 16dp mỗi phía.
Vừa chiều rộng lấy `(viewport.width - 32) / page.width`, đặt cạnh trên tại 16dp.
Zoom neo tọa độ trang dưới focal point; pan thay offset. Khi Android xoay thật
hoặc tỷ lệ Split Study thay đổi, viewport fit lại theo kích thước mới; điểm mực
không đổi. Không xoay hoặc reflow nội dung nguồn.

## Quyền sở hữu nét đang hoạt động

Pointer-down chụp sheet, style, scale và offset. Nét bắt đầu ngoài trang bị từ
chối. Điểm đi ra ngoài được chặn vào biên trang, giữ phần đã nhận. Pointer-up
hoặc cancel kết thúc một thao tác có thể undo. Đổi trang/kích thước kết thúc
phần nét đã nhận trên sheet cũ; sự kiện đến muộn không ghi sang trang mới.
Tẩy trong một gesture lưu snapshot trước đó, giữ nguyên thứ tự stroke.
Đóng màn hình kết thúc gesture trước khi dispose controller; không ghi đĩa.

## Kiểm thử đã chạy

| Kiểm thử | Bằng chứng và giới hạn |
| --- | --- |
| `test/viewport_test.dart` | Fit A4/16:9 khác nhau; inverse sau zoom/pan và đổi hướng; mô hình DPR 1, 2, 3 có sai số < 1e-10 |
| `test/ink_test.dart` | Ba adapter trùng byte với production; biên trang, tẩy nhiều nét, ba chu kỳ undo/redo giữ JSON và thứ tự chính xác |
| `test/session_race_test.dart` | Coalesce render đang chờ; lỗi render cũ không ảnh hưởng tài liệu mới; asset thiếu trả lỗi tiếng Việt và đóng handle |
| `integration_test/ink_test.dart` | Sự kiện stylus đi qua listener thật: viết trang 2, zoom 200%/pan, trang 3 trống, quay lại còn nét; tẩy không đổi raster nguồn; undo/redo đúng JSON |
| Cùng kịch bản Android | Đổi trang khi stylus còn chạm giữ nét trên sheet cũ; unmount khi nét còn hoạt động không gây lỗi framework |
| `integration_test/evidence_test.dart` | Tọa độ mực giữ nguyên khi zoom 150%/pan; pan từng pane độc lập; các tỷ lệ 40:60/50:50/60:40 và xoay màn hình thật |

Ảnh 05/06 chứng minh lớp mực được vẽ từ sự kiện kiểm thử, không phải overlay
có sẵn. Assertion kiểm tra tọa độ/JSON độc lập với ảnh. Stylus trên đây là
PointerDeviceKind.stylus do Flutter test dispatch; độ trễ, lực bút, palm rejection
và cảm giác viết trên bút vật lý **NOT EXECUTED**. Android emulator chạy DPR 2;
DPR 1/3 được kiểm tra toán học, không phải các thiết bị Android bổ sung.

Trace: `artifacts/pdf-functional-poc/acceptance-trace.json`.
Hướng dẫn tái lập: `examples/pdf_functional_poc/README.md`.
