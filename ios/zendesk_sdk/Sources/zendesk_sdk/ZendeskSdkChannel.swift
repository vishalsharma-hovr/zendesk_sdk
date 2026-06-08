enum ZendeskSdkChannel {
    static let name = "zendesk_sdk"

    enum Method {
        static let initialize = "initialize"
        static let showHelpCenter = "showHelpCenter"
        static let showHelpCenterArticleId = "showHelpCenterArticleId"
        static let showHelpCenterCategoryId = "showHelpCenterCategoryId"
        static let sendUserInformationForTicket = "sendUserInformationForTicket"
        static let startChatBot = "startChatBot"
        static let showListOfTickets = "showListOfTickets"
        static let startChat = "startChat"
    }

    enum Argument {
        static let zendeskUrl = "zendeskUrl"
        static let appId = "appId"
        static let clientId = "clientId"
        static let name = "name"
        static let emailId = "emailId"
        static let userId = "userId"
        static let userType = "userType"
        static let categoryIdList = "categoryIdList"
        static let articleId = "articleId"
        static let categoryId = "categoryId"
        static let tripId = "tripId"
        static let channelId = "channelId"
        static let customFields = "customFields"
        static let fieldId = "fieldId"
        static let value = "value"
    }
}
