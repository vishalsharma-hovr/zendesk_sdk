# zendesk_sdk Wiki

Welcome to the **zendesk_sdk** wiki — a Flutter plugin that integrates the Zendesk
**Support**, **Chat**, **Answer Bot**, and **Messaging** SDKs for **Android** and **iOS**.

- Repository: https://github.com/vishalsharma-hovr/zendesk_sdk
- Version: `1.0.1+2`
- Flutter `>=3.41.0` · Dart `^3.11.0` · iOS 13+

---

## Quick Links

| Section | What's inside |
| --- | --- |
| [Overview](WIKI#overview) | What the plugin does |
| [Architecture](WIKI#architecture) | How the Dart ↔ native bridge is wired |
| [Project Structure](WIKI#project-structure) | Directory layout |
| [Public API](WIKI#public-api) | Every method with examples |
| [MethodChannel Contract](WIKI#methodchannel-contract) | Channel/method/argument names |
| [Platform Behavior](WIKI#platform-behavior) | Android & iOS specifics |
| [Secrets & Configuration](WIKI#secrets--configuration) | `.secrets/zendesk.env` wiring |
| [Error Handling](WIKI#error-handling) | `ZendeskSdkException` & error codes |
| [Setup & Installation](WIKI#setup--installation) | Adding the dependency |
| [Running the Example](WIKI#running-the-example) | Run the demo app |
| [Testing](WIKI#testing) | Unit & integration tests |
| [FAQ / Notes](WIKI#faq--notes) | Gotchas & answers |

> The full reference lives in [WIKI](WIKI).

---

## Get Started in 60 Seconds

```dart
import 'package:zendesk_sdk/zendesk_sdk.dart';

final zendesk = ZendeskSdk.instance;

await zendesk.initialize(
  url: 'https://your-subdomain.zendesk.com',
  appId: 'your_app_id',
  clientId: 'your_client_id',
  name: 'John Doe',
  emailId: 'john@example.com',
  userId: 'user-123',
  userType: 'RIDER',
);

await zendesk.startChat(channelId: 'your_channel_key');
```

---

## At a Glance

| Capability | Method |
| --- | --- |
| Initialize Support/Chat/Answer Bot | `initialize(...)` |
| Open Help Center (by category) | `showHelpCenter(...)` |
| Submit a ticket | `sendUserInformationForTicket(...)` |
| List tickets | `showListOfTickets(...)` |
| Open Messaging (live chat) | `startChat(channelId:)` |
| Open Answer Bot (iOS) | `startChatBot()` |

---

## Helpful External Links

- [Flutter SPM for plugin authors](https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-plugin-authors)
- [Zendesk Messaging iOS docs](https://developer.zendesk.com/documentation/zendesk-web-widget-sdks/sdks/ios/getting_started/)
- [Issues](https://github.com/vishalsharma-hovr/zendesk_sdk/issues)
