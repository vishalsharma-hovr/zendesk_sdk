import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:zendesk_sdk/zendesk_sdk.dart';

import 'zendesk_env.dart';

const TAG = 'ZENDESK_SDK_FLUTTER';

void main() {
  runApp(MaterialApp(home: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _zendeskSdkPlugin = ZendeskSdk.instance;
  final _zendeskEnv = ZendeskEnv();
  String? _initError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initZendesk();
    });
  }

  Future<void> initZendesk() async {
    try {
      await _zendeskEnv.load();

      await _zendeskSdkPlugin.initialize(
        url: _zendeskEnv.require(ZendeskEnv.keyUrl),
        appId: _zendeskEnv.require(ZendeskEnv.keyAppId),
        clientId: _zendeskEnv.require(ZendeskEnv.keyClientId),
        name: 'John Doe',
        emailId: 'abc@mail.com',
        userId: 'abc123',
        userType: 'RIDER',
      );

      if (mounted) {
        setState(() => _initError = null);
      }
    } on ZendeskSdkException catch (error, stacktrace) {
      debugPrint('Zendesk init error: ${error.message}');
      log(
        name: TAG,
        'Error initializing the Zendesk SDK',
        error: error,
        stackTrace: stacktrace,
      );
      if (mounted) {
        setState(() => _initError = error.message);
      }
    } catch (error, stacktrace) {
      debugPrint('Zendesk config error: $error');
      log(
        name: TAG,
        'Error loading Zendesk env file',
        error: error,
        stackTrace: stacktrace,
      );
      if (mounted) {
        setState(() => _initError = error.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Zendesk SDK Plugin Example')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_initError != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _initError!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _zendeskSdkPlugin.showHelpCenter(
                  name: 'Testing User',
                  userId: 'UserId',
                  emailId: 'Email Id',
                  categoryIdList: [],
                );
              } catch (e) {
                debugPrint('Zendesk help center error: $e');
              }
            },
            child: const Text('Open Zendesk Help Center'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _zendeskSdkPlugin.sendUserInformationForTicket(
                  name: 'Testing User',
                  emailId: 'EmailId',
                  tripId: 'tripId',
                  userId: 'userId',
                  customFields: const [
                    ZendeskCustomField(fieldId: 29516552016157, value: 'RIDER'),
                  ],
                );
              } catch (error, stacktrace) {
                log(
                  name: TAG,
                  'Error sending user information in Zendesk SDK',
                  error: error,
                  stackTrace: stacktrace,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to open ticket form: $error')),
                );
              }
            },
            child: const Text('Send User Information'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _zendeskSdkPlugin.showListOfTickets(
                  name: 'Testing User',
                  emailId: 'EmailId',
                  tripId: 'tripId',
                  userId: 'userId',
                );
              } catch (error, stacktrace) {
                log(
                  name: TAG,
                  'Error showing ticket list in Zendesk SDK',
                  error: error,
                  stackTrace: stacktrace,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to open ticket list: $error')),
                );
              }
            },
            child: const Text('Show list of Tickets'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _zendeskSdkPlugin.startChat(
                  channelId: _zendeskEnv.require(ZendeskEnv.keyChannelId),
                );
              } catch (error, stacktrace) {
                log(
                  name: TAG,
                  'Error starting chat in Zendesk SDK',
                  error: error,
                  stackTrace: stacktrace,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to start chat: $error')),
                );
              }
            },
            child: const Text('Start chat'),
          ),
        ],
      ),
    );
  }
}
