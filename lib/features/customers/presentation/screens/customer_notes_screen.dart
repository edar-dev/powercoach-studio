import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/ui/widgets/app_snackbar.dart';
import '../../data/customer_notes_repository.dart';
import '../../domain/models/client_note_message.dart';

class CustomerNotesScreen extends StatefulWidget {
  const CustomerNotesScreen({
    super.key,
    required this.customerId,
    this.customerName,
  });

  final String customerId;
  final String? customerName;

  @override
  State<CustomerNotesScreen> createState() => _CustomerNotesScreenState();
}

class _CustomerNotesScreenState extends State<CustomerNotesScreen> {
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
      if (!mounted) {
        return;
      }
      setState(() {
        _messages = messages;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = 'load';
      });
    }
  }

  Future<void> _send() async {
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
    } catch (_) {
      if (!mounted) {
        return;
      }
      showAppSnackBar(
        context,
        content: Text(l10n.customerNotesSendError),
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final title = widget.customerName?.trim().isNotEmpty == true
        ? l10n.customerNotesTitleFor(widget.customerName!.trim())
        : l10n.customerNotesTitle;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            tooltip: l10n.customerNotesAttachPhoto,
            onPressed: () {
              showAppSnackBar(context, content: Text(l10n.customerNotesAttachSoon));
            },
            icon: const Icon(Icons.attach_file),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildBody(context, theme, colorScheme, l10n)),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _composerController,
                      minLines: 1,
                      maxLines: 4,
                      maxLength: ClientNoteMessage.maxBodyLength,
                      decoration: InputDecoration(
                        hintText: l10n.customerNotesHint,
                        counterText: '',
                        border: const OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: l10n.customerNotesSend,
                    onPressed: _send,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
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
              Text(l10n.customerNotesLoadError, textAlign: TextAlign.center),
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
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final locale = l10n.localeName;
    return Semantics(
      label: l10n.customerNotesTitle,
      child: ListView.builder(
        reverse: true,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final message = _messages[_messages.length - 1 - index];
          final timestamp = DateFormat.yMMMd(locale).add_jm().format(message.createdAt);
          return Align(
            alignment: Alignment.centerRight,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              constraints: const BoxConstraints(maxWidth: 320),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.body,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    timestamp,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
