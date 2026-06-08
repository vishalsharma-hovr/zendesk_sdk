import AnswerBotProvidersSDK
import AnswerBotSDK
import Flutter
import MessagingSDK
import SDKConfigurations
import SupportProvidersSDK
import SupportSDK
import UIKit
import ZendeskCoreSDK

final class ZendeskSupportHandler: ZendeskSupportHandling {
    private let session: ZendeskSession
    private weak var uiContext: ZendeskUiContextProviding?
    private weak var pluginHost: ZendeskPluginHost?
    private let lifecycleHandler: ZendeskLifecycleHandler

    init(
        session: ZendeskSession,
        uiContext: ZendeskUiContextProviding,
        pluginHost: ZendeskPluginHost,
        lifecycleHandler: ZendeskLifecycleHandler
    ) {
        self.session = session
        self.uiContext = uiContext
        self.pluginHost = pluginHost
        self.lifecycleHandler = lifecycleHandler
    }

    func showHelpCenter(categoryIdList: [NSNumber]) -> ZendeskNativeResult<Void> {
        .failure(code: ZendeskSdkErrorCodes.launchFailed, message: "Use showHelpCenterAsync")
    }

    func showHelpCenterAsync(categoryIdList: [NSNumber], result: @escaping FlutterResult) {
        guard lifecycleHandler.requireInitialized(result: result) else { return }

        DispatchQueue.main.async {
            guard let rootVC = self.uiContext?.rootViewController() else {
                ZendeskNativeResult<Void>.failure(
                    code: ZendeskSdkErrorCodes.noUiContext,
                    message: "No root view controller found"
                ).complete(result)
                return
            }

            let requestConfig = RequestUiConfiguration()
            requestConfig.tags = self.session.user.baseTags()

            let helpCenterConfig = HelpCenterUiConfiguration()
            helpCenterConfig.showContactOptions = true
            helpCenterConfig.groupType = .category
            helpCenterConfig.groupIds = categoryIdList

            let helpCenterVC = HelpCenterUi.buildHelpCenterOverviewUi(
                withConfigs: [helpCenterConfig, requestConfig]
            )

            self.presentWithCloseButton(rootVC: rootVC, viewController: helpCenterVC, result: result)
        }
    }

    func showHelpCenterArticleId(articleId: String) -> ZendeskNativeResult<Void> {
        .failure(code: ZendeskSdkErrorCodes.launchFailed, message: "Use showHelpCenterArticleIdAsync")
    }

    func showHelpCenterArticleIdAsync(articleId: String, result: @escaping FlutterResult) {
        guard lifecycleHandler.requireInitialized(result: result) else { return }

        DispatchQueue.main.async {
            guard let rootVC = self.uiContext?.rootViewController() else {
                ZendeskNativeResult<Void>.failure(
                    code: ZendeskSdkErrorCodes.noUiContext,
                    message: "No root view controller found"
                ).complete(result)
                return
            }

            let articleVC = HelpCenterUi.buildHelpCenterArticleUi(withArticleId: articleId)
            let navController = UINavigationController(rootViewController: articleVC)
            navController.modalPresentationStyle = .fullScreen
            rootVC.present(navController, animated: true) {
                result(nil)
            }
        }
    }

    func showHelpCenterCategoryId(categoryId: Int64) -> ZendeskNativeResult<Void> {
        .failure(code: ZendeskSdkErrorCodes.launchFailed, message: "Use showHelpCenterCategoryIdAsync")
    }

    func showHelpCenterCategoryIdAsync(categoryId: Int64, result: @escaping FlutterResult) {
        guard lifecycleHandler.requireInitialized(result: result) else { return }

        DispatchQueue.main.async {
            guard let rootVC = self.uiContext?.rootViewController() else {
                ZendeskNativeResult<Void>.failure(
                    code: ZendeskSdkErrorCodes.noUiContext,
                    message: "No root view controller found"
                ).complete(result)
                return
            }

            let requestConfig = RequestUiConfiguration()
            requestConfig.tags = self.session.user.baseTags()

            let helpCenterConfig = HelpCenterUiConfiguration()
            helpCenterConfig.showContactOptions = true
            helpCenterConfig.groupType = .category
            helpCenterConfig.groupIds = [NSNumber(value: categoryId)]

            let helpCenterVC = HelpCenterUi.buildHelpCenterOverviewUi(
                withConfigs: [helpCenterConfig, requestConfig]
            )

            self.presentWithCloseButton(rootVC: rootVC, viewController: helpCenterVC, result: result)
        }
    }

    func sendUserInformationForTicket(request: ZendeskTicketRequest) -> ZendeskNativeResult<Void> {
        .failure(code: ZendeskSdkErrorCodes.launchFailed, message: "Use sendUserInformationForTicketAsync")
    }

    func sendUserInformationForTicketAsync(
        request: ZendeskTicketRequest,
        result: @escaping FlutterResult
    ) {
        guard lifecycleHandler.requireInitialized(result: result) else { return }

        DispatchQueue.main.async {
            guard let rootVC = self.uiContext?.rootViewController() else {
                ZendeskNativeResult<Void>.failure(
                    code: ZendeskSdkErrorCodes.noUiContext,
                    message: "No root view controller found"
                ).complete(result)
                return
            }

            self.session.user = request.user

            let requestConfig = RequestUiConfiguration()
            requestConfig.tags = request.user.baseTags(tripId: request.tripId)
            if !request.customFields.isEmpty {
                requestConfig.customFields = request.customFields.map { $0.toNative() }
            }

            let requestVC = RequestUi.buildRequestUi(with: [requestConfig])
            let navController = UINavigationController(rootViewController: requestVC)
            navController.modalPresentationStyle = .fullScreen

            let closeButton = UIBarButtonItem(
                barButtonSystemItem: .done,
                target: self.pluginHost,
                action: #selector(ZendeskPluginHost.dismissHelpCenter)
            )
            requestVC.navigationItem.rightBarButtonItem = closeButton

            rootVC.present(navController, animated: true) {
                result(nil)
            }
        }
    }

    func showListOfTickets() -> ZendeskNativeResult<Void> {
        .failure(code: ZendeskSdkErrorCodes.launchFailed, message: "Use showListOfTicketsAsync")
    }

    func showListOfTicketsAsync(result: @escaping FlutterResult) {
        guard lifecycleHandler.requireInitialized(result: result) else { return }

        DispatchQueue.main.async {
            guard let rootVC = self.uiContext?.rootViewController() else {
                ZendeskNativeResult<Void>.failure(
                    code: ZendeskSdkErrorCodes.noUiContext,
                    message: "No root view controller found"
                ).complete(result)
                return
            }

            let requestListController = RequestUi.buildRequestList()
            if let navController = rootVC as? UINavigationController {
                navController.pushViewController(requestListController, animated: true)
            } else {
                let navController = UINavigationController(rootViewController: requestListController)
                navController.modalPresentationStyle = .fullScreen
                rootVC.present(navController, animated: true, completion: nil)
            }
            result(nil)
        }
    }

    func startChatBot() -> ZendeskNativeResult<Void> {
        .failure(code: ZendeskSdkErrorCodes.answerBotError, message: "Use startChatBotAsync")
    }

    func startChatBotAsync(result: @escaping FlutterResult) {
        guard lifecycleHandler.requireInitialized(result: result) else { return }

        DispatchQueue.main.async {
            guard let rootVC = self.uiContext?.rootViewController() else {
                ZendeskNativeResult<Void>.failure(
                    code: ZendeskSdkErrorCodes.noUiContext,
                    message: "No root view controller found"
                ).complete(result)
                return
            }

            Support.initialize(withZendesk: Zendesk.instance)
            AnswerBot.initialize(withZendesk: Zendesk.instance, support: Support.instance!)

            do {
                let answerBotEngine = try AnswerBotEngine.engine()
                let messagingConfig = MessagingConfiguration()

                let answerBotVC = try Messaging.instance.buildUI(
                    engines: [answerBotEngine],
                    configs: [messagingConfig]
                )

                let navController = UINavigationController(rootViewController: answerBotVC)
                navController.modalPresentationStyle = .fullScreen
                navController.setNavigationBarHidden(false, animated: false)

                let closeButton = UIBarButtonItem(
                    barButtonSystemItem: .done,
                    target: self.pluginHost,
                    action: #selector(ZendeskPluginHost.dismissHelpCenter)
                )
                answerBotVC.navigationItem.rightBarButtonItem = closeButton

                rootVC.present(navController, animated: true) {
                    result(nil)
                }
            } catch {
                result(
                    FlutterError(
                        code: ZendeskSdkErrorCodes.answerBotError,
                        message: "Failed to launch Answer Bot",
                        details: error.localizedDescription
                    )
                )
            }
        }
    }

    private func presentWithCloseButton(
        rootVC: UIViewController,
        viewController: UIViewController,
        result: @escaping FlutterResult
    ) {
        let navController = UINavigationController(rootViewController: viewController)
        navController.modalPresentationStyle = .fullScreen

        let closeButton = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: pluginHost,
            action: #selector(ZendeskPluginHost.dismissHelpCenter)
        )
        viewController.navigationItem.rightBarButtonItem = closeButton
        rootVC.present(navController, animated: true) {
            result(nil)
        }
    }
}
