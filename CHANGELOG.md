## 1.1.0+3
- Added `logout()`, `isInitialized()`, `getUnreadMessageCount()`, `updatePushNotificationToken()`, and `handlePushNotification()` APIs.
- Implemented Help Center article/category navigation on Android and iOS.
- Implemented Answer Bot on Android; unified error codes across platforms (`NO_UI_CONTEXT`, `NOT_INITIALIZED`, etc.).
- `userType` is now applied as a native ticket/messaging tag.
- Messaging sessions receive visitor name/email from `initialize()` via conversation fields and tags.
- Added Dart-side argument validation, expanded unit tests, and a CI workflow (`flutter analyze` + `flutter test`).
- Removed dead commented code from the iOS plugin implementation.

## 1.0.1+2
- Added few feature to the plugin.

## 1.0.0+1
- Initial release with basic Zendesk Messaging SDK integration.
