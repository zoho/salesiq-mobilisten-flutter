import 'package:flutter/services.dart';

import 'mobilisten_date_time.dart';

class KnowledgeBase {
  final MethodChannel _channel = const MethodChannel("salesiq_knowledge_base");

  final eventChannel = EventChannel("mobilisten_knowledge_base_events")
      .receiveBroadcastStream()
      .map((event) => KnowledgeBaseEvent(
          ResourceAction.from(event["eventName"]),
          _getResourceType(event["type"]),
          _getResource(event["resource"] as Map?)));

  Future<Null> setVisibility(ResourceType type, bool shouldShow) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("type", () => type.index);
    args.putIfAbsent("should_show", () => shouldShow);
    await _channel.invokeMethod('setVisibility', args);
  }

  Future<Null> combineDepartments(ResourceType type, bool merge) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("type", () => type.index);
    args.putIfAbsent("merge", () => merge);
    await _channel.invokeMethod('combineDepartments', args);
  }

  Future<Null> categorize(ResourceType type, bool shouldCategorize) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("type", () => type.index);
    args.putIfAbsent("should_categorize", () => shouldCategorize);
    await _channel.invokeMethod('categorize', args);
  }

  Future<bool> isEnabled(ResourceType type) async {
    Map<String, dynamic> arguments = <String, dynamic>{};
    arguments.putIfAbsent("type", () => type.index);
    return await _channel.invokeMethod('isEnabled', arguments);
  }

  Future<Resource?> getSingleResource(ResourceType type, String id) async {
    // bool shouldFallbackToDefaultLanguage
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("type", () => type.index);
    args.putIfAbsent("id", () => id);
    // args.putIfAbsent("should_fallback_to_default_language",
    //     () => shouldFallbackToDefaultLanguage);
    return _getResource(await _channel.invokeMethod('getSingleResource', args));
  }

  Result _getResourceResult(Map map) {
    List<Resource?> resources = [];

    List<Object?> resourcesMapList = map["resources"] as List<Object?>;
    bool moreDataAvailable = map["more_data_available"];

    resourcesMapList.forEach((resource) {
      resources.add(_getResource(resource as Map));
    });
    return Result(resources, moreDataAvailable);
  }

  static Resource? _getResource(Map? map) {
    if (map != null) {
      String? id = map["id"];

      Map<String, dynamic> categoryMap =
          Map<String, dynamic>.from(map["category"]);
      SIQResourceCategory? category =
          SIQResourceCategory(id: categoryMap["id"], name: categoryMap["name"]);

      String? title = map["title"];
      String? departmentID = map["departmentId"];

      Map<String, dynamic> languageMap =
          Map<String, dynamic>.from(map["language"]);
      Language? language =
          Language(id: languageMap["id"], code: languageMap["code"]);

      User? creator = (map["creator"] as Map)._toUser();
      User? modifier = (map["modifier"] as Map)._toUser();

      double? createdTimeMS = map["createdTime"];
      double? modifiedTimeMS = map["modifiedTime"];
      DateTime? createdTime =
          DateTimeUtils.convertDoubleToDateTime(createdTimeMS);
      DateTime? modifiedTime =
          DateTimeUtils.convertDoubleToDateTime(modifiedTimeMS);
      String? publicUrl = map["publicUrl"];

      Map<String, dynamic> statsMap = Map<String, dynamic>.from(map["stats"]);
      Stats? stats = Stats(
          liked: statsMap["liked"],
          disliked: statsMap["disliked"],
          used: statsMap["used"],
          viewed: statsMap["viewed"]);

      String? content = map["content"];
      String rateString = map["ratedType"] ?? "none";
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
    } else {
      return null;
    }
  }

  void setRecentlyViewedCount(int limit) {
    _channel.invokeMethod('setRecentlyViewedCount', limit);
  }

  Future<bool> open(ResourceType type, String id) async {
    int rawValue = type.index;
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("type", () => rawValue);
    args.putIfAbsent("id", () => id);
    return await _channel.invokeMethod('openResource', args);
  }

  Future<Result> getResources(ResourceType type,
      {String? departmentId,
      String? parentCategoryId,
      String? searchKey,
      int page = 1,
      int limit = 99}) async {
    int rawValue = type.index;
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("type", () => rawValue);

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

    return _getCategoryList(await _channel.invokeMethod('getCategories', args));
  }

  Future<List<ResourceDepartment>> getResourceDepartments() async {
    final List departmentList =
        await _channel.invokeMethod('getResourceDepartments');
    return _getResourceDepartmentList(departmentList);
  }

  static List<ResourceCategory> _getCategoryList(List mapList) {
    List<ResourceCategory> categoryList = [];
    for (int i = 0; i < mapList.length; i++) {
      Map map = mapList[i];
      String? id = map["id"];
      String? name = map["name"];
      String? departmentId = map["departmentId"];
      num? count = map["count"];
      num? childrenCount = map["childrenCount"];
      num? order = map["order"];
      String? parentCategoryId = map["parentCategoryId"];

      double? modifiedTimeMS = map["resourceModifiedTime"];
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

  static List<ResourceDepartment> _getResourceDepartmentList(List mapList) {
    List<ResourceDepartment> departmentList = [];
    for (int i = 0; i < mapList.length; i++) {
      Map map = mapList[i];
      String? id = map["id"];
      String? name = map["name"];
      ResourceDepartment department = ResourceDepartment(id: id, name: name);
      departmentList.add(department);
    }
    return departmentList;
  }

  static ResourceType? _getResourceType(int index) {
    if (index == 0) {
      return ResourceType.articles;
    } else {
      return null;
    }
  }
}

enum ResourceType { articles }

class Result {
  bool moreDataAvailable;
  List<Resource?> resources;

  Result(this.resources, this.moreDataAvailable);
}

class Resource {
  String? id;
  SIQResourceCategory? category;
  String? title;
  String? departmentId;
  Language? language;
  User? creator;
  User? modifier;
  DateTime? createdTime;
  DateTime? modifiedTime;
  String? publicUrl;
  Stats? stats;
  String? content;
  RatedType ratedType = RatedType.none;

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

class SIQResourceCategory {
  String? id;
  String? name;

  SIQResourceCategory({this.id, this.name});
}

class Language {
  String? id;
  String? code;

  Language({this.id, this.code});
}

class User {
  String? id;
  String? name;
  String? email;
  String? displayName;
  String? imageUrl;

  User({this.id, this.name, this.email, this.displayName, this.imageUrl});
}

class Stats {
  num? liked;
  num? disliked;
  num? used;
  num? viewed;

  Stats({this.liked, this.disliked, this.used, this.viewed});
}

class ResourceCategory {
  String? id;
  String? name;
  String? departmentId;
  num? count;
  num? childrenCount;
  num? order;
  String? parentCategoryId;
  DateTime? resourceModifiedTime;

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

class ResourceDepartment {
  String? id;
  String? name;

  ResourceDepartment({this.id, this.name});
}

enum RatedType { liked, disliked, none }

extension RatedTypeString on RatedType {
  static const Map<RatedType, String> _stringValues = const {
    RatedType.liked: "liked",
    RatedType.disliked: "disliked",
    RatedType.none: "none",
  };

  String toShortString() {
    var code = RatedTypeString._stringValues[this];
    if (code == null) {
      return "none";
    }
    return code;
  }

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

extension UserParsing on Map {
  User _toUser() {
    return User(
        id: this["id"],
        name: this["name"],
        email: this["email"],
        displayName: this["displayName"],
        imageUrl: this["imageUrl"]);
  }
}

class KnowledgeBaseEvent {
  ResourceAction? action;
  ResourceType? type;
  Resource? resource;

  KnowledgeBaseEvent(this.action, this.type, this.resource);
}

class ResourceAction {
  const ResourceAction._(this.value);

  final String value;

  static const ResourceAction opened = ResourceAction._("resourceOpened");
  static const ResourceAction closed = ResourceAction._("resourceClosed");
  static const ResourceAction liked = ResourceAction._("resourceLiked");
  static const ResourceAction disliked = ResourceAction._("resourceDisliked");

  static ResourceAction? from(String value) {
    if (value == opened.value) {
      return opened;
    } else if (value == closed.value) {
      return closed;
    } else if (value == liked.value) {
      return liked;
    } else if (value == disliked.value) {
      return disliked;
    } else {
      return null;
    }
  }
}
