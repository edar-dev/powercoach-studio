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
      ),
      body: Column(
        children: [
          Expanded(child: _buildBody(context, theme, colorScheme, l10n)),
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
                      border: const OutlineInputBorder(),
                    ),
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
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        itemCount: _messages.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final message = _messages[index];
          final timestamp =
              DateFormat.yMMMd(locale).add_jm().format(message.createdAt);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.body,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                timestamp,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
