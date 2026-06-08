import '../zendesk_custom_field.dart';
import 'zendesk_user.dart';

/// Ticket submission context combining [user], [tripId], and optional fields.
class ZendeskTicketRequest {
  const ZendeskTicketRequest({
    required this.user,
    required this.tripId,
    this.customFields = const [],
  });

  final ZendeskUser user;
  final String tripId;
  final List<ZendeskCustomField> customFields;

  Map<String, dynamic> toChannelArguments() => {
        ...user.toChannelArguments(),
        'tripId': tripId,
        'customFields': customFields.map((field) => field.toJson()).toList(),
      };
}
