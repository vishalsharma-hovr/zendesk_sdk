/// Shared MethodChannel contract between Dart and native platforms.
abstract final class ZendeskSdkChannel {
  static const String name = 'zendesk_sdk';

  static const String methodInitialize = 'initialize';
  static const String methodShowHelpCenter = 'showHelpCenter';
  static const String methodShowHelpCenterArticleId = 'showHelpCenterArticleId';
  static const String methodShowHelpCenterCategoryId = 'showHelpCenterCategoryId';
  static const String methodSendUserInformationForTicket =
      'sendUserInformationForTicket';
  static const String methodStartChatBot = 'startChatBot';
  static const String methodShowListOfTickets = 'showListOfTickets';
  static const String methodStartChat = 'startChat';

  static const String argZendeskUrl = 'zendeskUrl';
  static const String argAppId = 'appId';
  static const String argClientId = 'clientId';
  static const String argName = 'name';
  static const String argEmailId = 'emailId';
  static const String argUserId = 'userId';
  static const String argUserType = 'userType';
  static const String argCategoryIdList = 'categoryIdList';
  static const String argArticleId = 'articleId';
  static const String argCategoryId = 'categoryId';
  static const String argTripId = 'tripId';
  static const String argChannelId = 'channelId';
  static const String argCustomFields = 'customFields';
}
