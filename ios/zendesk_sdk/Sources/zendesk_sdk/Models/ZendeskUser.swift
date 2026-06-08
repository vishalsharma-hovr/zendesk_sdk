import Flutter

/// Immutable end-user identity passed to Zendesk (Value Object).
struct ZendeskUser {
    let name: String
    let emailId: String
    let userId: String
    let userType: String

    static let empty = ZendeskUser(name: "", emailId: "", userId: "", userType: "")

    var combinedName: String {
        "\(name) | UserID: \(userId)"
    }

    func baseTags(tripId: String? = nil) -> [String] {
        var tags = ["user_id:\(userId)", "mobile_app"]
        if !userType.isEmpty {
            tags.append("user_type:\(userType)")
        }
        if let tripId, !tripId.isEmpty {
            tags.append("trip_id:\(tripId)")
        }
        return tags
    }

    static func from(call: FlutterMethodCall) -> ZendeskUser {
        let args = call.arguments as? [String: Any]
        return ZendeskUser(
            name: args?[ZendeskSdkChannel.Argument.name] as? String ?? "",
            emailId: args?[ZendeskSdkChannel.Argument.emailId] as? String ?? "",
            userId: args?[ZendeskSdkChannel.Argument.userId] as? String ?? "",
            userType: args?[ZendeskSdkChannel.Argument.userType] as? String ?? ""
        )
    }
}
