import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:event_manager/core/di/injection.dart';
import 'package:event_manager/core/extensions/context_extensions.dart';
import 'package:event_manager/features/unibuddy/data/unibuddy_api.dart';
import 'package:flutter/material.dart';

@RoutePage(name: 'UniBuddyRoute')
class UniBuddyChatPage extends StatefulWidget {
  const UniBuddyChatPage({super.key});

  @override
  State<UniBuddyChatPage> createState() => _UniBuddyChatPageState();
}

class _ChatMessage {
  _ChatMessage({required this.text, required this.isUser});

  final String text;
  final bool isUser;
}

class _UniBuddyChatPageState extends State<UniBuddyChatPage> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _api = getIt<UniBuddyApi>();
  final _messages = <_ChatMessage>[];
  bool _loading = false;
  bool _isWakingUp = false;
  Timer? _wakeupTimer;

  @override
  void dispose() {
    _wakeupTimer?.cancel();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final q = _input.text.trim();
    if (q.isEmpty || _loading) return;

    setState(() {
      _messages.add(_ChatMessage(text: q, isUser: true));
      _loading = true;
      _isWakingUp = false;
    });
    _input.clear();
    _scrollDown();

    _wakeupTimer?.cancel();
    _wakeupTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && _loading) {
        setState(() => _isWakingUp = true);
        _scrollDown();
      }
    });

    try {
      final res = await _api.ask(q);
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(text: res.answer, isUser: false));
        _loading = false;
        _isWakingUp = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatMessage(
            text: _api.humanMessage(e),
            isUser: false,
          ),
        );
        _loading = false;
        _isWakingUp = false;
      });
    }
    _wakeupTimer?.cancel();
    _scrollDown();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(context.localization.unibuddyTitle),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              children: [
                Expanded(
                  child: _messages.isEmpty && !_loading
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              context.localization.unibuddyEmptyHint,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _scroll,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          itemCount: _messages.length + (_loading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (_loading && index == _messages.length) {
                              return Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      width: 28,
                                      height: 28,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                    if (_isWakingUp) ...[
                                      const SizedBox(height: 12),
                                      Text(
                                        'UniBuddy просыпается (до 2 минут)...',
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ]
                                  ],
                                ),
                              );
                            }
                            final m = _messages[index];
                            return Align(
                              alignment: m.isUser
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.sizeOf(context).width * 0.85,
                                ),
                                decoration: BoxDecoration(
                                  color: m.isUser
                                      ? Theme.of(context).colorScheme.primaryContainer
                                      : Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: SelectableText(
                                  m.text,
                                  style: TextStyle(
                                    color: m.isUser
                                        ? Theme.of(context).colorScheme.onPrimaryContainer
                                        : Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(8, 4, 8, 8 + bottomInset),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _input,
                          minLines: 1,
                          maxLines: 4,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _send(),
                          decoration: InputDecoration(
                            hintText: context.localization.unibuddyInputHint,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton.filled(
                        onPressed: _loading ? null : _send,
                        icon: const Icon(Icons.send_rounded),
                      ),
                    ],
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
