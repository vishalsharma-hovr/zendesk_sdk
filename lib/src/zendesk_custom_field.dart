/// A Zendesk ticket custom field passed from Dart to native platforms.
class ZendeskCustomField {
  /// Creates a custom field for ticket submission.
  const ZendeskCustomField({
    required this.fieldId,
    required this.value,
  });

  /// The Zendesk custom field ID configured in your Zendesk admin.
  final int fieldId;

  /// The value to assign to [fieldId] on the ticket.
  final String value;

  Map<String, dynamic> toJson() => {
        'fieldId': fieldId,
        'value': value,
      };
}
