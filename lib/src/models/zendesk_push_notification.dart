/// Push notification payload for Zendesk Messaging.
class ZendeskPushNotification {
  const ZendeskPushNotification({required this.data});

  final Map<String, dynamic> data;

  Map<String, dynamic> toChannelArguments() => {
        'pushNotificationData': data,
      };
}

/// Device push token registration value object.
class ZendeskPushToken {
  const ZendeskPushToken(this.value);

  final String value;
}
