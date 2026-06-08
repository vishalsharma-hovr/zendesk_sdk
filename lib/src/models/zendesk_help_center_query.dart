import 'zendesk_user.dart';

/// Help Center navigation intent (Polymorphism via sealed subtypes).
sealed class ZendeskHelpCenterQuery {
  const ZendeskHelpCenterQuery(this.user);

  final ZendeskUser user;
}

/// Opens Help Center filtered by category IDs.
final class CategoryListHelpCenterQuery extends ZendeskHelpCenterQuery {
  const CategoryListHelpCenterQuery({
    required ZendeskUser user,
    required this.categoryIdList,
  }) : super(user);

  final List<int> categoryIdList;
}

/// Opens a single article by numeric ID.
final class ArticleHelpCenterQuery extends ZendeskHelpCenterQuery {
  const ArticleHelpCenterQuery({
    required ZendeskUser user,
    required this.articleId,
  }) : super(user);

  final String articleId;
}

/// Opens Help Center for one category ID.
final class CategoryHelpCenterQuery extends ZendeskHelpCenterQuery {
  const CategoryHelpCenterQuery({
    required ZendeskUser user,
    required this.categoryId,
  }) : super(user);

  final String categoryId;
}
