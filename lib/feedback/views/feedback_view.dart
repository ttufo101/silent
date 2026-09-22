import 'package:fl_clash/auth/providers.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/feedback/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FeedbackView extends ConsumerStatefulWidget {
  const FeedbackView({super.key});

  @override
  ConsumerState<FeedbackView> createState() => _FeedbackViewState();
}

class _FeedbackViewState extends ConsumerState<FeedbackView> {
  final _contentController = TextEditingController();
  final _contactController = TextEditingController();
  var _category = 'issue';
  var _requestId = utils.uuidV4;
  var _submitting = false;
  String? _errorText;
  String? _submittedId;

  @override
  void initState() {
    super.initState();
    _contactController.text =
        ref.read(authControllerProvider).session?.email ?? '';
  }

  @override
  void dispose() {
    _contentController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      setState(() => _errorText = context.appLocalizations.feedbackContentRequired);
      return;
    }
    setState(() {
      _submitting = true;
      _errorText = null;
    });
    try {
      final result = await ref.read(feedbackServiceProvider).submitFeedback(
        category: _category,
        content: content,
        contact: _contactController.text.trim(),
        clientRequestId: _requestId,
      );
      if (!mounted) return;
      setState(() {
        _submittedId = result.id;
        _contentController.clear();
        _requestId = utils.uuidV4;
      });
    } on Object catch (error) {
      if (!mounted) return;
      commonPrint.log('Feedback submission failed: $error');
      setState(() => _errorText = context.appLocalizations.feedbackSubmitFailed);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.appLocalizations;
    return CommonScaffold(
      title: l10n.feedback,
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.feedbackType, style: context.textTheme.titleMedium),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                      value: 'issue',
                      label: Text(l10n.feedbackTypeIssue),
                      icon: const Icon(Icons.report_problem_outlined),
                    ),
                    ButtonSegment(
                      value: 'suggestion',
                      label: Text(l10n.feedbackTypeSuggestion),
                      icon: const Icon(Icons.lightbulb_outline),
                    ),
                    ButtonSegment(
                      value: 'other',
                      label: Text(l10n.feedbackTypeOther),
                      icon: const Icon(Icons.more_horiz),
                    ),
                  ],
                  selected: {_category},
                  onSelectionChanged: _submitting
                      ? null
                      : (value) => setState(() => _category = value.first),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _contentController,
                  enabled: !_submitting,
                  minLines: 6,
                  maxLines: 10,
                  inputFormatters: [LengthLimitingTextInputFormatter(2000)],
                  onChanged: (_) {
                    if (_errorText != null) setState(() => _errorText = null);
                  },
                  decoration: InputDecoration(
                    labelText: l10n.feedbackContent,
                    hintText: l10n.feedbackContentHint,
                    errorText: _errorText,
                    alignLabelWithHint: true,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _contactController,
                  enabled: !_submitting,
                  inputFormatters: [LengthLimitingTextInputFormatter(254)],
                  decoration: InputDecoration(
                    labelText: l10n.feedbackContact,
                    hintText: l10n.feedbackContactHint,
                    border: const OutlineInputBorder(),
                  ),
                ),
                if (_submittedId != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: context.colorScheme.primaryContainer,
                    child: ListTile(
                      leading: const Icon(Icons.check_circle_outline),
                      title: Text(l10n.feedbackSubmitted),
                      subtitle: Text(l10n.feedbackNumber(_submittedId!)),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _submitting ? null : _submit,
                  icon: _submitting
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_outlined),
                  label: Text(
                    _submitting ? l10n.submitting : l10n.submitFeedback,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
