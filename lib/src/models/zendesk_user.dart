/// Immutable end-user identity passed to Zendesk (Encapsulation + Value Object).
class ZendeskUser {
  const ZendeskUser({
    required this.name,
    required this.emailId,
    required this.userId,
    required this.userType,
  });

  final String name;
  final String emailId;
  final String userId;
  final String userType;

  Map<String, dynamic> toChannelArguments() => {
        'name': name,
        'emailId': emailId,
        'userId': userId,
        'userType': userType,
      };

  ZendeskUser copyWith({
    String? name,
    String? emailId,
    String? userId,
    String? userType,
  }) {
    return ZendeskUser(
      name: name ?? this.name,
      emailId: emailId ?? this.emailId,
      userId: userId ?? this.userId,
      userType: userType ?? this.userType,
    );
  }
}
