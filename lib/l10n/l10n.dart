import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../core/models/pen_preset.dart';
import 'generated/app_localizations.dart';

export 'generated/app_localizations.dart';

extension VietnameseUi on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  String uiDateTime(DateTime value) =>
      DateFormat('dd/MM/yyyy HH:mm', 'vi_VN').format(value.toLocal());
  String uiTime(DateTime value) =>
      DateFormat.Hm('vi_VN').format(value.toLocal());
  String uiDecimal(num value, {int digits = 2}) =>
      NumberFormat.decimalPatternDigits(
        locale: 'vi_VN',
        decimalDigits: digits,
      ).format(value);

  String presetLabel(PenPreset preset) {
    final index = PenPreset.defaults.indexOf(preset);
    return switch (index) {
      0 => l10n.ballpoint,
      1 => l10n.gelPen,
      2 => l10n.fountainPen,
      _ => preset.name,
    };
  }
}
