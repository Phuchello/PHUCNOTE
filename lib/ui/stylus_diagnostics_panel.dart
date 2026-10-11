import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../diagnostics/stylus_diagnostics.dart';
import '../l10n/l10n.dart';

class StylusDiagnosticsPanel extends StatefulWidget {
  const StylusDiagnosticsPanel({super.key});

  @override
  State<StylusDiagnosticsPanel> createState() => _StylusDiagnosticsPanelState();
}

class _StylusDiagnosticsPanelState extends State<StylusDiagnosticsPanel> {
  final diagnostics = StylusDiagnostics.instance;
  String? message;
  bool busy = false;

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      busy = true;
      message = null;
    });
    try {
      await action();
    } catch (_) {
      if (mounted) {
        setState(() => message = context.l10n.diagnosticsFailed);
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final report = diagnostics.report;
    return AlertDialog(
      title: Text(context.l10n.stylusDiagnostics),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(context.l10n.diagnosticsInstructions),
              const SizedBox(height: 12),
              Text(
                diagnostics.recording
                    ? context.l10n.diagnosticsRecording
                    : context.l10n.diagnosticsStopped,
              ),
              Text(context.l10n.diagnosticsCaveat),
              if (diagnostics.hasCapture) ...[
                const SizedBox(height: 12),
                Text(
                  context.l10n.diagnosticsModel(
                    diagnostics.model,
                    diagnostics.androidRelease,
                  ),
                ),
                Text(context.l10n.diagnosticsRefresh(diagnostics.refreshHz)),
                Text(
                  context.l10n.diagnosticsEvents(
                    diagnostics.eventCount,
                    diagnostics.cancellations,
                    diagnostics.historyCount,
                  ),
                ),
                Text(context.l10n.diagnosticsFrames(diagnostics.frameSummary)),
                Text(
                  context.l10n.diagnosticsDropped(diagnostics.droppedSamples),
                ),
              ],
              if (message != null) ...[
                const SizedBox(height: 12),
                SelectableText(message!),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: busy ? null : () => Navigator.pop(context),
          child: Text(context.l10n.close),
        ),
        if (diagnostics.recording)
          TextButton(
            onPressed: busy
                ? null
                : () => _run(() async {
                    await diagnostics.stop();
                  }),
            child: Text(context.l10n.diagnosticsStop),
          ),
        if (!diagnostics.recording)
          FilledButton(
            onPressed: busy
                ? null
                : () => _run(() async {
                    await diagnostics.start();
                    if (context.mounted) Navigator.pop(context);
                  }),
            child: Text(context.l10n.diagnosticsStart),
          ),
        if (report != null || diagnostics.recording)
          TextButton(
            onPressed: busy
                ? null
                : () => _run(() async {
                    final file = await diagnostics.export();
                    await Clipboard.setData(ClipboardData(text: file.path));
                    if (mounted) {
                      setState(
                        () =>
                            message = context.l10n.diagnosticsSaved(file.path),
                      );
                    }
                  }),
            child: Text(context.l10n.diagnosticsExport),
          ),
      ],
    );
  }
}
