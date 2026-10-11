// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'PHUCNOTE';

  @override
  String get untitledNote => 'Ghi chú mới';

  @override
  String get pen => 'Bút viết';

  @override
  String get highlighter => 'Bút đánh dấu';

  @override
  String get eraser => 'Tẩy nét';

  @override
  String get undo => 'Hoàn tác';

  @override
  String get redo => 'Làm lại';

  @override
  String get save => 'Lưu';

  @override
  String get cancel => 'Hủy';

  @override
  String get close => 'Đóng';

  @override
  String get newNote => 'Tạo ghi chú';

  @override
  String get openNotes => 'Mở ghi chú';

  @override
  String get createNote => 'Tạo ghi chú mới';

  @override
  String get create => 'Tạo';

  @override
  String get noteTitle => 'Tên ghi chú';

  @override
  String get renameNote => 'Đổi tên ghi chú';

  @override
  String get rename => 'Đổi tên';

  @override
  String get renameHint => 'Chạm để đổi tên ghi chú';

  @override
  String get drawingOptions => 'Công cụ khác';

  @override
  String get inkColor => 'Màu mực';

  @override
  String get colorBlack => 'Đen';

  @override
  String get colorBlue => 'Xanh dương';

  @override
  String get colorRed => 'Đỏ';

  @override
  String get colorGreen => 'Xanh lá';

  @override
  String get colorOrange => 'Cam';

  @override
  String get colorPurple => 'Tím';

  @override
  String get widthFine => 'Nét mảnh';

  @override
  String get widthNormal => 'Nét vừa';

  @override
  String get widthBold => 'Nét đậm';

  @override
  String get paperTemplate => 'Mẫu giấy';

  @override
  String get paperRuled => 'Giấy kẻ dòng';

  @override
  String get paperGrid => 'Giấy ô vuông';

  @override
  String get paperBlank => 'Giấy trắng';

  @override
  String get stylusOnly => 'Chỉ viết bằng bút cảm ứng';

  @override
  String get stylusOnlyActive =>
      'Đang dùng bút cảm ứng; dùng ngón tay để di chuyển giấy';

  @override
  String get fingerInkingAllowed =>
      'Có thể viết bằng ngón tay; chạm để chỉ dùng bút cảm ứng';

  @override
  String get a4Mode => 'Viết trên giấy A4';

  @override
  String get a4Badge => 'A4';

  @override
  String get continuousPaperHint =>
      'Giấy liên tục — chạm để bật viết trên giấy A4';

  @override
  String get a4WritingHint =>
      'Đang viết trên giấy A4 — chạm để tắt\nBắt đầu trong trang; nét có thể đi qua mép trang.';

  @override
  String get fitToWidth => 'Vừa chiều rộng';

  @override
  String get resetView => 'Đặt lại góc nhìn';

  @override
  String resetViewAt(int percent) {
    return 'Đặt lại góc nhìn ($percent%)';
  }

  @override
  String get enterZen => 'Chế độ tập trung';

  @override
  String get exitZen => 'Thoát tập trung';

  @override
  String get clearCanvas => 'Xóa toàn bộ nét';

  @override
  String get clearCanvasBody =>
      'Xóa tất cả nét trên ghi chú này? Bạn có thể hoàn tác thao tác này.';

  @override
  String get clear => 'Xóa nét';

  @override
  String get unsavedTitle => 'Có thay đổi chưa lưu';

  @override
  String unsavedBody(String title, String action) {
    return 'Ghi chú “$title” có thay đổi chưa lưu. Bạn muốn làm gì trước khi $action?';
  }

  @override
  String get discardChanges => 'Bỏ thay đổi';

  @override
  String get saveAndProceed => 'Lưu và tiếp tục';

  @override
  String get actionCreateNote => 'tạo ghi chú mới';

  @override
  String get actionOpenNote => 'mở ghi chú khác';

  @override
  String get actionExitApp => 'thoát ứng dụng';

  @override
  String get unsaved => 'Chưa lưu thay đổi';

  @override
  String get saved => 'Đã lưu';

  @override
  String get saving => 'Đang lưu…';

  @override
  String savedAt(String time) {
    return 'Đã lưu lúc $time';
  }

  @override
  String savedTo(String filename) {
    return 'Đã lưu: $filename';
  }

  @override
  String get noteSaveFailed =>
      'Không thể lưu ghi chú. Thay đổi vẫn được giữ lại; hãy thử lưu lần nữa.';

  @override
  String get noteListFailed =>
      'Không thể mở danh sách ghi chú. Vui lòng thử lại.';

  @override
  String get noteLoadFailed =>
      'Không thể mở ghi chú này. Vui lòng kiểm tra tệp và thử lại.';

  @override
  String get noteDeleteFailed => 'Không thể xóa ghi chú. Vui lòng thử lại.';

  @override
  String createdNote(String title) {
    return 'Đã tạo ghi chú “$title”.';
  }

  @override
  String loadedNote(String title) {
    return 'Đã mở ghi chú “$title”.';
  }

  @override
  String generatedNoteTitle(String date) {
    return 'Ghi chú $date';
  }

  @override
  String savedNotes(int count) {
    return 'Ghi chú đã lưu ($count)';
  }

  @override
  String get emptyNotes =>
      'Chưa có ghi chú đã lưu. Hãy tạo một ghi chú và lưu lại.';

  @override
  String noteModified(String date, String size) {
    return 'Cập nhật $date · $size kB';
  }

  @override
  String get deleteNote => 'Xóa ghi chú';

  @override
  String pageNumber(int page) {
    return 'Trang $page';
  }

  @override
  String get penStudio => 'Xưởng bút';

  @override
  String get penStudioTitle => 'Xưởng bút PHUCNOTE';

  @override
  String get closePenStudio => 'Đóng xưởng bút';

  @override
  String get ballpoint => 'Bút bi';

  @override
  String get gelPen => 'Bút gel';

  @override
  String get fountainPen => 'Bút máy';

  @override
  String get preset => 'Mẫu bút';

  @override
  String get presetCustomized => 'Mẫu bút · đã tùy chỉnh';

  @override
  String get currentPen => 'Bút hiện tại';

  @override
  String get fountainExplanation =>
      'Bút máy mô phỏng ngòi mềm bằng độ rộng theo lực nhấn; đầu nét vẫn là đầu tròn.';

  @override
  String get width => 'Độ rộng nét';

  @override
  String get opacity => 'Độ đậm mực';

  @override
  String get thinning => 'Độ biến thiên';

  @override
  String get smoothing => 'Độ mượt';

  @override
  String get streamline => 'Ổn định nét';

  @override
  String get colorHex => 'Màu mực (mã RGB)';

  @override
  String get colorHexHint =>
      'Nhập 6 ký tự mã màu; màu hợp lệ được áp dụng ngay.';

  @override
  String get previewHint => 'Viết thử tại đây';

  @override
  String get previewSemantics => 'Vùng viết thử nét bút';

  @override
  String get resetPreview => 'Xóa nét viết thử';

  @override
  String get resetPreset => 'Đặt lại mẫu';

  @override
  String get savePersonal => 'Lưu mẫu riêng';

  @override
  String get savePersonalTitle => 'Lưu mẫu bút riêng';

  @override
  String get presetName => 'Tên mẫu bút';

  @override
  String get savePreset => 'Lưu mẫu';

  @override
  String get presetLoadFailed =>
      'Không thể tải mẫu bút riêng. Các thiết lập đã có vẫn được giữ nguyên.';

  @override
  String get presetSaveFailed => 'Không thể lưu mẫu bút. Vui lòng thử lại.';

  @override
  String get presetInvalid => 'Tên hoặc thông số mẫu bút không hợp lệ.';

  @override
  String get presetNameRequired => 'Vui lòng nhập tên mẫu bút.';

  @override
  String get presetNameExists =>
      'Tên mẫu bút đã được dùng. Vui lòng chọn tên khác.';

  @override
  String get presetNameTooLong => 'Tên mẫu bút không được dài quá 40 ký tự.';

  @override
  String get writingCanvas => 'Vùng viết ghi chú';

  @override
  String get noChanges => 'Chưa có thay đổi';

  @override
  String get stylusDiagnostics => 'Chẩn đoán bút Y700';

  @override
  String get diagnosticsInstructions =>
      'Bắt đầu rồi viết trên trang hiện tại. Mở lại mục này để dừng và xuất JSON. Dữ liệu chỉ lưu cục bộ, không lưu vào ghi chú.';

  @override
  String get diagnosticsRecording => 'Đang đo — có thêm chi phí chẩn đoán.';

  @override
  String get diagnosticsStopped => 'Chưa đo hoặc đã dừng.';

  @override
  String get diagnosticsCaveat =>
      'Không suy ra chất lượng bút thật từ emulator. Không đồng nhất Hz màn hình với tần số lấy mẫu bút.';

  @override
  String get diagnosticsFailed =>
      'Không thể thu thập chẩn đoán. Vui lòng thử lại.';

  @override
  String get diagnosticsStart => 'Bắt đầu đo';

  @override
  String get diagnosticsStop => 'Dừng đo';

  @override
  String get diagnosticsExport => 'Xuất JSON';

  @override
  String diagnosticsModel(String model, String os) {
    return 'Máy: $model · Android $os';
  }

  @override
  String diagnosticsRefresh(String rate) {
    return 'Tần số hiện tại: $rate Hz';
  }

  @override
  String diagnosticsEvents(
    String events,
    String cancellations,
    String history,
  ) {
    return 'Sự kiện: $events · Hủy: $cancellations · Lịch sử: $history';
  }

  @override
  String diagnosticsFrames(String frames) {
    return 'Khung hình Flutter: $frames';
  }

  @override
  String diagnosticsDropped(String count) {
    return 'Mẫu bị bỏ do giới hạn: $count';
  }

  @override
  String diagnosticsSaved(String path) {
    return 'Đã lưu JSON. Đường dẫn đã sao chép:\n$path';
  }
}
