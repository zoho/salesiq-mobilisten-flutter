// ignore_for_file: public_member_api_docs

import 'package:flutter/services.dart';

import 'salesiq_mobilisten.dart';

/// Provides APIs to manage the visitor's information.
/// Access this via [ZohoSalesIQ.visitor].
class Visitor {
  final MethodChannel _channel = const MethodChannel('salesiq_visitor_module');

  /// Updates the visitor's profile using the given [profile].
  ///
  /// Replaces the individual `setVisitorName`/`setVisitorEmail`/
  /// `setVisitorContactNumber`/`setVisitorAddInfo`/`setVisitorLocation` APIs.
  Future<void> updateProfile(SalesIQVisitorProfile profile) {
    return _channel.invokeMethod('updateVisitorProfile', profile.toMap());
  }

  /// Performs a custom action using the action name provided in [actionName].
  Future<void> performCustomAction(String actionName) {
    return _channel.invokeMethod('performCustomAction', <String, dynamic>{
      'action_name': actionName,
    });
  }
}

/// Salutation of the visitor.
enum Salutation { none, mr, ms, mrs, dr, prof }

/// The visitor's phone number with its country [code].
class SIQVisitorPhoneNumber {
  /// The country dialing code.
  final String code;

  /// The phone number, without the country code.
  final String number;

  /// Creates a phone number from the country [code] and [number].
  const SIQVisitorPhoneNumber({this.code = "", required this.number});

  /// Serializes this phone number to a map for the native bridge.
  Map<String, dynamic> toMap() => {'code': code, 'number': number};
}

/// The visitor's profile, applied using [Visitor.updateProfile].
class SalesIQVisitorProfile {
  /// The visitor's salutation.
  final Salutation? salutation;

  /// The visitor's first name.
  final String? firstName;

  /// The visitor's last name.
  final String? lastName;

  /// The visitor's email address.
  final String? email;

  /// The visitor's phone number.
  final SIQVisitorPhoneNumber? phone;

  /// The visitor's unique user ID. Applies only for iOS.
  final String? userId;

  /// Custom information associated with the visitor.
  final Map<String, String>? customInfo;

  /// The visitor's secondary location.
  final SIQVisitorLocation? location;

  const SalesIQVisitorProfile({
    this.salutation,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.userId,
    this.customInfo,
    this.location,
  });

  /// Serializes this visitor profile to a map for the native bridge.
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = <String, dynamic>{};
    if (salutation != null) map['salutation'] = salutation!.name;
    if (firstName != null) map['firstName'] = firstName;
    if (lastName != null) map['lastName'] = lastName;
    if (email != null) map['email'] = email;
    if (phone != null) map['phone'] = phone!.toMap();
    if (userId != null) map['userID'] = userId;
    if (customInfo != null) map['customInfo'] = customInfo;
    if (location != null) {
      map['location'] = <String, dynamic>{
        'latitude': location!.latitude,
        'longitude': location!.longitude,
        'city': location!.city,
        'state': location!.state,
        'country': location!.country,
        'countryCode': location!.countryCode,
        'zipCode': location!.zipCode,
      };
    }
    return map;
  }
}
