class SalesIQAuth {
  Map<String, dynamic> toMap() => {};
}

class SalesIQUser extends SalesIQAuth {
  final String userId;

  SalesIQUser({required this.userId});

  @override
  Map<String, dynamic> toMap() =>
      {'type': 'registered_visitor', 'user_id': userId};
}

class SalesIQGuestUser extends SalesIQAuth {
  @override
  Map<String, dynamic> toMap() => {'type': 'guest'};
}
