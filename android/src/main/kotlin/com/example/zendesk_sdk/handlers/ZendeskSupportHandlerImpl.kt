package com.example.zendesk_sdk.handlers

import android.util.Log
import com.example.zendesk_sdk.ZendeskSdkErrorCodes
import com.example.zendesk_sdk.models.ZendeskTicketRequest
import com.example.zendesk_sdk.platform.ZendeskSupportHandler
import com.example.zendesk_sdk.platform.ZendeskUiContext
import com.example.zendesk_sdk.result.ZendeskResult
import com.example.zendesk_sdk.session.ZendeskSession
import com.zendesk.service.ErrorResponse
import com.zendesk.service.ZendeskCallback
import zendesk.answerbot.AnswerBotEngine
import zendesk.classic.messaging.MessagingActivity
import zendesk.support.Request
import zendesk.support.Support
import zendesk.support.guide.HelpCenterActivity
import zendesk.support.guide.ViewArticleActivity
import zendesk.support.request.RequestActivity
import zendesk.support.requestlist.RequestListActivity

class ZendeskSupportHandlerImpl(
    private val session: ZendeskSession,
    private val uiContext: ZendeskUiContext,
) : ZendeskSupportHandler {

    override fun showHelpCenter(categoryIdList: List<Long>): ZendeskResult<Unit> {
        if (!requireInitialized()) return notInitialized()

        return try {
            val currentActivity = requireActivity() ?: return noUiContext()
            val requestActivityConfig = RequestActivity.builder()
                .withTags(session.user.baseTags())
                .config()

            HelpCenterActivity.builder()
                .withArticlesForCategoryIds(categoryIdList)
                .withContactUsButtonVisible(true)
                .show(currentActivity, requestActivityConfig)

            ZendeskResult.Success(Unit)
        } catch (e: Exception) {
            ZendeskResult.Failure(ZendeskSdkErrorCodes.LAUNCH_FAILED, e.localizedMessage)
        }
    }

    override fun showHelpCenterArticleId(articleId: Long): ZendeskResult<Unit> {
        if (!requireInitialized()) return notInitialized()

        return try {
            val currentActivity = requireActivity() ?: return noUiContext()
            ViewArticleActivity.builder(articleId).show(currentActivity)
            ZendeskResult.Success(Unit)
        } catch (e: Exception) {
            ZendeskResult.Failure(ZendeskSdkErrorCodes.LAUNCH_FAILED, e.localizedMessage)
        }
    }

    override fun showHelpCenterCategoryId(categoryId: Long): ZendeskResult<Unit> {
        if (!requireInitialized()) return notInitialized()

        return try {
            val currentActivity = requireActivity() ?: return noUiContext()
            val requestActivityConfig = RequestActivity.builder()
                .withTags(session.user.baseTags())
                .config()

            HelpCenterActivity.builder()
                .withArticlesForCategoryIds(categoryId)
                .withContactUsButtonVisible(true)
                .show(currentActivity, requestActivityConfig)

            ZendeskResult.Success(Unit)
        } catch (e: Exception) {
            ZendeskResult.Failure(ZendeskSdkErrorCodes.LAUNCH_FAILED, e.localizedMessage)
        }
    }

    override fun sendUserInformationForTicket(request: ZendeskTicketRequest): ZendeskResult<Unit> {
        if (!requireInitialized()) return notInitialized()

        session.user = request.user
        val currentActivity = requireActivity() ?: return noUiContext()

        return try {
            val customFields = request.customFields.map { it.toNative() }
            val tags = request.user.baseTags(tripId = request.tripId)

            val config = RequestActivity.builder()
                .apply {
                    if (customFields.isNotEmpty()) {
                        withCustomFields(customFields)
                    }
                }
                .withTags(tags)
                .intent(currentActivity)

            currentActivity.startActivity(config)
            ZendeskResult.Success(Unit)
        } catch (e: Exception) {
            ZendeskResult.Failure(ZendeskSdkErrorCodes.LAUNCH_FAILED, e.localizedMessage)
        }
    }

    override fun showListOfTickets(): ZendeskResult<Unit> {
        if (!requireInitialized()) return notInitialized()

        return try {
            val currentActivity = requireActivity() ?: return noUiContext()

            val requestProvider = Support.INSTANCE.provider()?.requestProvider()
            requestProvider?.getAllRequests(object : ZendeskCallback<List<Request>>() {
                override fun onSuccess(requests: List<Request>?) {
                    requests?.forEach {
                        Log.d("ZENDESK", "Ticket ${it.id} - ${it.subject}")
                    }
                    RequestListActivity.builder().show(currentActivity)
                }

                override fun onError(errorResponse: ErrorResponse?) {
                    Log.e("ZENDESK", errorResponse?.reason ?: "Unknown error")
                    RequestListActivity.builder().show(currentActivity)
                }
            })
            ZendeskResult.Success(Unit)
        } catch (e: Exception) {
            ZendeskResult.Failure(ZendeskSdkErrorCodes.LAUNCH_FAILED, e.localizedMessage)
        }
    }

    override fun startChatBot(): ZendeskResult<Unit> {
        if (!requireInitialized()) return notInitialized()

        return try {
            val currentActivity = requireActivity() ?: return noUiContext()
            MessagingActivity.builder()
                .withEngines(AnswerBotEngine.engine())
                .show(currentActivity)
            ZendeskResult.Success(Unit)
        } catch (e: Exception) {
            ZendeskResult.Failure(ZendeskSdkErrorCodes.ANSWERBOT_ERROR, e.localizedMessage)
        }
    }

    private fun requireInitialized(): Boolean = session.isSupportInitialized

    private fun requireActivity() = uiContext.currentActivity()

    private fun notInitialized(): ZendeskResult<Unit> {
        return ZendeskResult.Failure(
            ZendeskSdkErrorCodes.NOT_INITIALIZED,
            "Call initialize() before using the Zendesk SDK",
        )
    }

    private fun noUiContext(): ZendeskResult<Unit> {
        return ZendeskResult.Failure(
            ZendeskSdkErrorCodes.NO_UI_CONTEXT,
            "No activity attached",
        )
    }
}
