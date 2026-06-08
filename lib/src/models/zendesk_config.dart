/// Immutable Zendesk account configuration (Encapsulation + Value Object).
class ZendeskConfig {
  const ZendeskConfig({
    required this.url,
    required this.appId,
    required this.clientId,
  });

  final String url;
  final String appId;
  final String clientId;

  Map<String, dynamic> toChannelArguments() => {
        'zendeskUrl': url,
        'appId': appId,
        'clientId': clientId,
      };
}
