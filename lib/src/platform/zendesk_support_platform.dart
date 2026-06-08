import '../zendesk_custom_field.dart';

/// Support SDK operations: Help Center and tickets (Interface Segregation).
abstract class ZendeskSupportPlatform {
  Future<void> showHelpCenter({
    required String name,
    required String emailId,
    required String userId,
    required List<int> categoryIdList,
  });

  Future<void> showHelpCenterArticleId({required String articleId});

  Future<void> showHelpCenterCategoryId({required String categoryId});

  Future<void> sendUserInformationForTicket({
    required String name,
    required String emailId,
    required String userId,
    required String tripId,
    List<ZendeskCustomField> customFields = const [],
  });

  Future<void> startChatBot();

  Future<void> showListOfTickets({
    required String name,
    required String emailId,
    required String userId,
    required String tripId,
  });
}
