import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:zendesk_sdk/zendesk_sdk.dart';

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
      await _zendeskSdkPlugin.initialize(
        url: 'https://hovr-12795.zendesk.com',
        appId: '5628e5164bde398de10c972ed52877194795ea18aca2ebad',
        clientId: 'mobile_sdk_client_0209e7e309ead3916918',
        name: "Testing User",
        emailId: "Email Id",
      );
    } on PlatformException catch (e) {
      debugPrint('Zendesk init error: ${e.message}');
      rethrow;
      // Optional: show error toast/snack
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
              } catch (e) {
                debugPrint('Zendesk init error: ${e}');
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to open Help Center: $e')));
              }
            },
            child: const Text("Send User Information"),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _zendeskSdkPlugin.showListOfTickets();
              } catch (e) {
                debugPrint('Zendesk show list of tickets error: ${e}');
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to open Help Center: $e')));
              }
            },
            child: Text("Show list of Tickets"),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _zendeskSdkPlugin.startChat(emailId: "abc@mail.com", name: "test", phoneNumber: "1234567890");
              } catch (e) {
                debugPrint('Zendesk start chat error: ${e}');
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to open Help Center: $e')));
              }
            },
            child: Text("Start chat"),
          ),
        ],
      ),
    );
  }
}
