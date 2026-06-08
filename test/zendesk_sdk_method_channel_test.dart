import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zendesk_sdk/src/zendesk_sdk_channel.dart';
import 'package:zendesk_sdk/src/zendesk_sdk_error_codes.dart';
import 'package:zendesk_sdk/src/zendesk_sdk_exception.dart';
import 'package:zendesk_sdk/zendesk_sdk_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final MethodChannelZendeskSdk platform = MethodChannelZendeskSdk();
  const MethodChannel channel = MethodChannel(ZendeskSdkChannel.name);

  final List<MethodCall> log = [];

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      log.add(methodCall);

      switch (methodCall.method) {
        case ZendeskSdkChannel.methodInitialize:
        case ZendeskSdkChannel.methodLogout:
        case ZendeskSdkChannel.methodShowHelpCenter:
        case ZendeskSdkChannel.methodStartChat:
        case ZendeskSdkChannel.methodUpdatePushNotificationToken:
          return null;
        case ZendeskSdkChannel.methodIsInitialized:
          return true;
        case ZendeskSdkChannel.methodGetUnreadMessageCount:
          return 5;
        case ZendeskSdkChannel.methodHandlePushNotification:
          return true;
        default:
          throw PlatformException(code: 'not_implemented');
      }
    });

    log.clear();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('initialize sends correct parameters', () async {
    await platform.initialize(
      url: 'https://example.zendesk.com',
      appId: 'testAppId',
      clientId: 'testClientId',
      emailId: 'name@email.com',
      name: 'name',
      userId: 'userID',
      userType: 'RIDER',
    );

    expect(log.single.method, ZendeskSdkChannel.methodInitialize);
    expect(
      log.single.arguments,
      {
        ZendeskSdkChannel.argZendeskUrl: 'https://example.zendesk.com',
        ZendeskSdkChannel.argAppId: 'testAppId',
        ZendeskSdkChannel.argClientId: 'testClientId',
        ZendeskSdkChannel.argName: 'name',
        ZendeskSdkChannel.argEmailId: 'name@email.com',
        ZendeskSdkChannel.argUserId: 'userID',
        ZendeskSdkChannel.argUserType: 'RIDER',
      },
    );
  });

  test('showHelpCenter sends correct parameters', () async {
    await platform.showHelpCenter(
      name: 'Name',
      emailId: 'email@example.com',
      userId: 'user-1',
      categoryIdList: [1, 2, 3],
    );

    expect(log.single.method, ZendeskSdkChannel.methodShowHelpCenter);
    expect(
      log.single.arguments,
      {
        ZendeskSdkChannel.argName: 'Name',
        ZendeskSdkChannel.argEmailId: 'email@example.com',
        ZendeskSdkChannel.argUserId: 'user-1',
        ZendeskSdkChannel.argCategoryIdList: [1, 2, 3],
      },
    );
  });

  test('logout invokes native logout method', () async {
    await platform.logout();
    expect(log.single.method, ZendeskSdkChannel.methodLogout);
  });

  test('isInitialized returns native value', () async {
    expect(await platform.isInitialized(), isTrue);
    expect(log.single.method, ZendeskSdkChannel.methodIsInitialized);
  });

  test('getUnreadMessageCount returns native value', () async {
    expect(await platform.getUnreadMessageCount(), 5);
    expect(log.single.method, ZendeskSdkChannel.methodGetUnreadMessageCount);
  });

  test('updatePushNotificationToken sends token', () async {
    await platform.updatePushNotificationToken(token: 'device-token');
    expect(log.single.method, ZendeskSdkChannel.methodUpdatePushNotificationToken);
    expect(log.single.arguments, {ZendeskSdkChannel.argPushToken: 'device-token'});
  });

  test('handlePushNotification sends payload', () async {
    final handled = await platform.handlePushNotification(
      data: {'zendesk': 'message'},
    );
    expect(handled, isTrue);
    expect(log.single.method, ZendeskSdkChannel.methodHandlePushNotification);
    expect(
      log.single.arguments,
      {ZendeskSdkChannel.argPushNotificationData: {'zendesk': 'message'}},
    );
  });

  test('platform exceptions are converted to ZendeskSdkException', () async {
    await expectLater(
      platform.showHelpCenterArticleId(articleId: '123'),
      throwsA(
        isA<ZendeskSdkException>().having(
          (error) => error.code,
          'code',
          'not_implemented',
        ),
      ),
    );
  });

  test('dart validation rejects empty articleId', () async {
    await expectLater(
      platform.showHelpCenterArticleId(articleId: ''),
      throwsA(
        isA<ZendeskSdkException>().having(
          (error) => error.code,
          'code',
          ZendeskSdkErrorCodes.invalidArguments,
        ),
      ),
    );
    expect(log, isEmpty);
  });
}
