// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "zendesk_sdk",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "zendesk-sdk", targets: ["zendesk_sdk"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(url: "https://github.com/zendesk/support_sdk_ios", exact: "9.3.0"),
        .package(url: "https://github.com/zendesk/chat_sdk_ios", exact: "5.0.8"),
        .package(url: "https://github.com/zendesk/answer_bot_sdk_ios", exact: "6.0.3"),
        .package(url: "https://github.com/zendesk/sdk_messaging_ios", from: "2.35.0"),
    ],
    targets: [
        .target(
            name: "zendesk_sdk",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "ZendeskSupportSDK", package: "support_sdk_ios"),
                .product(name: "ZendeskChatSDK", package: "chat_sdk_ios"),
                .product(name: "ZendeskAnswerBotSDK", package: "answer_bot_sdk_ios"),
                .product(name: "ZendeskSDKMessaging", package: "sdk_messaging_ios"),
            ],
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ]
        )
    ]
)
