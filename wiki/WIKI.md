# zendesk_sdk — Wiki

A Flutter plugin that integrates the Zendesk **Support**, **Chat**, **Answer Bot**, and **Messaging** SDKs for **Android** and **iOS**.

- Repository: https://github.com/vishalsharma-hovr/zendesk_sdk
- Version: `1.0.1+2`
- Flutter `>=3.41.0`, Dart `^3.11.0`, iOS 13+

---

## Table of Contents
1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Project Structure](#project-structure)
4. [Public API](#public-api)
5. [MethodChannel Contract](#methodchannel-contract)
6. [Platform Behavior](#platform-behavior)
7. [Secrets & Configuration](#secrets--configuration)
8. [Error Handling](#error-handling)
9. [Setup & Installation](#setup--installation)
10. [Running the Example](#running-the-example)
11. [Testing](#testing)
12. [FAQ / Notes](#faq--notes)

---

## Overview

`zendesk_sdk` exposes a single Dart entry point (`ZendeskSdk.instance`) that bridges to the
native Zendesk SDKs through a `MethodChannel`. It supports:

- Initializing Zendesk Support + Chat + Answer Bot with an anonymous identity
- Opening the Help Center filtered by category IDs
- Submitting tickets with user/trip metadata and dynamic custom fields
- Listing a user's tickets
- Launching Zendesk Messaging (live chat) by channel key

---

## Architecture

The plugin follows the standard federated Flutter plugin pattern:

```
ZendeskSdk (public singleton)
        │
        ▼
ZendeskSdkPlatform (PlatformInterface, abstract)
        │
        ▼
MethodChannelZendeskSdk (default impl)
        │  MethodChannel("zendesk_sdk")
        ├──────────────► Android: ZendeskSdkPlugin.kt
        └──────────────► iOS:     ZendeskSdkPlugin.swift
```

- **`ZendeskSdk`** — user-facing singleton (`lib/zendesk_sdk.dart`).
- **`ZendeskSdkPlatform`** — abstract platform interface guarded by `plugin_platform_interface`.
- **`MethodChannelZendeskSdk`** — serializes calls/args and converts `PlatformException` → `ZendeskSdkException`.
- **`ZendeskSdkChannel`** — single source of truth for channel name, method names, and argument keys (mirrored on each native side).

---

## Project Structure

```
zendesk_sdk/
├── lib/
│   ├── zendesk_sdk.dart                  # Public singleton API
│   ├── zendesk_sdk_platform_interface.dart
│   ├── zendesk_sdk_method_channel.dart   # Default MethodChannel impl
│   └── src/
│       ├── zendesk_sdk_channel.dart      # Channel/method/arg constants
│       ├── zendesk_custom_field.dart     # Ticket custom field model
│       └── zendesk_sdk_exception.dart    # Typed exception
├── android/
│   └── src/main/kotlin/com/example/zendesk_sdk/
│       ├── ZendeskSdkPlugin.kt           # Native Android handler
│       └── ZendeskSdkChannel.kt          # Native constants
├── ios/zendesk_sdk/                      # SPM package (no CocoaPods)
│   ├── Package.swift
│   └── Sources/zendesk_sdk/
│       ├── ZendeskSdkPlugin.swift
│       ├── ZendeskSdkChannel.swift
│       └── PrivacyInfo.xcprivacy
├── example/                              # Demo app + secrets wiring
└── .secrets/zendesk.env(.example)        # Local secrets (gitignored)
```

---

## Public API

Use the singleton: `ZendeskSdk.instance` (or `ZendeskSdk()`).

| Method | Description |
| --- | --- |
| `initialize(...)` | Initializes Support, Chat, and Answer Bot; sets an anonymous identity |
| `showHelpCenter(...)` | Opens Help Center filtered by `categoryIdList` |
| `sendUserInformationForTicket(...)` | Opens ticket submission with user/trip metadata + optional custom fields |
| `showListOfTickets(...)` | Opens the user's ticket list |
| `startChat(channelId:)` | Opens Zendesk Messaging with a channel key |
| `startChatBot()` | Opens Answer Bot (iOS only for now) |
| `showHelpWithArticleId(...)` | Declared but **not implemented** natively (`notImplemented`) |
| `showHelpWithCategoryId(...)` | Declared but **not implemented** natively (`notImplemented`) |

### Example

```dart
import 'package:zendesk_sdk/zendesk_sdk.dart';

final zendesk = ZendeskSdk.instance;

try {
  await zendesk.initialize(
    url: 'https://your-subdomain.zendesk.com',
    appId: 'your_app_id',
    clientId: 'your_client_id',
    name: 'John Doe',
    emailId: 'john@example.com',
    userId: 'user-123',
    userType: 'RIDER',
  );

  await zendesk.showHelpCenter(
    name: 'John Doe',
    emailId: 'john@example.com',
    userId: 'user-123',
    categoryIdList: [123456789],
  );

  await zendesk.sendUserInformationForTicket(
    name: 'John Doe',
    emailId: 'john@example.com',
    userId: 'user-123',
    tripId: 'trip-987',
    customFields: [
      ZendeskCustomField(fieldId: 29516552016157, value: 'RIDER'),
    ],
  );

  await zendesk.startChat(channelId: 'your_channel_key');
} on ZendeskSdkException catch (e) {
  debugPrint('Zendesk error [${e.code}]: ${e.message}');
}
```

### `ZendeskCustomField`

```dart
ZendeskCustomField(fieldId: 29516552016157, value: 'RIDER');
// Serialized as { "fieldId": <int>, "value": <String> }
```

---

## MethodChannel Contract

Channel name: **`zendesk_sdk`** (defined in `ZendeskSdkChannel.name`).

| Method constant | Channel method |
| --- | --- |
| `methodInitialize` | `initialize` |
| `methodShowHelpCenter` | `showHelpCenter` |
| `methodShowHelpCenterArticleId` | `showHelpCenterArticleId` |
| `methodShowHelpCenterCategoryId` | `showHelpCenterCategoryId` |
| `methodSendUserInformationForTicket` | `sendUserInformationForTicket` |
| `methodStartChatBot` | `startChatBot` |
| `methodShowListOfTickets` | `showListOfTickets` |
| `methodStartChat` | `startChat` |

Argument keys: `zendeskUrl`, `appId`, `clientId`, `name`, `emailId`, `userId`,
`userType`, `categoryIdList`, `articleId`, `categoryId`, `tripId`, `channelId`, `customFields`.

The same constants are mirrored natively in `ZendeskSdkChannel.kt` and `ZendeskSdkChannel.swift`
to keep method/arg names consistent across platforms.

---

## Platform Behavior

### Android (`ZendeskSdkPlugin.kt`)
- `ActivityAware`; most UI actions require an attached `Activity` (else `NO_ACTIVITY`).
- `initialize`: inits `Zendesk` (v2 Support/Chat/AnswerBot) with an `AnonymousIdentity`
  using `name | UserID: userId` and email. Inits `Chat` with `clientId`/`appId`.
- `showHelpCenter`: launches `HelpCenterActivity` filtered by category IDs, with a
  contact-us button and request tags (`user_id`, `mobile_app`).
- `sendUserInformationForTicket`: launches `RequestActivity` with custom fields and tags
  (`user_id`, `trip_id`). Requires non-empty `userId` and `tripId`.
- `showListOfTickets`: fetches all requests, then shows `RequestListActivity`.
- `startChat`: uses Zendesk v3 (`zendesk.android.Zendesk`) + `DefaultMessagingFactory`
  to show messaging.
- `startChatBot`, `showHelpCenterArticleId`, `showHelpCenterCategoryId` → `notImplemented`.

### iOS (`ZendeskSdkPlugin.swift`, SPM)
- **SPM only** (no CocoaPods). Dependencies resolved via Swift Package Manager:
  - `support_sdk_ios` 9.3.0
  - `chat_sdk_ios` 5.0.8
  - `answer_bot_sdk_ios` 6.0.3
  - `sdk_messaging_ios` 2.35.0+
- Consuming apps need Flutter `>=3.24` for SPM; the plugin requires `>=3.41.0`
  because it depends on `FlutterFramework` via SPM.

---

## Secrets & Configuration

Secrets live in **`.secrets/zendesk.env`** (gitignored), are injected into the native
manifests at build time, and Dart reads them **by key name** only.

```env
ZENDESK_URL=https://your-subdomain.zendesk.com
ZENDESK_APP_ID=your_mobile_sdk_app_id
ZENDESK_CLIENT_ID=your_mobile_sdk_client_id
ZENDESK_CHANNEL_ID=your_messaging_channel_key
```

1. **Create:** `cp .secrets/zendesk.env.example .secrets/zendesk.env`
2. **Android:** Gradle injects values into `AndroidManifest.xml` `<meta-data>` placeholders.
3. **iOS:** run `example/ios/scripts/generate_secrets_xcconfig.sh` to produce
   `Secrets.generated.xcconfig` (quoted so `https://` URLs survive), injected into `Info.plist`.
4. **Dart:** read by key via the example's `ZendeskEnv` helper (`env.require(ZendeskEnv.keyUrl)`),
   which reads AndroidManifest/Info.plist first and falls back to the `.secrets` file.

| Key | Used for |
| --- | --- |
| `ZENDESK_URL` | Zendesk subdomain URL |
| `ZENDESK_APP_ID` | Mobile SDK app ID |
| `ZENDESK_CLIENT_ID` | Mobile SDK client ID |
| `ZENDESK_CHANNEL_ID` | Messaging channel key |

---

## Error Handling

Native `PlatformException`s are converted to typed `ZendeskSdkException(code, message, details)`.

```dart
try {
  await zendesk.initialize(/* ... */);
} on ZendeskSdkException catch (e) {
  print('${e.code}: ${e.message}');
}
```

| Code | Meaning |
| --- | --- |
| `INVALID_ARGUMENTS` | Missing/invalid method arguments |
| `NO_CONTEXT` / `NO_ACTIVITY` | No native context/UI to present screens |
| `INIT_FAILED` | Support/Chat/AnswerBot init failed |
| `CHAT_INIT_FAILED` / `CHAT_ENGINE_FAILED` | Messaging init failed |
| `LAUNCH_FAILED` | A screen failed to launch |

---

## Setup & Installation

Add the dependency:

```yaml
dependencies:
  zendesk_sdk:
    git:
      url: https://github.com/vishalsharma-hovr/zendesk_sdk.git
```

Enable SPM once (iOS):

```bash
flutter config --enable-swift-package-manager
```

---

## Running the Example

```bash
# 1. Create secrets
cp .secrets/zendesk.env.example .secrets/zendesk.env

# 2. Generate iOS secrets xcconfig
chmod +x example/ios/scripts/generate_secrets_xcconfig.sh
example/ios/scripts/generate_secrets_xcconfig.sh

# 3. Enable SPM (iOS)
flutter config --enable-swift-package-manager

# 4. Run
cd example
flutter pub get
flutter run
```

---

## Testing

- Dart unit tests: `test/zendesk_sdk_test.dart`, `test/zendesk_sdk_method_channel_test.dart`
- Android: `android/src/test/.../ZendeskSdkPluginTest.kt`
- Integration: `example/integration_test/plugin_integration_test.dart`

Run: `flutter test`

---

## FAQ / Notes

- **Why SPM, not CocoaPods?** iOS uses SPM exclusively; the old `Podfile`/podspec were removed.
- **Answer Bot / chat bot:** `startChatBot()` is iOS-only and `notImplemented` on Android.
- **Article/Category-by-ID Help Center:** declared in Dart but `notImplemented` natively.
- **Identity:** the SDK uses an anonymous identity built from name/email/userId.
