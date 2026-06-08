import Foundation

/// Support SDK operations: Help Center, tickets, Answer Bot (ISP).
protocol ZendeskSupportHandling {
    func showHelpCenter(categoryIdList: [NSNumber]) -> ZendeskNativeResult<Void>
    func showHelpCenterArticleId(articleId: String) -> ZendeskNativeResult<Void>
    func showHelpCenterCategoryId(categoryId: Int64) -> ZendeskNativeResult<Void>
    func sendUserInformationForTicket(request: ZendeskTicketRequest) -> ZendeskNativeResult<Void>
    func showListOfTickets() -> ZendeskNativeResult<Void>
    func startChatBot() -> ZendeskNativeResult<Void>
}
