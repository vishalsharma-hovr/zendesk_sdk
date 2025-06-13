// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:zendesk_sdk/zendesk_sdk.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final ZendeskSdk plugin = ZendeskSdk();

  testWidgets('initialize does not throw', (WidgetTester tester) async {
    await plugin.initialize(
      url: 'https://example.zendesk.com',
      appId: 'your_app_id',
      clientId: 'your_client_id',
    );
    expect(true, isTrue); // no exceptions = success
  });

  testWidgets('showHelpCenter does not throw', (WidgetTester tester) async {
    await plugin.showHelpCenter();
    expect(true, isTrue); // no exceptions = success
  });
}
