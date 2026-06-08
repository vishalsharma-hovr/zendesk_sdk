/// Messaging SDK operations: chat, unread count, push (ISP).
protocol ZendeskMessagingHandling {
    func getUnreadMessageCount() -> ZendeskNativeResult<Int>
    func updatePushNotificationToken(token: String) -> ZendeskNativeResult<Void>
    func handlePushNotification(payload: [String: Any]) -> ZendeskNativeResult<Bool>
}
