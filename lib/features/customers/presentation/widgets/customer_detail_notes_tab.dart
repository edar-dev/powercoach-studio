import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/remote/cloud_save_error_message.dart';
import '../../../../core/theme/marketing_dark_colors.dart';
import '../../../../core/ui/widgets/app_snackbar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/customer_notes_repository.dart';
import '../../domain/models/client_note_message.dart';

/// Embedded notes thread for the customer detail Notes tab.
class CustomerDetailNotesTab extends StatefulWidget {
  const CustomerDetailNotesTab({
    super.key,
    required this.customerId,
    this.onNotesChanged,
  });

  final String customerId;
  final VoidCallback? onNotesChanged;

  @override
  State<CustomerDetailNotesTab> createState() => _CustomerDetailNotesTabState();
}

class _CustomerDetailNotesTabState extends State<CustomerDetailNotesTab> {
  final CustomerNotesRepository _repository = CustomerNotesRepository();
  final TextEditingController _composerController = TextEditingController();

  List<ClientNoteMessage> _messages = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadThread(markRead: true);
  }

  @override
  void dispose() {
    _composerController.dispose();
    super.dispose();
  }

  Future<void> _loadThread({bool markRead = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (markRead) {
        await _repository.markThreadRead(widget.customerId);
      }
      final messages = await _repository.listNotes(widget.customerId);
      if (!mounted) return;
      setState(() {
        _messages = messages;
        _loading = false;
      });
      widget.onNotesChanged?.call();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'load';
      });
    }
  }

  Future<void> _addNote() async {
    final l10n = AppLocalizations.of(context);
    final body = _composerController.text;
    try {
      ClientNoteMessage.validateBody(body);
    } on ArgumentError {
      showAppSnackBar(
        context,
        content: Text(l10n.customerNotesEmptyBody),
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
      );
      return;
    }

    try {
      await _repository.addNote(widget.customerId, body);
      await _repository.markThreadRead(widget.customerId);
      _composerController.clear();
      await _loadThread();
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        content: Text(
          tryCloudSaveErrorMessage(e, l10n) ?? l10n.customerNotesSendError,
        ),
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      children: [
        Expanded(child: _buildBody(theme, l10n)),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _composerController,
                  minLines: 2,
                  maxLines: 4,
                  maxLength: ClientNoteMessage.maxBodyLength,
                  decoration: InputDecoration(
                    hintText: l10n.customerNotesHint,
                    counterText: '',
                    filled: true,
                    fillColor: MarketingDarkColors.surfaceElevated,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: MarketingDarkColors.borderMuted,
                      ),
                    ),
                  ),
                  style: const TextStyle(color: MarketingDarkColors.text),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _addNote(),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: _addNote,
                  child: Text(l10n.customerNotesSend),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(ThemeData theme, AppLocalizations l10n) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.customerNotesLoadError,
                textAlign: TextAlign.center,
                style: const TextStyle(color: MarketingDarkColors.slate300),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => _loadThread(markRead: true),
                child: Text(l10n.customersRetry),
              ),
            ],
          ),
        ),
      );
    }
    if (_messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.customerNotesEmpty,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: MarketingDarkColors.slate400,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final locale = l10n.localeName;
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      itemCount: _messages.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final message = _messages[index];
        final timestamp =
            DateFormat.yMMMd(locale).add_jm().format(message.createdAt);
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: MarketingDarkColors.stitchCardElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: MarketingDarkColors.stitchBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.body,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: MarketingDarkColors.text,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                timestamp,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: MarketingDarkColors.slate500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
