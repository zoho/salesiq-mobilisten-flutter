import 'package:flutter/services.dart';

import 'mobilisten_date_time.dart';

/// Entry point for the knowledge base — controlling resource visibility,
/// fetching articles and their categories, opening resources and subscribing
/// to resource events. Accessed via [ZohoSalesIQ.knowledgeBase].
class KnowledgeBase {
  final MethodChannel _channel = const MethodChannel("salesiq_knowledge_base");

  /// Broadcast stream of knowledge base [KnowledgeBaseEvent]s, emitted when a
  /// visitor opens, closes, likes or dislikes a resource.
  final eventChannel = EventChannel("mobilisten_knowledge_base_events")
      .receiveBroadcastStream()
      .map((event) => KnowledgeBaseEvent(
          ResourceAction.from(event["eventName"] as String),
          _getResourceType(event["type"] as int),
          _getResource(event["resource"] as Map?),
          KnowledgeBaseErrorInfo.fromMap(
              event["error"] as Map<dynamic, dynamic>)));

  /// Shows or hides resources of the given [type], based on the value
  /// provided for [shouldShow].
  void setVisibility(ResourceType type, bool shouldShow) {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("type", () => type.index);
    args.putIfAbsent("should_show", () => shouldShow);
    _channel.invokeMethod('setVisibility', args);
  }

  /// Combines resources of the given [type] across departments when [merge]
  /// is `true`, otherwise keeps them grouped per department.
  void combineDepartments(ResourceType type, bool merge) {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("type", () => type.index);
    args.putIfAbsent("merge", () => merge);
    _channel.invokeMethod('combineDepartments', args);
  }

  /// Enables or disables categorized display of resources of the given
  /// [type], based on the value provided for [shouldCategorize].
  void categorize(ResourceType type, bool shouldCategorize) {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("type", () => type.index);
    args.putIfAbsent("should_categorize", () => shouldCategorize);
    _channel.invokeMethod('categorize', args);
  }

  /// Returns whether the resource of the given [type] is enabled.
  Future<bool> isEnabled(ResourceType type) async {
    Map<String, dynamic> arguments = <String, dynamic>{};
    arguments.putIfAbsent("type", () => type.index);
    return await _channel
        .invokeMethod<bool>('isEnabled', arguments)
        .then((value) => value ?? false);
  }

  /// Returns a single resource of the given [type] matching the given [id].
  //
  // [pending iOS support] `shouldFallbackToDefaultLanguage` (falls back to the
  // resource in the default language when it is unavailable in the current
  // language) is handled on Android but has no iOS native support. The
  // parameter and its forwarding are commented out until iOS adds support.
  Future<Resource?> getSingleResource(ResourceType type, String id) async {
    // bool shouldFallbackToDefaultLanguage
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("type", () => type.index);
    args.putIfAbsent("id", () => id);
    // args.putIfAbsent("should_fallback_to_default_language",
    //     () => shouldFallbackToDefaultLanguage);
    return _getResource(await _channel.invokeMethod('getSingleResource', args));
  }

  Result _getResourceResult(Map? map) {
    if (map == null) {
      return Result([], false);
    }

    List<Resource?> resources = [];

    List<Object?>? resourcesMapList = map["resources"] as List<Object?>?;
    bool moreDataAvailable = map["more_data_available"] as bool;

    if (resourcesMapList != null) {
      resourcesMapList.forEach((resource) {
        resources.add(_getResource(resource as Map));
      });
    }
    return Result(resources, moreDataAvailable);
  }

  static Resource? _getResource(Map? map) {
    if (map == null || map.isEmpty) {
      return null;
    }

    String? id = map["id"]?.toString();

    // Category, language, creator, modifier and stats are all optional on a resource, so guard
    // each nested map instead of an unconditional `as Map` cast — a null field (e.g. a resource
    // with no language or no department) would otherwise throw and fail the whole resource,
    // leaving every field (department, language, …) blank.
    final categoryRaw = map["category"];
    SIQResourceCategory? category;
    if (categoryRaw is Map) {
      final categoryMap = Map<String, dynamic>.from(categoryRaw);
      category = SIQResourceCategory(
          id: categoryMap["id"]?.toString(),
          name: categoryMap["name"]?.toString());
    }

    String? title = map["title"]?.toString();
    String? departmentID = map["departmentId"]?.toString();

    final languageRaw = map["language"];
    Language? language;
    if (languageRaw is Map) {
      final languageMap = Map<String, dynamic>.from(languageRaw);
      language = Language(
          id: languageMap["id"]?.toString(),
          code: languageMap["code"]?.toString());
    }

    User? creator = map["creator"] is Map ? (map["creator"] as Map)._toUser() : null;
    User? modifier = map["modifier"] is Map ? (map["modifier"] as Map)._toUser() : null;

    // Tolerate the timestamp arriving as either int or double over the method channel — a bare
    // `as double?` throws on an int and would null the whole resource.
    double? createdTimeMS = (map["createdTime"] as num?)?.toDouble();
    double? modifiedTimeMS = (map["modifiedTime"] as num?)?.toDouble();
    DateTime? createdTime =
        DateTimeUtils.convertDoubleToDateTime(createdTimeMS);
    DateTime? modifiedTime =
        DateTimeUtils.convertDoubleToDateTime(modifiedTimeMS);
    String? publicUrl = map["publicUrl"]?.toString();

    final statsRaw = map["stats"];
    Stats? stats;
    if (statsRaw is Map) {
      final statsMap = Map<String, dynamic>.from(statsRaw);
      stats = Stats(
          liked: statsMap["liked"] as num?,
          disliked: statsMap["disliked"] as num?,
          used: statsMap["used"] as num?,
          viewed: statsMap["viewed"] as num?);
    }

    String? content = map["content"]?.toString();
    String rateString = map["ratedType"]?.toString() ?? "none";
    RatedType ratedTypes = RatedTypeString.toRateType(rateString);

    return Resource(
        id: id,
        category: category,
        title: title,
        departmentId: departmentID,
        language: language,
        creator: creator,
        modifier: modifier,
        createdTime: createdTime,
        modifiedTime: modifiedTime,
        publicUrl: publicUrl,
        stats: stats,
        content: content,
        ratedType: ratedTypes);
  }

  /// Sets the maximum number, [limit], of recently viewed resources retained
  /// and displayed.
  void setRecentlyViewedCount(int limit) {
    _channel.invokeMethod('setRecentlyViewedCount', limit);
  }

  /// Opens the resource of the given [type] identified by [id].
  Future<bool> open(ResourceType type, String id) async {
    int rawValue = type.index;
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("type", () => rawValue);
    args.putIfAbsent("id", () => id);
    return await _channel
        .invokeMethod<bool>('openResource', args)
        .then((value) => value ?? false);
  }

  /// Returns the resources of the given [type].
  ///
  /// Optionally scopes the result to a department via [departmentId] and to a
  /// parent category via [parentCategoryId], and filters by a full-text
  /// [searchKey]. Results are paginated: [page] selects the page (starting at 1)
  /// and [limit] sets the page size (defaults to 99). The returned [Result]
  /// exposes the fetched page via its resources list and whether more pages
  /// remain via its moreDataAvailable flag.
  ///
  /// Each resource in the list omits its body content, which is `null` here;
  /// call [getSingleResource] to fetch a single resource with its full content.
  //
  // [pending iOS support] `includeChildCategoryResources` (includes resources
  // belonging to child categories of [parentCategoryId]) is handled on Android
  // but has no iOS native support. The parameter and its forwarding are
  // commented out until iOS adds support.
  Future<Result> getResources(ResourceType type,
      {String? departmentId,
      String? parentCategoryId,
      String? searchKey,
      int page = 1,
      int limit = 99}) async {
    int rawValue = type.index;
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("type", () => rawValue);
    // args.putIfAbsent("include_child_category_resources",
    //     () => includeChildCategoryResources);

    if (departmentId != null) {
      args.putIfAbsent("departmentId", () => departmentId);
    }

    if (parentCategoryId != null) {
      args.putIfAbsent("parentCategoryId", () => parentCategoryId);
    }

    if (searchKey != null) {
      args.putIfAbsent("searchKey", () => searchKey);
    }

    args.putIfAbsent("page", () => page);
    args.putIfAbsent("limit", () => limit);

    return _getResourceResult(
        await _channel.invokeMethod('getResources', args));
  }

  /// Returns the resource categories of the given [type].
  ///
  /// Optionally scopes the result to a department via [departmentId] and to
  /// the children of a category via [parentCategoryId].
  Future<List<ResourceCategory>> getCategories(ResourceType type,
      {String? departmentId, String? parentCategoryId}) async {
    int rawValue = type.index;
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("type", () => rawValue);

    if (departmentId != null) {
      args.putIfAbsent("departmentId", () => departmentId);
    }

    if (parentCategoryId != null) {
      args.putIfAbsent("parentCategoryId", () => parentCategoryId);
    }

    return _getCategoryList(
        await _channel.invokeMethod<List<dynamic>>('getCategories', args));
  }

  /// Returns the resource departments associated with the brand, as configured
  /// under the brand's flow control settings.
  Future<List<ResourceDepartment>> getResourceDepartments() async {
    final List<dynamic>? departmentList =
        await _channel.invokeMethod<List<dynamic>>('getResourceDepartments');
    return _getResourceDepartmentList(departmentList);
  }

  static List<ResourceCategory> _getCategoryList(List? mapList) {
    if (mapList == null) {
      return [];
    }
    List<ResourceCategory> categoryList = [];
    for (int i = 0; i < mapList.length; i++) {
      Map? map = mapList[i] as Map?;
      String? id = map?["id"]?.toString();
      String? name = map?["name"]?.toString();
      String? departmentId = map?["departmentId"]?.toString();
      num? count = map?["count"] as num;
      num? childrenCount = map?["childrenCount"] as num;
      num? order = map?["order"] as num;
      String? parentCategoryId = map?["parentCategoryId"]?.toString();

      double? modifiedTimeMS = map?["resourceModifiedTime"] as double?;
      DateTime? modifiedTime =
          DateTimeUtils.convertDoubleToDateTime(modifiedTimeMS);

      ResourceCategory category = ResourceCategory(
        id: id,
        name: name,
        departmentId: departmentId,
        count: count,
        childrenCount: childrenCount,
        order: order,
        parentCategoryId: parentCategoryId,
        resourceModifiedTime: modifiedTime,
      );
      categoryList.add(category);
    }

    return categoryList;
  }

  static List<ResourceDepartment> _getResourceDepartmentList(List? mapList) {
    if (mapList == null) {
      return [];
    }
    List<ResourceDepartment> departmentList = [];
    for (int i = 0; i < mapList.length; i++) {
      Map? map = mapList[i] as Map?;
      String? id = map?["id"]?.toString();
      String? name = map?["name"]?.toString();
      ResourceDepartment department = ResourceDepartment(id: id, name: name);
      departmentList.add(department);
    }
    return departmentList;
  }

  static ResourceType? _getResourceType(int index) {
    if (index == 0) {
      return ResourceType.articles;
      // FAQs is pending the iOS native implementation. Uncomment when iOS supports it:
      // } else if (index == 1) {
      //   return ResourceType.faqs;
    } else {
      return null;
    }
  }
}

/// The type of knowledge base resource a [KnowledgeBase] API operates on.
enum ResourceType {
  /// Knowledge base articles.
  articles,

  // FAQs is pending the iOS native implementation. Uncomment when iOS supports it.
  // /// Frequently asked questions.
  // faqs,
}

/// The result of a resource fetch, holding the fetched page and whether more
/// data is available beyond the requested page limit.
class Result {
  /// `true` when more resources exist beyond the requested page limit.
  bool moreDataAvailable;

  /// The fetched page of resources.
  List<Resource?> resources;

  /// Creates a [Result] from the fetched [resources] and the
  /// [moreDataAvailable] flag.
  Result(this.resources, this.moreDataAvailable);
}

/// A knowledge base resource (article) and its metadata.
class Resource {
  /// The resource's unique identifier.
  String? id;

  /// The category the resource belongs to.
  SIQResourceCategory? category;

  /// The resource's title.
  String? title;

  /// The identifier of the department the resource belongs to.
  String? departmentId;

  /// The language of the resource.
  Language? language;

  /// The user who created the resource.
  User? creator;

  /// The user who last modified the resource.
  User? modifier;

  /// The time the resource was created.
  DateTime? createdTime;

  /// The time the resource was last modified.
  DateTime? modifiedTime;

  /// The public URL of the resource.
  String? publicUrl;

  /// Engagement statistics for the resource.
  Stats? stats;

  /// The resource's body content.
  String? content;

  /// The current visitor's rating on the resource.
  RatedType ratedType = RatedType.none;

  /// Creates a [Resource] with the given metadata.
  Resource({
    this.id,
    this.category,
    this.title,
    this.departmentId,
    this.language,
    this.creator,
    this.modifier,
    this.createdTime,
    this.modifiedTime,
    this.publicUrl,
    this.stats,
    this.content,
    this.ratedType = RatedType.none,
  });
}

/// The category a [Resource] belongs to.
class SIQResourceCategory {
  /// The category's unique identifier.
  String? id;

  /// The category's name.
  String? name;

  /// Creates a [SIQResourceCategory] with the given [id] and [name].
  SIQResourceCategory({this.id, this.name});
}

/// The language of a [Resource].
class Language {
  /// The language's unique identifier.
  String? id;

  /// The language code.
  String? code;

  /// Creates a [Language] with the given [id] and [code].
  Language({this.id, this.code});
}

/// A user (operator) referenced by a [Resource], such as its creator or
/// modifier.
class User {
  /// The user's unique identifier.
  String? id;

  /// The user's name.
  String? name;

  /// The user's email address.
  String? email;

  /// The user's display name.
  String? displayName;

  /// The URL of the user's image.
  String? imageUrl;

  /// Creates a [User] with the given details.
  User({this.id, this.name, this.email, this.displayName, this.imageUrl});
}

/// Engagement statistics for a [Resource].
class Stats {
  /// The number of likes.
  num? liked;

  /// The number of dislikes.
  num? disliked;

  /// The number of times the resource was used.
  num? used;

  /// The number of times the resource was viewed.
  num? viewed;

  /// Creates a [Stats] with the given engagement counts.
  Stats({this.liked, this.disliked, this.used, this.viewed});
}

/// A knowledge base resource (article) category.
class ResourceCategory {
  /// The category's unique identifier.
  String? id;

  /// The category's name.
  String? name;

  /// The identifier of the department the category belongs to.
  String? departmentId;

  /// The number of resources in the category.
  num? count;

  /// The number of child categories.
  num? childrenCount;

  /// The display order of the category.
  num? order;

  /// The identifier of the parent category, if this is a sub-category.
  String? parentCategoryId;

  /// The time a resource in the category was last modified.
  DateTime? resourceModifiedTime;

  /// Creates a [ResourceCategory] with the given metadata.
  ResourceCategory({
    this.id,
    this.name,
    this.departmentId,
    this.count,
    this.childrenCount,
    this.order,
    this.parentCategoryId,
    this.resourceModifiedTime,
  });
}

/// A department under which knowledge base resources are grouped.
class ResourceDepartment {
  /// The department's unique identifier.
  String? id;

  /// The department's name.
  String? name;

  /// Creates a [ResourceDepartment] with the given [id] and [name].
  ResourceDepartment({this.id, this.name});
}

/// The current visitor's rating on a [Resource].
enum RatedType {
  /// The visitor liked the resource.
  liked,

  /// The visitor disliked the resource.
  disliked,

  /// The visitor has not rated the resource.
  none
}

/// Conversion helpers between [RatedType] and its native string value.
extension RatedTypeString on RatedType {
  static const Map<RatedType, String> _stringValues = const {
    RatedType.liked: "liked",
    RatedType.disliked: "disliked",
    RatedType.none: "none",
  };

  /// Returns the native string value for this rated type.
  String toShortString() {
    var code = RatedTypeString._stringValues[this];
    if (code == null) {
      return "none";
    }
    return code;
  }

  /// Returns the [RatedType] matching the native [rateString], defaulting to
  /// [RatedType.none] when unrecognized.
  static RatedType toRateType(String rateString) {
    var valueList = RatedType.values;
    for (var i = 0; i < valueList.length; i++) {
      var rateType = valueList[i];
      if (rateString == rateType.toShortString()) {
        return rateType;
      }
    }
    return RatedType.none;
  }
}

/// Parses a native map into a [User].
extension UserParsing on Map {
  User _toUser() {
    return User(
        id: this["id"]?.toString(),
        name: this["name"]?.toString(),
        email: this["email"]?.toString(),
        displayName: this["displayName"]?.toString(),
        imageUrl: this["imageUrl"]?.toString());
  }
}

/// A knowledge base resource event delivered on [KnowledgeBase.eventChannel],
/// describing a visitor action such as opening, closing, liking or disliking a
/// resource.
class KnowledgeBaseEvent {
  /// The resource action that occurred.
  ResourceAction? action;

  /// The type of the affected resource.
  ResourceType? type;

  /// The affected resource.
  Resource? resource;

  /// Error details, present when the action is [ResourceAction.error].
  KnowledgeBaseErrorInfo? errorInfo;

  /// Creates a [KnowledgeBaseEvent] from the [action], [type], [resource] and
  /// [errorInfo].
  KnowledgeBaseEvent(this.action, this.type, this.resource, this.errorInfo);
}

/// Error details carried by a [KnowledgeBaseEvent] when a resource action
/// fails.
class KnowledgeBaseErrorInfo {
  /// A human-readable description of the error.
  final String message;

  /// The error code.
  final int code;

  /// The error type identifier.
  final String type;

  /// Creates a [KnowledgeBaseErrorInfo] with the given [message], [code] and
  /// [type].
  KnowledgeBaseErrorInfo(this.message, this.code, this.type);

  /// Builds a [KnowledgeBaseErrorInfo] from the native error [data] map.
  static KnowledgeBaseErrorInfo fromMap(Map<dynamic, dynamic> data) {
    String type = data["type"];
    int code = data["code"] ?? -1;
    String message = data["message"] ?? "";

    return KnowledgeBaseErrorInfo(message, code, type);
  }
}

/// The visitor action a [KnowledgeBaseEvent] reports on a resource.
class ResourceAction {
  const ResourceAction._(this.value);

  /// The raw event name backing this action.
  final String value;

  /// The visitor opened a resource.
  static const ResourceAction opened = ResourceAction._("resourceOpened");

  /// The visitor closed a resource.
  static const ResourceAction closed = ResourceAction._("resourceClosed");

  /// The visitor liked a resource.
  static const ResourceAction liked = ResourceAction._("resourceLiked");

  /// The visitor disliked a resource.
  static const ResourceAction disliked = ResourceAction._("resourceDisliked");

  /// A resource action failed; see [KnowledgeBaseEvent.errorInfo].
  static const ResourceAction error = ResourceAction._("resourceError");

  /// Returns the [ResourceAction] matching the raw event [value], or `null`
  /// if it is unrecognized.
  static ResourceAction? from(String value) {
    if (value == opened.value) {
      return opened;
    } else if (value == closed.value) {
      return closed;
    } else if (value == liked.value) {
      return liked;
    } else if (value == disliked.value) {
      return disliked;
    } else if (value == error.value) {
      return error;
    } else {
      return null;
    }
  }
}
