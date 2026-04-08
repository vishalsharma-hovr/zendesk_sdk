import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zendesk_sdk/zendesk_sdk.dart';

const TAG = "ZENDESK_SDK_FLUTTER";
void main() {
  runApp(MaterialApp(home: const MyApp()));
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
      await _zendeskSdkPlugin.initialize(url: 'zendesk_url', appId: 'app_id', clientId: 'client_id', name: "John Doe", emailId: "abc@mail.com", userId: "abc123", userType: "userType");
    } on PlatformException catch (error, stacktrace) {
      debugPrint('Zendesk init error: ${error.message}');
      log(name: TAG, "Error Initializing the zendesk SDK :", error: error, stackTrace: stacktrace);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Zendesk SDK Plugin Example')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () async {
              try {
                await _zendeskSdkPlugin.showHelpCenter(
                  name: "Testing User",
                  userId: "UserId",
                  emailId: "Email Id",
                  /* Add the category id as per your dashboard*/
                  categoryIdList: [], // Category Id's
                );
              } catch (e) {
                debugPrint('Zendesk init error: $e');
                // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to open Help Center: $e')));
              }
            },
            child: const Text("Open Zendesk Help Center"),
          ),

          ElevatedButton(
            onPressed: () async {
              try {
                await _zendeskSdkPlugin.sendUserInformationForTicket(name: "Testing User", emailId: "EmailId", tripId: "tripId", userId: "userId");
              } catch (error, stacktrace) {
                log(name: TAG, "Error Sending User Information in zendesk SDK :", error: error, stackTrace: stacktrace);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to open Help Center: $error')));
              }
            },
            child: const Text("Send User Information"),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _zendeskSdkPlugin.showListOfTickets(name: "Testing User", emailId: "EmailId", tripId: "tripId", userId: "userId");
              } catch (error, stacktrace) {
                log(name: TAG, "Error Showing the list of tickets in zendesk SDK :", error: error, stackTrace: stacktrace);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to open Help Center: $error')));
              }
            },
            child: Text("Show list of Tickets"),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _zendeskSdkPlugin.startChat(channelId: "<your_channel_key>");
              } catch (error, stacktrace) {
                log(name: TAG, "Error starting chat in zendesk SDK :", error: error, stackTrace: stacktrace);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to open Help Center: $error')));
              }
            },
            child: Text("Start chat"),
          ),
        ],
      ),
    );
  }
}
