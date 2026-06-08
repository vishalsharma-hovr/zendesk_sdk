import UIKit

/// Provides root view controller access to handlers (DIP).
protocol ZendeskUiContextProviding: AnyObject {
    func rootViewController() -> UIViewController?
}

final class ZendeskUiContext: ZendeskUiContextProviding {
    func rootViewController() -> UIViewController? {
        if #available(iOS 13.0, *) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else {
                return nil
            }
            return window.rootViewController
        } else {
            return UIApplication.shared.keyWindow?.rootViewController
        }
    }
}
