// ignore_for_file: public_member_api_docs

/// Base class for the authentication data used to authenticate the user,
/// either during initialization via `SalesIQConfiguration.auth` or while
/// acknowledging a visitor registration failure event.
class SalesIQAuth {
  /// Serializes this authentication data to a map for the native bridge.
  Map<String, dynamic> toMap() => {};
}

/// A registered (logged-in) user identified by [userId].
class SalesIQUser extends SalesIQAuth {
  /// The unique identifier of the registered user.
  final String userId;

  /// Creates a registered-user authentication for the given [userId].
  SalesIQUser({required this.userId});

  /// Serializes this authentication data to a map for the native bridge.
  @override
  Map<String, dynamic> toMap() =>
      {'type': 'registered_visitor', 'user_id': userId};
}

/// An anonymous guest user.
class SalesIQGuestUser extends SalesIQAuth {
  /// Serializes this authentication data to a map for the native bridge.
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
