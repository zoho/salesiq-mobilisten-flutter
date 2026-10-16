// ignore_for_file: public_member_api_docs

/// The base class for the data that identifies the visitor. You use it when
/// you respond to a visitor registration failure event.
class SalesIQAuth {
  /// Converts this authentication data to a map for the native bridge.
  Map<String, dynamic> toMap() => {};
}

/// A registered visitor, who has logged in and is identified by [userId].
class SalesIQUser extends SalesIQAuth {
  /// The unique ID of the registered visitor.
  final String userId;

  /// Creates the authentication data of a registered visitor with the given
  /// [userId].
  SalesIQUser({required this.userId});

  /// Converts this authentication data to a map for the native bridge.
  @override
  Map<String, dynamic> toMap() =>
      {'type': 'registered_visitor', 'user_id': userId};
}

/// An anonymous guest visitor.
class SalesIQGuestUser extends SalesIQAuth {
  /// Converts this authentication data to a map for the native bridge.
  @override
  Map<String, dynamic> toMap() => {'type': 'guest'};
}

// [pending support] JWT-based authentication is commented out until it is
// supported across the native SDKs. Uncomment when it lands.
//
// /// JWT-based authentication using the given [token].
// class SalesIQJWTAuth extends SalesIQAuth {
//   /// The JWT used to authenticate the user.
//   final String token;
//
//   /// Creates a JWT-based authentication using the given [token].
//   SalesIQJWTAuth({required this.token});
//
//   /// Serializes this authentication data to a map for the native bridge.
//   @override
//   Map<String, dynamic> toMap() => {'type': 'jwt', 'token': token};
// }
