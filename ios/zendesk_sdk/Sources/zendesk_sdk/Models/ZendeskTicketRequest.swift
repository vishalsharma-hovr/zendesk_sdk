import Flutter

/// Ticket submission context combining [user], [tripId], and optional fields.
struct ZendeskTicketRequest {
    let user: ZendeskUser
    let tripId: String
    let customFields: [ZendeskCustomFieldModel]

    static func from(call: FlutterMethodCall) -> ZendeskTicketRequest? {
        guard let args = call.arguments as? [String: Any],
              let tripId = args[ZendeskSdkChannel.Argument.tripId] as? String,
              !tripId.isEmpty
        else {
            return nil
        }

        let user = ZendeskUser.from(call: call)
        if user.userId.isEmpty {
            return nil
        }

        return ZendeskTicketRequest(
            user: user,
            tripId: tripId,
            customFields: ZendeskCustomFieldModel.list(from: args)
        )
    }
}
