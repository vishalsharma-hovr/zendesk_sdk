import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:zendesk_sdk/zendesk_sdk.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _zendeskSdkPlugin = ZendeskSdk();

  @override
  void initState() {
    super.initState();
    initZendesk();
  }

  Future<void> initZendesk() async {
    try {
      await _zendeskSdkPlugin.initialize(url: 'Your URL', appId: 'Your App Id', clientId: 'Your Client Id');
    } on PlatformException catch (e) {
      // Optional: show error toast/snack
      debugPrint('Zendesk init error: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Zendesk SDK Plugin Example')),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              try {
                await _zendeskSdkPlugin.showHelpCenter();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to open Help Center: $e')));
              }
            },
            child: const Text("Open Zendesk Help Center"),
          ),
        ),
      ),
    );
  }
}
