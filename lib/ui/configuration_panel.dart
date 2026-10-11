import 'package:flutter/material.dart';

/// Shared configuration surface for existing pen controls and future panels.
class ConfigurationPanel extends StatelessWidget {
  final String title;
  final String closeTooltip;
  final Widget content;
  final List<Widget> actions;
  const ConfigurationPanel({
    super.key,
    required this.title,
    required this.closeTooltip,
    required this.content,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) => Dialog(
    insetPadding: const EdgeInsets.all(16),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: closeTooltip,
                  constraints: const BoxConstraints.tightFor(
                    width: 48,
                    height: 48,
                  ),
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Flexible(child: SingleChildScrollView(child: content)),
            const SizedBox(height: 12),
            Wrap(alignment: WrapAlignment.end, spacing: 8, children: actions),
          ],
        ),
      ),
    ),
  );
}
