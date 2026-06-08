/// Messaging SDK operations: chat, unread count, push (Interface Segregation).
abstract class ZendeskMessagingPlatform {
  Future<void> startChat({required String channelId});

  Future<int> getUnreadMessageCount();

  Future<void> updatePushNotificationToken({required String token});

  Future<bool> handlePushNotification({required Map<String, dynamic> data});
}
