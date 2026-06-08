import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zendesk_sdk/zendesk_sdk.dart';
import 'package:zendesk_sdk/zendesk_sdk_platform_interface.dart';
import 'package:zendesk_sdk_example/zendesk_controller.dart';
import 'package:zendesk_sdk_example/zendesk_demo_page.dart';
import 'package:zendesk_sdk_example/zendesk_env.dart';

class MockZendeskSdkPlatform implements ZendeskSdkPlatform {
  @override
  Future<void> initialize({
    required String url,
    required String appId,
    required String clientId,
    required String emailId,
    required String name,
    required String userId,
    required String userType,
  }) async {}

  @override
  Future<void> logout() async {}

  @override
  Future<bool> isInitialized() async => true;

  @override
  Future<void> showHelpCenter({
    required String name,
    required String emailId,
    required String userId,
    required List<int> categoryIdList,
  }) async {}

  @override
  Future<void> startChatBot() async {}

  @override
  Future<void> showHelpCenterArticleId({required String articleId}) async {}

  @override
  Future<void> showHelpCenterCategoryId({required String categoryId}) async {}

  @override
  Future<void> sendUserInformationForTicket({
    required String name,
    required String emailId,
    required String userId,
    required String tripId,
    List<ZendeskCustomField> customFields = const [],
  }) async {}

  @override
  Future<void> showListOfTickets({
    required String name,
    required String emailId,
    required String userId,
    required String tripId,
  }) async {}

  @override
  Future<void> startChat({required String channelId}) async {}

  @override
  Future<int> getUnreadMessageCount() async => 0;

  @override
  Future<void> updatePushNotificationToken({required String token}) async {}

  @override
  Future<bool> handlePushNotification({required Map<String, dynamic> data}) async => false;
}

void main() {
  testWidgets('renders Zendesk demo page', (WidgetTester tester) async {
    final controller = ZendeskController(
      service: ZendeskService.fromSdkPlatform(MockZendeskSdkPlatform()),
      env: ZendeskEnv(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ZendeskDemoPage(controller: controller),
      ),
    );

    expect(find.text('Zendesk SDK Plugin Example'), findsOneWidget);
    expect(find.text('Open Zendesk Help Center'), findsOneWidget);
    expect(find.text('Start chat'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);

    await tester.pump();
  });
}
