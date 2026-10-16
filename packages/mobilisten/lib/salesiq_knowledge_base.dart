import 'package:flutter/services.dart';

import 'mobilisten_date_time.dart';

/// Provides the APIs for the Knowledge Base. With it, you can control the
/// visibility of resources, get articles and their categories, open resources,
/// and listen to resource events. To use it, call [ZohoSalesIQ.knowledgeBase].
class KnowledgeBase {
  final MethodChannel _channel = const MethodChannel("salesiq_knowledge_base");

  /// The broadcast stream of Knowledge Base [KnowledgeBaseEvent]s. It sends an
  /// event when a visitor opens, closes, likes, or dislikes a resource.
  final eventChannel = EventChannel("mobilisten_knowledge_base_events")
      .receiveBroadcastStream()
      .map((event) => KnowledgeBaseEvent(
          ResourceAction.from(event["eventName"] as String),
          _getResourceType(event["type"] as int),
          _getResource(event["resource"] as Map?),
          KnowledgeBaseErrorInfo.fromMap(
              event["error"] as Map<dynamic, dynamic>)));

  /// Shows or hides resources of the given [type], based on the value of
  /// [shouldShow].
  void setVisibility(ResourceType type, bool shouldShow) {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("type", () => type.index);
    args.putIfAbsent("should_show", () => shouldShow);
    _channel.invokeMethod('setVisibility', args);
  }

  /// Combines resources of the given [type] from all departments when [merge]
  /// is `true`. Otherwise, it keeps them grouped by department.
  void combineDepartments(ResourceType type, bool merge) {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("type", () => type.index);
    args.putIfAbsent("merge", () => merge);
    _channel.invokeMethod('combineDepartments', args);
  }

  /// Turns the grouping of resources of the given [type] into categories on or
  /// off, based on the value of [shouldCategorize].
  void categorize(ResourceType type, bool shouldCategorize) {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("type", () => type.index);
    args.putIfAbsent("should_categorize", () => shouldCategorize);
    _channel.invokeMethod('categorize', args);
  }

  /// Returns whether resources of the given [type] are enabled.
  Future<bool> isEnabled(ResourceType type) async {
    Map<String, dynamic> arguments = <String, dynamic>{};
    arguments.putIfAbsent("type", () => type.index);
    return await _channel
        .invokeMethod<bool>('isEnabled', arguments)
        .then((value) => value ?? false);
  }

  /// Returns one resource of the given [type] that matches the given [id].
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

  /// Sets [limit], the maximum number of recently viewed resources that the SDK
  /// keeps and shows.
  void setRecentlyViewedCount(int limit) {
    _channel.invokeMethod('setRecentlyViewedCount', limit);
  }

  /// Opens the resource of the given [type] that [id] identifies.
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
  /// To return only the resources of a department, pass [departmentId]. To
  /// return only the resources under a parent category, pass
  /// [parentCategoryId]. To filter the results with a full-text search, pass
  /// [searchKey].
  ///
  /// The results come in pages. [page] selects the page, starting at 1, and
  /// [limit] sets the page size. The default page size is 99. The returned
  /// [Result] holds the fetched page in its `resources` list. Its
  /// `moreDataAvailable` flag tells you whether more pages remain.
  ///
  /// The resources in the list do not include their body content, which is
  /// `null` here. To get one resource with its full content, call
  /// [getSingleResource].
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
  /// To return only the categories of a department, pass [departmentId]. To
  /// return only the child categories of a category, pass [parentCategoryId].
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

  /// Returns the resource departments of the brand, as they are set in the flow
  /// control settings of the brand.
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

/// Defines the type of Knowledge Base resource that a [KnowledgeBase] API works
/// on.
enum ResourceType {
  /// Knowledge Base articles.
  articles,

  // FAQs is pending the iOS native implementation. Uncomment when iOS supports it.
  // /// Frequently asked questions.
  // faqs,
}

/// The result of a resource fetch. It holds the fetched page, and whether more
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

/// A Knowledge Base resource, such as an article, and its metadata.
class Resource {
  /// The unique ID of the resource.
  String? id;

  /// The category that the resource belongs to.
  SIQResourceCategory? category;

  /// The title of the resource.
  String? title;

  /// The ID of the department that the resource belongs to.
  String? departmentId;

  /// The language of the resource.
  Language? language;

  /// The operator who created the resource.
  User? creator;

  /// The operator who last modified the resource.
  User? modifier;

  /// The time when the resource was created.
  DateTime? createdTime;

  /// The time when the resource was last modified.
  DateTime? modifiedTime;

  /// The public URL of the resource.
  String? publicUrl;

  /// The engagement statistics of the resource.
  Stats? stats;

  /// The body content of the resource.
  String? content;

  /// The current visitor's rating of the resource.
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

/// The category that a [Resource] belongs to.
class SIQResourceCategory {
  /// The unique ID of the category.
  String? id;

  /// The name of the category.
  String? name;

  /// Creates a [SIQResourceCategory] with the given [id] and [name].
  SIQResourceCategory({this.id, this.name});
}

/// The language of a [Resource].
class Language {
  /// The unique ID of the language.
  String? id;

  /// The language code.
  String? code;

  /// Creates a [Language] with the given [id] and [code].
  Language({this.id, this.code});
}

/// An operator that a [Resource] refers to, such as the operator who created it
/// or last modified it.
class User {
  /// The unique ID of the user.
  String? id;

  /// The name of the user.
  String? name;

  /// The email address of the user.
  String? email;

  /// The display name of the user.
  String? displayName;

  /// The URL of the user's image.
  String? imageUrl;

  /// Creates a [User] with the given details.
  User({this.id, this.name, this.email, this.displayName, this.imageUrl});
}

/// The engagement statistics of a [Resource].
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

/// A category of Knowledge Base resources, such as articles.
class ResourceCategory {
  /// The unique ID of the category.
  String? id;

  /// The name of the category.
  String? name;

  /// The ID of the department that the category belongs to.
  String? departmentId;

  /// The number of resources in the category.
  num? count;

  /// The number of child categories.
  num? childrenCount;

  /// The display order of the category.
  num? order;

  /// The ID of the parent category, if this is a subcategory.
  String? parentCategoryId;

  /// The time when a resource in the category was last modified.
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

/// A department that groups Knowledge Base resources.
class ResourceDepartment {
  /// The unique ID of the department.
  String? id;

  /// The name of the department.
  String? name;

  /// Creates a [ResourceDepartment] with the given [id] and [name].
  ResourceDepartment({this.id, this.name});
}

/// Defines the current visitor's rating of a [Resource].
enum RatedType {
  /// The visitor liked the resource.
  liked,

  /// The visitor disliked the resource.
  disliked,

  /// The visitor has not rated the resource.
  none
}

/// Converts between [RatedType] and its native string value.
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

  /// Returns the [RatedType] that matches the native [rateString]. If the value
  /// is not recognized, it returns [RatedType.none].
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

/// A Knowledge Base resource event that [KnowledgeBase.eventChannel] sends. It
/// describes a visitor action, such as opening, closing, liking, or disliking a
/// resource.
class KnowledgeBaseEvent {
  /// The resource action that occurred.
  ResourceAction? action;

  /// The type of the resource that the action affected.
  ResourceType? type;

  /// The resource that the action affected.
  Resource? resource;

  /// The error details, when the action is [ResourceAction.error].
  KnowledgeBaseErrorInfo? errorInfo;

  /// Creates a [KnowledgeBaseEvent] from the [action], [type], [resource], and
  /// [errorInfo].
  KnowledgeBaseEvent(this.action, this.type, this.resource, this.errorInfo);
}

/// The error details that a [KnowledgeBaseEvent] carries when a resource action
/// fails.
class KnowledgeBaseErrorInfo {
  /// A readable description of the error.
  final String message;

  /// The error code.
  final int code;

  /// The ID of the error type.
  final String type;

  /// Creates a [KnowledgeBaseErrorInfo] with the given [message], [code], and
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

/// The visitor action on a resource that a [KnowledgeBaseEvent] reports.
class ResourceAction {
  const ResourceAction._(this.value);

  /// The raw event name behind this action.
  final String value;

  /// The visitor opened a resource.
  static const ResourceAction opened = ResourceAction._("resourceOpened");

  /// The visitor closed a resource.
  static const ResourceAction closed = ResourceAction._("resourceClosed");

  /// The visitor liked a resource.
  static const ResourceAction liked = ResourceAction._("resourceLiked");

  /// The visitor disliked a resource.
  static const ResourceAction disliked = ResourceAction._("resourceDisliked");

  /// A resource action failed. For details, see [KnowledgeBaseEvent.errorInfo].
  static const ResourceAction error = ResourceAction._("resourceError");

  /// Returns the [ResourceAction] that matches the raw event [value], or `null`
  /// if it is not recognized.
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
