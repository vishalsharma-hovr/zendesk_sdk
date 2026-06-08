import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:zendesk_sdk/zendesk_sdk.dart';
import 'package:zendesk_sdk/zendesk_sdk_platform_interface.dart';

class MockZendeskSdkPlatform with MockPlatformInterfaceMixin implements ZendeskSdkPlatform {
  bool initialized = false;

  @override
  Future<void> initialize({
    required String url,
    required String appId,
    required String clientId,
    required String emailId,
    required String name,
    required String userId,
    required String userType,
  }) async {
    initialized = true;
  }

  @override
  Future<void> logout() async {
    initialized = false;
  }

  @override
  Future<bool> isInitialized() async => initialized;

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
  Future<int> getUnreadMessageCount() async => 7;

  @override
  Future<void> updatePushNotificationToken({required String token}) async {}

  @override
  Future<bool> handlePushNotification({required Map<String, dynamic> data}) async => true;
}

void main() {
  late MockZendeskSdkPlatform mockPlatform;
  late ZendeskService service;

  setUp(() {
    mockPlatform = MockZendeskSdkPlatform();
    service = ZendeskService.fromSdkPlatform(mockPlatform);
  });

  test('initializeResult returns ZendeskSuccess', () async {
    const config = ZendeskConfig(
      url: 'https://example.zendesk.com',
      appId: 'app',
      clientId: 'client',
    );
    const user = ZendeskUser(
      name: 'Jane',
      emailId: 'jane@example.com',
      userId: 'u1',
      userType: 'RIDER',
    );

    final result = await service.initializeResult(config: config, user: user);

    expect(result, isA<ZendeskSuccess<void>>());
    expect(await service.isInitialized(), isTrue);
  });

  test('help center query uses sealed polymorphism', () async {
    const user = ZendeskUser(
      name: 'Jane',
      emailId: 'jane@example.com',
      userId: 'u1',
      userType: 'RIDER',
    );

    final result = await service.showHelpCenterResult(
      ArticleHelpCenterQuery(user: user, articleId: '12345'),
    );

    expect(result, isA<ZendeskSuccess<void>>());
  });

  test('logout clears initialized state', () async {
    await service.initialize(
      config: const ZendeskConfig(
        url: 'https://example.zendesk.com',
        appId: 'app',
        clientId: 'client',
      ),
      user: const ZendeskUser(
        name: 'Jane',
        emailId: 'jane@example.com',
        userId: 'u1',
        userType: 'RIDER',
      ),
    );

    await service.logout();

    expect(await service.isInitialized(), isFalse);
  });
}
