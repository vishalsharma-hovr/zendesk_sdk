/// Mutable plugin session state shared across native handlers.
final class ZendeskSession {
    var user: ZendeskUser = .empty
    var isSupportInitialized = false

    func clear() {
        user = .empty
        isSupportInitialized = false
    }
}
