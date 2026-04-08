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
  }) async {
    // Mock behavior, e.g., log or assert inputs if desired
  }

  @override
  Future<void> showHelpCenter({required String name, required String emailId, required String userId, required List<int> categoryIdList}) async {
    // Mock behavior
  }

  @override
  Future<void> startChatBot() {
    throw UnimplementedError();
  }

  @override
  Future<void> showHelpCenterArticleId({required String articleId}) {
    throw UnimplementedError();
  }

  @override
  Future<void> showHelpCenterCategoryId({required String categoryId}) {
    throw UnimplementedError();
  }

  @override
  Future<void> sendUserInformationForTicket({required String name, required String emailId, required String userId, required String tripId}) {
    throw UnimplementedError();
  }

  @override
  Future<void> showListOfTickets({required String name, required String emailId, required String userId, required String tripId}) {
    // TODO: implement showListOfTickets
    throw UnimplementedError();
  }

  @override
  Future<void> startChat({required String channelId}) {
    // TODO: implement startChat
    throw UnimplementedError();
  }
}

void main() {
  final ZendeskSdkPlatform initialPlatform = ZendeskSdkPlatform.instance;

  test('$MethodChannelZendeskSdk is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelZendeskSdk>());
  });

  test('initialize and showHelpCenter work without error', () async {
    ZendeskSdk zendesk = ZendeskSdk();
    ZendeskSdkPlatform.instance = MockZendeskSdkPlatform();

    await zendesk.initialize(url: 'https://example.zendesk.com', appId: 'fakeAppId', clientId: 'fakeClientId', emailId: "name@email.com", name: "name", userId: "userID", userType: "userType");

    await zendesk.showHelpCenter(name: "Name", emailId: "EmailId", userId: "UserId", categoryIdList: [1, 2, 3]);

    await zendesk.showHelpWithArticleId(articleId: "");

    await zendesk.showHelpWithCategoryId(categoryId: "");

    await zendesk.startChatBot();

    // No exceptions = success
    expect(true, isTrue);
  });
}
