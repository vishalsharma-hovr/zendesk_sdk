/// Lifecycle operations: initialize, logout, readiness (Interface Segregation).
abstract class ZendeskLifecyclePlatform {
  Future<void> initialize({
    required String url,
    required String appId,
    required String clientId,
    required String name,
    required String emailId,
    required String userId,
    required String userType,
  });

  Future<void> logout();

  Future<bool> isInitialized();
}
