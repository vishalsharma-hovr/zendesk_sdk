# zendesk_sdk

A Flutter plugin that integrates Zendesk Support, Chat, Answer Bot, and Messaging SDKs for Android and iOS.

## Requirements

- Flutter `>=3.41.0`
- Dart `^3.11.0`
- iOS 13+
- Android

### iOS: Swift Package Manager (SPM)

This plugin uses **SPM only** on iOS (no CocoaPods). Enable it once:

```bash
flutter config --enable-swift-package-manager
```

Consuming apps need Flutter `>=3.24` for SPM integration. The plugin itself requires Flutter `>=3.41.0` because it depends on `FlutterFramework` via SPM.

## Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  zendesk_sdk:
    git:
      url: https://github.com/vishalsharma-hovr/zendesk_sdk.git
```

Or use a path dependency while developing locally.

## OOP architecture

This plugin is structured as a Dart OOP teaching example: value objects, segregated platform interfaces, command pattern, sealed `ZendeskResult`, injectable `ZendeskService`, and an MVC example app. See [wiki/OOP-Guide.md](wiki/OOP-Guide.md).

```dart
final service = ZendeskService.fromSdkPlatform(ZendeskSdkPlatform.instance);

await service.initialize(
  config: ZendeskConfig(url: url, appId: appId, clientId: clientId),
  user: ZendeskUser(name: name, emailId: emailId, userId: userId, userType: userType),
);
```

## Quick start

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

  await zendesk.startChat(channelId: 'your_channel_key');
} on ZendeskSdkException catch (e) {
  debugPrint('Zendesk error [${e.code}]: ${e.message}');
}
```

## API

| Method | Description |
| --- | --- |
| `initialize` | Initializes Zendesk Support, Chat, and Answer Bot |
| `logout` | Clears identity and messaging session (call on sign-out) |
| `isInitialized` | Returns whether `initialize` completed on the native side |
| `showHelpCenter` | Opens Help Center filtered by category IDs |
| `showHelpWithArticleId` | Opens a single Help Center article by numeric ID |
| `showHelpWithCategoryId` | Opens Help Center for a single category ID |
| `sendUserInformationForTicket` | Opens ticket submission with user/trip metadata and optional custom fields |
| `showListOfTickets` | Opens the user's ticket list |
| `startChat` | Opens Zendesk Messaging with a channel key |
| `startChatBot` | Opens Answer Bot (Android and iOS) |
| `getUnreadMessageCount` | Returns total unread messaging count |
| `updatePushNotificationToken` | Registers FCM/APNs token with Zendesk Messaging |
| `handlePushNotification` | Validates and handles a Zendesk Messaging push payload |

Use the singleton:

```dart
final zendesk = ZendeskSdk.instance;
// or
final zendesk = ZendeskSdk();
```

Pass Zendesk ticket custom fields dynamically:

```dart
await zendesk.sendUserInformationForTicket(
  name: name,
  emailId: emailId,
  userId: userId,
  tripId: tripId,
  customFields: [
    ZendeskCustomField(fieldId: 29516552016157, value: 'RIDER'),
    ZendeskCustomField(fieldId: 29516536736157, value: 'DRIVER'),
  ],
);
```

## Error handling

Platform errors are converted to `ZendeskSdkException`:

```dart
try {
  await zendesk.initialize(...);
} on ZendeskSdkException catch (e) {
  print('${e.code}: ${e.message}');
}
```

Common error codes:

| Code | Meaning |
| --- | --- |
| `INVALID_ARGUMENTS` | Missing or invalid method arguments |
| `NO_UI_CONTEXT` | No UI context to present Zendesk screens |
| `NOT_INITIALIZED` | `initialize()` was not called first |
| `INIT_FAILED` | Native SDK initialization failed |
| `CHAT_INIT_FAILED` | Messaging SDK failed to initialize |
| `LOGOUT_FAILED` | Failed to clear Zendesk session |

## MethodChannel contract

Dart and native platforms share the same channel contract via constants:

- Channel: `zendesk_sdk`
- Dart: `lib/src/zendesk_sdk_channel.dart`
- iOS: `ios/zendesk_sdk/Sources/zendesk_sdk/ZendeskSdkChannel.swift`
- Android: `android/.../ZendeskSdkChannel.kt`

This keeps method names and argument keys consistent across platforms.

## Local secrets

Same pattern as Google Maps / Adyen in a production app: secrets live in **`.secrets/zendesk.env`**, get injected into **AndroidManifest** and **Info.plist** at build time, and Dart reads them by **key name** only.

### 1. Create the secrets file

```bash
cp .secrets/zendesk.env.example .secrets/zendesk.env
```

Edit `.secrets/zendesk.env`:

```env
ZENDESK_URL=https://your-subdomain.zendesk.com
ZENDESK_APP_ID=your_mobile_sdk_app_id
ZENDESK_CLIENT_ID=your_mobile_sdk_client_id
ZENDESK_CHANNEL_ID=your_messaging_channel_key
```

### 2. Android — `AndroidManifest.xml`

Gradle reads `.secrets/zendesk.env` and injects values into manifest placeholders:

```xml
<meta-data android:name="ZENDESK_URL" android:value="${ZENDESK_URL}" />
<meta-data android:name="ZENDESK_APP_ID" android:value="${ZENDESK_APP_ID}" />
<meta-data android:name="ZENDESK_CLIENT_ID" android:value="${ZENDESK_CLIENT_ID}" />
<meta-data android:name="ZENDESK_CHANNEL_ID" android:value="${ZENDESK_CHANNEL_ID}" />
```

### 3. iOS — `Info.plist`

Generate an xcconfig file from `.secrets/zendesk.env` (required before each iOS build):

```bash
chmod +x example/ios/scripts/generate_secrets_xcconfig.sh
example/ios/scripts/generate_secrets_xcconfig.sh
```

This writes `example/ios/Flutter/Secrets.generated.xcconfig` with quoted values so `https://` URLs work correctly. Xcode then injects into Info.plist:

```xml
<key>ZENDESK_URL</key>
<string>$(ZENDESK_URL)</string>
```

### 4. Dart — read by key (not hardcoded values)

```dart
import 'zendesk_env.dart';

final env = ZendeskEnv();
await env.load(); // reads AndroidManifest / Info.plist first, .secrets file as fallback

await zendesk.initialize(
  url: env.require(ZendeskEnv.keyUrl),
  appId: env.require(ZendeskEnv.keyAppId),
  clientId: env.require(ZendeskEnv.keyClientId),
  name: name,
  emailId: emailId,
  userId: userId,
  userType: userType,
);

await zendesk.startChat(
  channelId: env.require(ZendeskEnv.keyChannelId),
);
```

| Key | AndroidManifest / Info.plist | Used for |
| --- | --- | --- |
| `ZENDESK_URL` | `ZENDESK_URL` | Zendesk subdomain URL |
| `ZENDESK_APP_ID` | `ZENDESK_APP_ID` | Mobile SDK app ID |
| `ZENDESK_CLIENT_ID` | `ZENDESK_CLIENT_ID` | Mobile SDK client ID |
| `ZENDESK_CHANNEL_ID` | `ZENDESK_CHANNEL_ID` | Messaging channel key |

`.secrets/zendesk.env` is gitignored. Only `.secrets/zendesk.env.example` is committed.

### Use in your own rider app

1. Add the same manifest `meta-data` and Info.plist keys.
2. Point Gradle and xcconfig at your `.secrets/zendesk.env`.
3. Copy `example/lib/zendesk_env.dart` and the native config readers from `MainActivity.kt` / `ZendeskConfigChannel.swift`.

## Run the example app

1. Create `.secrets/zendesk.env` from the template above.
2. Generate iOS secrets: `example/ios/scripts/generate_secrets_xcconfig.sh`
3. Enable SPM (iOS):

```bash
flutter config --enable-swift-package-manager
```

3. Run:

```bash
cd example
flutter pub get
flutter run
```

## iOS plugin structure (SPM)

```
ios/zendesk_sdk/
├── Package.swift
└── Sources/zendesk_sdk/
    ├── ZendeskSdkPlugin.swift
    ├── ZendeskSdkChannel.swift
    └── PrivacyInfo.xcprivacy
```

Zendesk dependencies are resolved via SPM:

- `support_sdk_ios` 9.3.0
- `chat_sdk_ios` 5.0.8
- `answer_bot_sdk_ios` 6.0.3
- `sdk_messaging_ios` 2.35.0+

## Android

Uses Gradle dependencies configured in `android/build.gradle`. No extra setup beyond adding the plugin dependency.

## Links

- [Repository](https://github.com/vishalsharma-hovr/zendesk_sdk)
- [Issues](https://github.com/vishalsharma-hovr/zendesk_sdk/issues)
- [Flutter SPM for plugin authors](https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-plugin-authors)
- [Zendesk Messaging iOS docs](https://developer.zendesk.com/documentation/zendesk-web-widget-sdks/sdks/ios/getting_started/)
