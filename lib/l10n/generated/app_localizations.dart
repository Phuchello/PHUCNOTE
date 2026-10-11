import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('vi')];

  /// No description provided for @appName.
  ///
  /// In vi, this message translates to:
  /// **'PHUCNOTE'**
  String get appName;

  /// No description provided for @untitledNote.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú mới'**
  String get untitledNote;

  /// No description provided for @pen.
  ///
  /// In vi, this message translates to:
  /// **'Bút viết'**
  String get pen;

  /// No description provided for @highlighter.
  ///
  /// In vi, this message translates to:
  /// **'Bút đánh dấu'**
  String get highlighter;

  /// No description provided for @eraser.
  ///
  /// In vi, this message translates to:
  /// **'Tẩy nét'**
  String get eraser;

  /// No description provided for @undo.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn tác'**
  String get undo;

  /// No description provided for @redo.
  ///
  /// In vi, this message translates to:
  /// **'Làm lại'**
  String get redo;

  /// No description provided for @save.
  ///
  /// In vi, this message translates to:
  /// **'Lưu'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In vi, this message translates to:
  /// **'Hủy'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In vi, this message translates to:
  /// **'Đóng'**
  String get close;

  /// No description provided for @newNote.
  ///
  /// In vi, this message translates to:
  /// **'Tạo ghi chú'**
  String get newNote;

  /// No description provided for @openNotes.
  ///
  /// In vi, this message translates to:
  /// **'Mở ghi chú'**
  String get openNotes;

  /// No description provided for @createNote.
  ///
  /// In vi, this message translates to:
  /// **'Tạo ghi chú mới'**
  String get createNote;

  /// No description provided for @create.
  ///
  /// In vi, this message translates to:
  /// **'Tạo'**
  String get create;

  /// No description provided for @noteTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tên ghi chú'**
  String get noteTitle;

  /// No description provided for @renameNote.
  ///
  /// In vi, this message translates to:
  /// **'Đổi tên ghi chú'**
  String get renameNote;

  /// No description provided for @rename.
  ///
  /// In vi, this message translates to:
  /// **'Đổi tên'**
  String get rename;

  /// No description provided for @renameHint.
  ///
  /// In vi, this message translates to:
  /// **'Chạm để đổi tên ghi chú'**
  String get renameHint;

  /// No description provided for @drawingOptions.
  ///
  /// In vi, this message translates to:
  /// **'Công cụ khác'**
  String get drawingOptions;

  /// No description provided for @inkColor.
  ///
  /// In vi, this message translates to:
  /// **'Màu mực'**
  String get inkColor;

  /// No description provided for @colorBlack.
  ///
  /// In vi, this message translates to:
  /// **'Đen'**
  String get colorBlack;

  /// No description provided for @colorBlue.
  ///
  /// In vi, this message translates to:
  /// **'Xanh dương'**
  String get colorBlue;

  /// No description provided for @colorRed.
  ///
  /// In vi, this message translates to:
  /// **'Đỏ'**
  String get colorRed;

  /// No description provided for @colorGreen.
  ///
  /// In vi, this message translates to:
  /// **'Xanh lá'**
  String get colorGreen;

  /// No description provided for @colorOrange.
  ///
  /// In vi, this message translates to:
  /// **'Cam'**
  String get colorOrange;

  /// No description provided for @colorPurple.
  ///
  /// In vi, this message translates to:
  /// **'Tím'**
  String get colorPurple;

  /// No description provided for @widthFine.
  ///
  /// In vi, this message translates to:
  /// **'Nét mảnh'**
  String get widthFine;

  /// No description provided for @widthNormal.
  ///
  /// In vi, this message translates to:
  /// **'Nét vừa'**
  String get widthNormal;

  /// No description provided for @widthBold.
  ///
  /// In vi, this message translates to:
  /// **'Nét đậm'**
  String get widthBold;

  /// No description provided for @paperTemplate.
  ///
  /// In vi, this message translates to:
  /// **'Mẫu giấy'**
  String get paperTemplate;

  /// No description provided for @paperRuled.
  ///
  /// In vi, this message translates to:
  /// **'Giấy kẻ dòng'**
  String get paperRuled;

  /// No description provided for @paperGrid.
  ///
  /// In vi, this message translates to:
  /// **'Giấy ô vuông'**
  String get paperGrid;

  /// No description provided for @paperBlank.
  ///
  /// In vi, this message translates to:
  /// **'Giấy trắng'**
  String get paperBlank;

  /// No description provided for @stylusOnly.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ viết bằng bút cảm ứng'**
  String get stylusOnly;

  /// No description provided for @stylusOnlyActive.
  ///
  /// In vi, this message translates to:
  /// **'Đang dùng bút cảm ứng; dùng ngón tay để di chuyển giấy'**
  String get stylusOnlyActive;

  /// No description provided for @fingerInkingAllowed.
  ///
  /// In vi, this message translates to:
  /// **'Có thể viết bằng ngón tay; chạm để chỉ dùng bút cảm ứng'**
  String get fingerInkingAllowed;

  /// No description provided for @a4Mode.
  ///
  /// In vi, this message translates to:
  /// **'Viết trên giấy A4'**
  String get a4Mode;

  /// No description provided for @a4Badge.
  ///
  /// In vi, this message translates to:
  /// **'A4'**
  String get a4Badge;

  /// No description provided for @continuousPaperHint.
  ///
  /// In vi, this message translates to:
  /// **'Giấy liên tục — chạm để bật viết trên giấy A4'**
  String get continuousPaperHint;

  /// No description provided for @a4WritingHint.
  ///
  /// In vi, this message translates to:
  /// **'Đang viết trên giấy A4 — chạm để tắt\nBắt đầu trong trang; nét có thể đi qua mép trang.'**
  String get a4WritingHint;

  /// No description provided for @fitToWidth.
  ///
  /// In vi, this message translates to:
  /// **'Vừa chiều rộng'**
  String get fitToWidth;

  /// No description provided for @resetView.
  ///
  /// In vi, this message translates to:
  /// **'Đặt lại góc nhìn'**
  String get resetView;

  /// No description provided for @resetViewAt.
  ///
  /// In vi, this message translates to:
  /// **'Đặt lại góc nhìn ({percent}%)'**
  String resetViewAt(int percent);

  /// No description provided for @enterZen.
  ///
  /// In vi, this message translates to:
  /// **'Chế độ tập trung'**
  String get enterZen;

  /// No description provided for @exitZen.
  ///
  /// In vi, this message translates to:
  /// **'Thoát tập trung'**
  String get exitZen;

  /// No description provided for @clearCanvas.
  ///
  /// In vi, this message translates to:
  /// **'Xóa toàn bộ nét'**
  String get clearCanvas;

  /// No description provided for @clearCanvasBody.
  ///
  /// In vi, this message translates to:
  /// **'Xóa tất cả nét trên ghi chú này? Bạn có thể hoàn tác thao tác này.'**
  String get clearCanvasBody;

  /// No description provided for @clear.
  ///
  /// In vi, this message translates to:
  /// **'Xóa nét'**
  String get clear;

  /// No description provided for @unsavedTitle.
  ///
  /// In vi, this message translates to:
  /// **'Có thay đổi chưa lưu'**
  String get unsavedTitle;

  /// No description provided for @unsavedBody.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú “{title}” có thay đổi chưa lưu. Bạn muốn làm gì trước khi {action}?'**
  String unsavedBody(String title, String action);

  /// No description provided for @discardChanges.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ thay đổi'**
  String get discardChanges;

  /// No description provided for @saveAndProceed.
  ///
  /// In vi, this message translates to:
  /// **'Lưu và tiếp tục'**
  String get saveAndProceed;

  /// No description provided for @actionCreateNote.
  ///
  /// In vi, this message translates to:
  /// **'tạo ghi chú mới'**
  String get actionCreateNote;

  /// No description provided for @actionOpenNote.
  ///
  /// In vi, this message translates to:
  /// **'mở ghi chú khác'**
  String get actionOpenNote;

  /// No description provided for @actionExitApp.
  ///
  /// In vi, this message translates to:
  /// **'thoát ứng dụng'**
  String get actionExitApp;

  /// No description provided for @unsaved.
  ///
  /// In vi, this message translates to:
  /// **'Chưa lưu thay đổi'**
  String get unsaved;

  /// No description provided for @saved.
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu'**
  String get saved;

  /// No description provided for @saving.
  ///
  /// In vi, this message translates to:
  /// **'Đang lưu…'**
  String get saving;

  /// No description provided for @savedAt.
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu lúc {time}'**
  String savedAt(String time);

  /// No description provided for @savedTo.
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu: {filename}'**
  String savedTo(String filename);

  /// No description provided for @noteSaveFailed.
  ///
  /// In vi, this message translates to:
  /// **'Không thể lưu ghi chú. Thay đổi vẫn được giữ lại; hãy thử lưu lần nữa.'**
  String get noteSaveFailed;

  /// No description provided for @noteListFailed.
  ///
  /// In vi, this message translates to:
  /// **'Không thể mở danh sách ghi chú. Vui lòng thử lại.'**
  String get noteListFailed;

  /// No description provided for @noteLoadFailed.
  ///
  /// In vi, this message translates to:
  /// **'Không thể mở ghi chú này. Vui lòng kiểm tra tệp và thử lại.'**
  String get noteLoadFailed;

  /// No description provided for @noteDeleteFailed.
  ///
  /// In vi, this message translates to:
  /// **'Không thể xóa ghi chú. Vui lòng thử lại.'**
  String get noteDeleteFailed;

  /// No description provided for @createdNote.
  ///
  /// In vi, this message translates to:
  /// **'Đã tạo ghi chú “{title}”.'**
  String createdNote(String title);

  /// No description provided for @loadedNote.
  ///
  /// In vi, this message translates to:
  /// **'Đã mở ghi chú “{title}”.'**
  String loadedNote(String title);

  /// No description provided for @generatedNoteTitle.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú {date}'**
  String generatedNoteTitle(String date);

  /// No description provided for @savedNotes.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú đã lưu ({count})'**
  String savedNotes(int count);

  /// No description provided for @emptyNotes.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có ghi chú đã lưu. Hãy tạo một ghi chú và lưu lại.'**
  String get emptyNotes;

  /// No description provided for @noteModified.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật {date} · {size} kB'**
  String noteModified(String date, String size);

  /// No description provided for @deleteNote.
  ///
  /// In vi, this message translates to:
  /// **'Xóa ghi chú'**
  String get deleteNote;

  /// No description provided for @pageNumber.
  ///
  /// In vi, this message translates to:
  /// **'Trang {page}'**
  String pageNumber(int page);

  /// No description provided for @penStudio.
  ///
  /// In vi, this message translates to:
  /// **'Xưởng bút'**
  String get penStudio;

  /// No description provided for @penStudioTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xưởng bút PHUCNOTE'**
  String get penStudioTitle;

  /// No description provided for @closePenStudio.
  ///
  /// In vi, this message translates to:
  /// **'Đóng xưởng bút'**
  String get closePenStudio;

  /// No description provided for @ballpoint.
  ///
  /// In vi, this message translates to:
  /// **'Bút bi'**
  String get ballpoint;

  /// No description provided for @gelPen.
  ///
  /// In vi, this message translates to:
  /// **'Bút gel'**
  String get gelPen;

  /// No description provided for @fountainPen.
  ///
  /// In vi, this message translates to:
  /// **'Bút máy'**
  String get fountainPen;

  /// No description provided for @preset.
  ///
  /// In vi, this message translates to:
  /// **'Mẫu bút'**
  String get preset;

  /// No description provided for @presetCustomized.
  ///
  /// In vi, this message translates to:
  /// **'Mẫu bút · đã tùy chỉnh'**
  String get presetCustomized;

  /// No description provided for @currentPen.
  ///
  /// In vi, this message translates to:
  /// **'Bút hiện tại'**
  String get currentPen;

  /// No description provided for @fountainExplanation.
  ///
  /// In vi, this message translates to:
  /// **'Bút máy mô phỏng ngòi mềm bằng độ rộng theo lực nhấn; đầu nét vẫn là đầu tròn.'**
  String get fountainExplanation;

  /// No description provided for @width.
  ///
  /// In vi, this message translates to:
  /// **'Độ rộng nét'**
  String get width;

  /// No description provided for @opacity.
  ///
  /// In vi, this message translates to:
  /// **'Độ đậm mực'**
  String get opacity;

  /// No description provided for @thinning.
  ///
  /// In vi, this message translates to:
  /// **'Độ biến thiên'**
  String get thinning;

  /// No description provided for @smoothing.
  ///
  /// In vi, this message translates to:
  /// **'Độ mượt'**
  String get smoothing;

  /// No description provided for @streamline.
  ///
  /// In vi, this message translates to:
  /// **'Ổn định nét'**
  String get streamline;

  /// No description provided for @colorHex.
  ///
  /// In vi, this message translates to:
  /// **'Màu mực (mã RGB)'**
  String get colorHex;

  /// No description provided for @colorHexHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập 6 ký tự mã màu; màu hợp lệ được áp dụng ngay.'**
  String get colorHexHint;

  /// No description provided for @previewHint.
  ///
  /// In vi, this message translates to:
  /// **'Viết thử tại đây'**
  String get previewHint;

  /// No description provided for @previewSemantics.
  ///
  /// In vi, this message translates to:
  /// **'Vùng viết thử nét bút'**
  String get previewSemantics;

  /// No description provided for @resetPreview.
  ///
  /// In vi, this message translates to:
  /// **'Xóa nét viết thử'**
  String get resetPreview;

  /// No description provided for @resetPreset.
  ///
  /// In vi, this message translates to:
  /// **'Đặt lại mẫu'**
  String get resetPreset;

  /// No description provided for @savePersonal.
  ///
  /// In vi, this message translates to:
  /// **'Lưu mẫu riêng'**
  String get savePersonal;

  /// No description provided for @savePersonalTitle.
  ///
  /// In vi, this message translates to:
  /// **'Lưu mẫu bút riêng'**
  String get savePersonalTitle;

  /// No description provided for @presetName.
  ///
  /// In vi, this message translates to:
  /// **'Tên mẫu bút'**
  String get presetName;

  /// No description provided for @savePreset.
  ///
  /// In vi, this message translates to:
  /// **'Lưu mẫu'**
  String get savePreset;

  /// No description provided for @presetLoadFailed.
  ///
  /// In vi, this message translates to:
  /// **'Không thể tải mẫu bút riêng. Các thiết lập đã có vẫn được giữ nguyên.'**
  String get presetLoadFailed;

  /// No description provided for @presetSaveFailed.
  ///
  /// In vi, this message translates to:
  /// **'Không thể lưu mẫu bút. Vui lòng thử lại.'**
  String get presetSaveFailed;

  /// No description provided for @presetInvalid.
  ///
  /// In vi, this message translates to:
  /// **'Tên hoặc thông số mẫu bút không hợp lệ.'**
  String get presetInvalid;

  /// No description provided for @presetNameRequired.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập tên mẫu bút.'**
  String get presetNameRequired;

  /// No description provided for @presetNameExists.
  ///
  /// In vi, this message translates to:
  /// **'Tên mẫu bút đã được dùng. Vui lòng chọn tên khác.'**
  String get presetNameExists;

  /// No description provided for @presetNameTooLong.
  ///
  /// In vi, this message translates to:
  /// **'Tên mẫu bút không được dài quá 40 ký tự.'**
  String get presetNameTooLong;

  /// No description provided for @writingCanvas.
  ///
  /// In vi, this message translates to:
  /// **'Vùng viết ghi chú'**
  String get writingCanvas;

  /// No description provided for @noChanges.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có thay đổi'**
  String get noChanges;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
