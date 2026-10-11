import 'package:flutter/material.dart';

import '../l10n/l10n.dart';

const inkPalette = <String, Color>{
  'Black': Color(0xFF1E1E1E),
  'Blue': Color(0xFF1565C0),
  'Red': Color(0xFFC62828),
  'Green': Color(0xFF2E7D32),
  'Orange': Color(0xFFEF6C00),
  'Purple': Color(0xFF6A1B9A),
};

String inkColorLabel(AppLocalizations l10n, String id) => switch (id) {
  'Black' => l10n.colorBlack,
  'Blue' => l10n.colorBlue,
  'Red' => l10n.colorRed,
  'Green' => l10n.colorGreen,
  'Orange' => l10n.colorOrange,
  _ => l10n.colorPurple,
};

class InkSwatch extends StatelessWidget {
  final Color color;
  final bool selected;
  const InkSwatch({super.key, required this.color, this.selected = false});

  @override
  Widget build(BuildContext context) => Container(
    width: 26,
    height: 26,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: selected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.outlineVariant,
        width: selected ? 2 : 1,
      ),
    ),
    padding: const EdgeInsets.all(3),
    child: DecoratedBox(
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    ),
  );
}
