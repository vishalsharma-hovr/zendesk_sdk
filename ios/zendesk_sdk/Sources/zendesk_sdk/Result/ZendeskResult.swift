import Flutter

/// Typed native result mirroring Dart ZendeskResult.
enum ZendeskNativeResult<T> {
    case success(T)
    case failure(code: String, message: String?)

    func complete(_ result: @escaping FlutterResult) {
        switch self {
        case .success(let value):
            result(value)
        case .failure(let code, let message):
            result(FlutterError(code: code, message: message, details: nil))
        }
    }
}
