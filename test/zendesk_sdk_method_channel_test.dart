import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zendesk_sdk/zendesk_sdk_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final MethodChannelZendeskSdk platform = MethodChannelZendeskSdk();
  const MethodChannel channel = MethodChannel('zendesk_sdk');

  final List<MethodCall> log = [];

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      log.add(methodCall);

      switch (methodCall.method) {
        case 'initialize':
          return null;
        case 'showHelpCenter':
          return null;
        default:
          throw PlatformException(code: 'not_implemented');
      }
    });

    log.clear();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('initialize sends correct parameters', () async {
    await platform.initialize(url: 'https://example.zendesk.com', appId: 'testAppId', clientId: 'testClientId');

    expect(log.single.method, 'initialize');
    expect(log.single.arguments, {'url': 'https://example.zendesk.com', 'appId': 'testAppId', 'clientId': 'testClientId'});
  });

  test('showHelpCenter is called', () async {
    // await platform.showHelpCenterMethodChannel(articleId: "", categoryId: "");
    expect(log.single.method, 'showHelpCenter');
  });
}
