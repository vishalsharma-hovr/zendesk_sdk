# OOP Guide — zendesk_sdk

This plugin is structured as a **teaching-quality** Dart OOP example for Flutter plugin architecture.

---

## Layered architecture

```
UI (ZendeskDemoPage)
    ↓
Controller (ZendeskController)          ← MVC / presentation logic
    ↓
Service (ZendeskService)                ← Facade + DIP
    ↓
Segregated interfaces                     ← Interface Segregation (ISP)
    ↓
Platform adapters                         ← Adapter pattern
    ↓
MethodChannel + Commands                    ← Command pattern
    ↓
Native (Android / iOS)
```

---

## OOP concepts mapped to code

| Concept | What it means here | File(s) |
| --- | --- | --- |
| **Encapsulation** | Private SDK constructor; internal `src/` module | `lib/zendesk_sdk.dart` |
| **Abstraction** | Hide native details behind interfaces | `lib/src/platform/*.dart` |
| **Inheritance** | `MethodChannelZendeskSdk extends ZendeskSdkPlatform` | `lib/zendesk_sdk_method_channel.dart` |
| **Polymorphism** | `ZendeskHelpCenterQuery` sealed subtypes; swappable platform mocks | `lib/src/models/zendesk_help_center_query.dart` |
| **Composition** | `ZendeskService` composes lifecycle/support/messaging adapters | `lib/src/zendesk_service.dart` |
| **Singleton** | `ZendeskSdk.instance` for plugin consumers | `lib/zendesk_sdk.dart` |
| **Factory** | `ZendeskSdk()`, `ZendeskService.fromSdkPlatform()` | `lib/zendesk_sdk.dart`, `lib/src/zendesk_service.dart` |
| **Facade** | `ZendeskSdk` delegates to `ZendeskService` | `lib/zendesk_sdk.dart` |
| **Command** | Each channel call is a `ZendeskCommand` object | `lib/src/commands/` |
| **Adapter** | `ZendeskLifecyclePlatformAdapter` wraps `ZendeskSdkPlatform` | `lib/src/platform/zendesk_platform_adapters.dart` |
| **Dependency Injection** | Inject `ZendeskService` into `ZendeskController` | `example/lib/zendesk_controller.dart` |
| **Value Object** | `ZendeskConfig`, `ZendeskUser`, `ZendeskTicketRequest` | `lib/src/models/` |
| **Sealed types** | `ZendeskResult<T>`, `ZendeskHelpCenterQuery` | `lib/src/zendesk_result.dart` |

---

## Phase 1 — Value objects

Replace primitive groups with immutable models:

```dart
const config = ZendeskConfig(
  url: 'https://example.zendesk.com',
  appId: 'app-id',
  clientId: 'client-id',
);

const user = ZendeskUser(
  name: 'Jane',
  emailId: 'jane@example.com',
  userId: 'user-1',
  userType: 'RIDER',
);
```

**Why:** one place to validate, serialize, and document domain data.

---

## Phase 2 — Service layer (DIP)

```dart
final service = ZendeskService.fromSdkPlatform(ZendeskSdkPlatform.instance);

await service.initialize(config: config, user: user);
```

`ZendeskService` depends on **abstractions** (`ZendeskLifecyclePlatform`, etc.), not `MethodChannel` directly.

---

## Phase 3 — Interface segregation (ISP)

| Interface | Responsibility |
| --- | --- |
| `ZendeskLifecyclePlatform` | `initialize`, `logout`, `isInitialized` |
| `ZendeskSupportPlatform` | Help Center, tickets, Answer Bot |
| `ZendeskMessagingPlatform` | Chat, unread count, push |

`ZendeskSdkPlatform` implements all three for plugin compatibility.

---

## Phase 4 — Command pattern

```dart
final command = InitializeCommand(config: config, user: user);
await methodChannel.invokeMethod(command.methodName, command.arguments);
```

Adding a new SDK method = add a new command class (Open/Closed Principle).

---

## Phase 5 — Sealed results

```dart
final result = await service.initializeResult(config: config, user: user);

switch (result) {
  case ZendeskSuccess():
    // initialized
  case ZendeskFailure(:final error):
    // handle ZendeskSdkException without try/catch
}
```

Throwing APIs (`initialize()`) remain for backward compatibility via `valueOrThrow`.

---

## Phase 6 — Example app MVC

| Layer | File |
| --- | --- |
| View | `example/lib/zendesk_demo_page.dart` |
| Controller | `example/lib/zendesk_controller.dart` |
| Model / Service | `ZendeskService` + value objects |

```dart
void main() {
  runApp(MaterialApp(
    home: ZendeskDemoPage(
      controller: ZendeskController.defaults(),
    ),
  ));
}
```

Swap `ZendeskController.defaults()` with a controller that injects a mock `ZendeskService` in tests.

---

## SOLID checklist

| Principle | How this repo demonstrates it |
| --- | --- |
| **S**ingle Responsibility | Commands serialize; validators validate; service orchestrates |
| **O**pen/Closed | New commands extend behavior without editing `_execute` |
| **L**iskov Substitution | `MockZendeskSdkPlatform` replaces real platform in tests |
| **I**nterface Segregation | Lifecycle / Support / Messaging split |
| **D**ependency Inversion | `ZendeskService` → interfaces, not MethodChannel |

---

## Recommended learning path

1. Read `lib/src/models/` — value objects
2. Read `lib/src/platform/` — segregated interfaces + adapters
3. Read `lib/src/commands/` — command pattern
4. Read `lib/src/zendesk_service.dart` — facade + results
5. Read `example/lib/zendesk_controller.dart` — DI in a real app
6. Run `test/zendesk_service_test.dart` — polymorphic mocks

---

## Native side (Android / iOS)

The same OOP structure is mirrored on both native platforms:

```
MethodChannel (ZendeskSdkPlugin)
    ↓
ZendeskMethodDispatcher              ← Command pattern routing
    ↓
ZendeskNativeService                 ← Facade + DIP
    ↓
Segregated handlers (ISP)
    ├── ZendeskLifecycleHandler      ← initialize, logout, isInitialized
    ├── ZendeskSupportHandler        ← Help Center, tickets, Answer Bot
    └── ZendeskMessagingHandler      ← chat, unread count, push
    ↓
ZendeskSession + value objects       ← Encapsulation
```

### Native file map

| Layer | Android | iOS |
| --- | --- | --- |
| Value objects | `android/.../models/` | `ios/.../Models/` |
| Session state | `session/ZendeskSession.kt` | `Session/ZendeskSession.swift` |
| Result type | `result/ZendeskResult.kt` | `Result/ZendeskResult.swift` |
| ISP interfaces | `platform/*Handler.kt` | `Platform/*Handling.swift` |
| Command pattern | `commands/ZendeskCommand.kt` | `Commands/ZendeskCommand.swift` |
| Handler impls | `handlers/*HandlerImpl.kt` | `Handlers/*Handler.swift` |
| Facade | `ZendeskNativeService.kt` | `ZendeskNativeService.swift` |
| Dispatcher | `ZendeskMethodDispatcher.kt` | `ZendeskMethodDispatcher.swift` |
| Plugin entry | `ZendeskSdkPlugin.kt` | `ZendeskSdkPlugin.swift` |

### Native learning path

1. Read `models/` / `Models/` — `ZendeskConfig`, `ZendeskUser`, `ZendeskTicketRequest`
2. Read `commands/` — `ZendeskCommandFactory.parse()` mirrors Dart commands
3. Read handler interfaces — lifecycle / support / messaging split
4. Read `ZendeskNativeService` — sync command execution
5. Read `ZendeskMethodDispatcher` — async UI methods (logout, startChat, Help Center)
6. Run `android/src/test/.../ZendeskCommandFactoryTest.kt`

---

## Public API compatibility

Existing code using primitive parameters still works:

```dart
await ZendeskSdk.instance.initialize(
  url: url,
  appId: appId,
  clientId: clientId,
  name: name,
  emailId: emailId,
  userId: userId,
  userType: userType,
);
```

New OOP-style APIs are additive:

```dart
await ZendeskSdk.instance.initializeResult(config: config, user: user);
```
