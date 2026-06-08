/// A Zendesk ticket custom field passed from Dart to native platforms.
class ZendeskCustomField {
  const ZendeskCustomField({
    required this.fieldId,
    required this.value,
  });

  final int fieldId;
  final String value;

  Map<String, dynamic> toJson() => {
        'fieldId': fieldId,
        'value': value,
      };
}
