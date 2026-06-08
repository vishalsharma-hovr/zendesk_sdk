import 'dart:developer';

import 'package:flutter/material.dart';
import 'zendesk_controller.dart';

const _logTag = 'zendeskSdkFlutter';

class ZendeskDemoPage extends StatefulWidget {
  const ZendeskDemoPage({super.key, required this.controller});

  final ZendeskController controller;

  @override
  State<ZendeskDemoPage> createState() => _ZendeskDemoPageState();
}

class _ZendeskDemoPageState extends State<ZendeskDemoPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  Future<void> _initialize() async {
    await widget.controller.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _runAction(
    Future<void> Function() action, {
    String? successMessage,
    String failurePrefix = 'Action failed',
  }) async {
    try {
      await action();
      if (!mounted) return;
      if (successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage)),
        );
      }
    } catch (error, stackTrace) {
      log(name: _logTag, failurePrefix, error: error, stackTrace: stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$failurePrefix: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Scaffold(
      appBar: AppBar(title: const Text('Zendesk SDK Plugin Example')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (controller.initError != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                controller.initError!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          ElevatedButton(
            onPressed: () => _runAction(controller.openHelpCenter),
            child: const Text('Open Zendesk Help Center'),
          ),
          ElevatedButton(
            onPressed: () => _runAction(
              controller.openTicketForm,
              failurePrefix: 'Failed to open ticket form',
            ),
            child: const Text('Send User Information'),
          ),
          ElevatedButton(
            onPressed: () => _runAction(
              controller.openTicketList,
              failurePrefix: 'Failed to open ticket list',
            ),
            child: const Text('Show list of Tickets'),
          ),
          ElevatedButton(
            onPressed: () => _runAction(
              controller.startChat,
              failurePrefix: 'Failed to start chat',
            ),
            child: const Text('Start chat'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final count = await controller.unreadCount();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Unread messages: $count')),
                );
              } catch (error) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Unread count failed: $error')),
                );
              }
            },
            child: const Text('Get unread count'),
          ),
          ElevatedButton(
            onPressed: () => _runAction(
              controller.logout,
              successMessage: 'Zendesk session cleared',
              failurePrefix: 'Logout failed',
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
