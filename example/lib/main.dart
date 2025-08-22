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
      await _zendeskSdkPlugin.initialize(
        url: 'https://ridehovr.zendesk.com',
        appId: 'ab4e000b41478e3acde9d01b5069bf6d168236d6b948886e',
        clientId: 'mobile_sdk_client_5134bbfe3fb5a795422b',
      );
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
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                try {
                  await _zendeskSdkPlugin.showHelpCenter(
                    name: "Testing User",
                    userId: "UserId",
                    emailId: "Email Id",
                    /* Add the category id as per your dashboard*/
                    categoryIdList: [1, 2, 3],
                  );
                } catch (e) {
                  debugPrint('Zendesk init error: $e');
                  // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to open Help Center: $e')));
                }
              },
              child: const Text("Open Zendesk Help Center"),
            ),

            // ElevatedButton(
            //   onPressed: () async {
            //     try {
            //       await _zendeskSdkPlugin.showHelpWithArticleId(articleId: "");
            //     } catch (e) {
            //       debugPrint('Zendesk init error: ${e}');
            //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to open Help Center: $e')));
            //     }
            //   },
            //   child: const Text("Open Zendesk Help Center with Article Id"),
            // ),
            // ElevatedButton(
            //   onPressed: () async {
            //     try {
            //       await _zendeskSdkPlugin.startChatBot();
            //     } catch (e) {
            //       debugPrint('Zendesk init error: ${e}');
            //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to open Help Center: $e')));
            //     }
            //   },
            //   child: const Text("Open Zendesk Bot"),
            // ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _zendeskSdkPlugin.sendUserInformationForTicket(
                    name: "Testing User",
                    emailId: "EmailId",
                    tripId: "tripId",
                    userId: "userId",
                  );
                } catch (e) {
                  debugPrint('Zendesk init error: ${e}');
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to open Help Center: $e')));
                }
              },
              child: const Text("Send User Information"),
            ),
          ],
        ),
      ),
    );
  }
}
