package com.example.zendesk_sdk.platform

import com.example.zendesk_sdk.models.ZendeskTicketRequest
import com.example.zendesk_sdk.result.ZendeskResult

/// Support SDK operations: Help Center, tickets, Answer Bot (ISP).
interface ZendeskSupportHandler {
    fun showHelpCenter(categoryIdList: List<Long>): ZendeskResult<Unit>
    fun showHelpCenterArticleId(articleId: Long): ZendeskResult<Unit>
    fun showHelpCenterCategoryId(categoryId: Long): ZendeskResult<Unit>
    fun sendUserInformationForTicket(request: ZendeskTicketRequest): ZendeskResult<Unit>
    fun showListOfTickets(): ZendeskResult<Unit>
    fun startChatBot(): ZendeskResult<Unit>
}
