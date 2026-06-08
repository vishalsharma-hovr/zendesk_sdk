import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zendesk_sdk/src/zendesk_sdk_channel.dart';
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
        case ZendeskSdkChannel.methodShowHelpCenter:
        case ZendeskSdkChannel.methodStartChat:
          return null;
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
      userType: 'userType',
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
        ZendeskSdkChannel.argUserType: 'userType',
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
}
