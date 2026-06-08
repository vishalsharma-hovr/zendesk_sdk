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
| [Overview](https://github.com/vishalsharma-hovr/zendesk_sdk/wiki/WIKI#overview) | What the plugin does |
| [Architecture](https://github.com/vishalsharma-hovr/zendesk_sdk/wiki/WIKI#architecture) | How the Dart ↔ native bridge is wired |
| [Project Structure](https://github.com/vishalsharma-hovr/zendesk_sdk/wiki/WIKI#project-structure) | Directory layout |
| [Public API](https://github.com/vishalsharma-hovr/zendesk_sdk/wiki/WIKI#public-api) | Every method with examples |
| [MethodChannel Contract](https://github.com/vishalsharma-hovr/zendesk_sdk/wiki/WIKI#methodchannel-contract) | Channel/method/argument names |
| [Platform Behavior](https://github.com/vishalsharma-hovr/zendesk_sdk/wiki/WIKI#platform-behavior) | Android & iOS specifics |
| [Secrets & Configuration](https://github.com/vishalsharma-hovr/zendesk_sdk/wiki/WIKI#secrets--configuration) | `.secrets/zendesk.env` wiring |
| [Error Handling](https://github.com/vishalsharma-hovr/zendesk_sdk/wiki/WIKI#error-handling) | `ZendeskSdkException` & error codes |
| [Setup & Installation](https://github.com/vishalsharma-hovr/zendesk_sdk/wiki/WIKI#setup--installation) | Adding the dependency |
| [Running the Example](https://github.com/vishalsharma-hovr/zendesk_sdk/wiki/WIKI#running-the-example) | Run the demo app |
| [Testing](https://github.com/vishalsharma-hovr/zendesk_sdk/wiki/WIKI#testing) | Unit & integration tests |
| [FAQ / Notes](https://github.com/vishalsharma-hovr/zendesk_sdk/wiki/WIKI#faq--notes) | Gotchas & answers |

> The full reference lives in [WIKI](https://github.com/vishalsharma-hovr/zendesk_sdk/wiki/WIKI).

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
