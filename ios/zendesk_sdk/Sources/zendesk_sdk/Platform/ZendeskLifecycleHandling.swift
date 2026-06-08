/// Lifecycle operations: initialize, logout, isInitialized (ISP).
protocol ZendeskLifecycleHandling {
    func initialize(config: ZendeskConfig, user: ZendeskUser) -> ZendeskNativeResult<Void>
    func isInitialized() -> ZendeskNativeResult<Bool>
}
