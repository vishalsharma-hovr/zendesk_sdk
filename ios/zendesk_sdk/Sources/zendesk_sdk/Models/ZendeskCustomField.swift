import SupportProvidersSDK

/// Ticket custom field value object.
struct ZendeskCustomFieldModel {
    let fieldId: Int64
    let value: String

    func toNative() -> CustomField {
        CustomField(fieldId: fieldId, value: value)
    }

    static func list(from args: [String: Any]) -> [ZendeskCustomFieldModel] {
        guard let customFieldsArg = args[ZendeskSdkChannel.Argument.customFields] as? [[String: Any]] else {
            return []
        }

        return customFieldsArg.compactMap { field in
            guard let fieldIdNumber = field[ZendeskSdkChannel.Argument.fieldId] as? NSNumber,
                  let value = field[ZendeskSdkChannel.Argument.value] as? String else {
                return nil
            }
            return ZendeskCustomFieldModel(fieldId: fieldIdNumber.int64Value, value: value)
        }
    }
}
