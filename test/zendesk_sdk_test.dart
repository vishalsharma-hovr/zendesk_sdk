import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:zendesk_sdk/zendesk_sdk.dart';
import 'package:zendesk_sdk/zendesk_sdk_method_channel.dart';
import 'package:zendesk_sdk/zendesk_sdk_platform_interface.dart';
class MockZendeskSdkPlatform with MockPlatformInterfaceMixin implements ZendeskSdkPlatform {
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
  Future<int> getUnreadMessageCount() async => 3;

  @override
  Future<void> updatePushNotificationToken({required String token}) async {}

  @override
  Future<bool> handlePushNotification({required Map<String, dynamic> data}) async => true;
}

void main() {
  final ZendeskSdkPlatform initialPlatform = ZendeskSdkPlatform.instance;

  test('$MethodChannelZendeskSdk is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelZendeskSdk>());
  });

  test('public API delegates to the platform implementation', () async {
    final zendesk = ZendeskSdk();
    ZendeskSdkPlatform.instance = MockZendeskSdkPlatform();

    await zendesk.initialize(
      url: 'https://example.zendesk.com',
      appId: 'fakeAppId',
      clientId: 'fakeClientId',
      emailId: 'name@email.com',
      name: 'name',
      userId: 'userID',
      userType: 'RIDER',
    );

    await zendesk.showHelpCenter(
      name: 'Name',
      emailId: 'EmailId',
      userId: 'UserId',
      categoryIdList: [1, 2, 3],
    );

    await zendesk.showHelpWithArticleId(articleId: '123');
    await zendesk.showHelpWithCategoryId(categoryId: '456');
    await zendesk.startChatBot();
    await zendesk.logout();

    expect(await zendesk.isInitialized(), isTrue);
    expect(await zendesk.getUnreadMessageCount(), 3);
    expect(
      await zendesk.handlePushNotification(data: {'key': 'value'}),
      isTrue,
    );
  });

  test('initialize rejects empty required fields before calling native', () async {
    final platform = MethodChannelZendeskSdk();
    await expectLater(
      platform.initialize(
        url: '',
        appId: 'app',
        clientId: 'client',
        emailId: 'a@b.com',
        name: 'n',
        userId: 'u',
        userType: 'RIDER',
      ),
      throwsA(isA<ZendeskSdkException>()),
    );
  });
}
