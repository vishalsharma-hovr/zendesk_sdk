import 'zendesk_sdk_platform_interface.dart';

class ZendeskSdk {
  Future<void> initialize({required String url, required String appId, required String clientId, required String name, required String emailId, required String userId}) {
    return ZendeskSdkPlatform.instance.initialize(url: url, appId: appId, clientId: clientId, name: name, emailId: emailId, userId: userId);
  }

  Future<void> showHelpCenter({required String name, required String emailId, required String userId, required List<int> categoryIdList}) {
    return ZendeskSdkPlatform.instance.showHelpCenter(name: name, emailId: emailId, userId: userId, categoryIdList: categoryIdList);
  }

  Future<void> startChatBot() {
    return ZendeskSdkPlatform.instance.startChatBot();
  }

  Future<void> showHelpWithArticleId({required String articleId}) {
    return ZendeskSdkPlatform.instance.showHelpCenterArticleId(articleId: articleId);
  }

  Future<void> showHelpWithCategoryId({required String categoryId}) {
    return ZendeskSdkPlatform.instance.showHelpCenterCategoryId(categoryId: categoryId);
  }

  Future<void> sendUserInformationForTicket({required String name, required String emailId, required String userId, required String tripId}) {
    return ZendeskSdkPlatform.instance.sendUserInformationForTicket(name: name, emailId: emailId, userId: userId, tripId: tripId);
  }

  Future<void> showListOfTickets({required String name, required String emailId, required String userId, required String tripId}) {
    return ZendeskSdkPlatform.instance.showListOfTickets(name: name, emailId: emailId, userId: userId, tripId: tripId);
  }

  Future<void> startChat({required String name, required String emailId, required String phoneNumber}) {
    return ZendeskSdkPlatform.instance.startChat(name: name, emailId: emailId, phoneNumber: phoneNumber);
  }
}
