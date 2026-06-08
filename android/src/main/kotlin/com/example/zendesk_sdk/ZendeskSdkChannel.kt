object ZendeskSdkChannel {
    const val NAME = "zendesk_sdk"

    object Method {
        const val INITIALIZE = "initialize"
        const val LOGOUT = "logout"
        const val IS_INITIALIZED = "isInitialized"
        const val SHOW_HELP_CENTER = "showHelpCenter"
        const val SHOW_HELP_CENTER_ARTICLE_ID = "showHelpCenterArticleId"
        const val SHOW_HELP_CENTER_CATEGORY_ID = "showHelpCenterCategoryId"
        const val SEND_USER_INFORMATION_FOR_TICKET = "sendUserInformationForTicket"
        const val START_CHAT_BOT = "startChatBot"
        const val SHOW_LIST_OF_TICKETS = "showListOfTickets"
        const val START_CHAT = "startChat"
        const val GET_UNREAD_MESSAGE_COUNT = "getUnreadMessageCount"
        const val UPDATE_PUSH_NOTIFICATION_TOKEN = "updatePushNotificationToken"
        const val HANDLE_PUSH_NOTIFICATION = "handlePushNotification"
    }

    object Argument {
        const val ZENDESK_URL = "zendeskUrl"
        const val APP_ID = "appId"
        const val CLIENT_ID = "clientId"
        const val NAME = "name"
        const val EMAIL_ID = "emailId"
        const val USER_ID = "userId"
        const val USER_TYPE = "userType"
        const val CATEGORY_ID_LIST = "categoryIdList"
        const val ARTICLE_ID = "articleId"
        const val CATEGORY_ID = "categoryId"
        const val TRIP_ID = "tripId"
        const val CHANNEL_ID = "channelId"
        const val CUSTOM_FIELDS = "customFields"
        const val FIELD_ID = "fieldId"
        const val VALUE = "value"
        const val PUSH_TOKEN = "pushToken"
        const val PUSH_NOTIFICATION_DATA = "pushNotificationData"
    }
}
