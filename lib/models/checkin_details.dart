import 'package:cloud_firestore/cloud_firestore.dart';

class CheckIn {
  final Timestamp? checkin;
  final Timestamp? checkout;
  final String? name;
  final String ? id;
  final String? location;

  CheckIn({
    this.checkin,
    this.checkout,
    this.id,
    this.name,
    this.location
  });

  /// Factory constructor to safely parse JSON and handle null values
  factory CheckIn.fromJson(Map<String, dynamic> json) {
    return CheckIn(
      checkin: json['checkin'] != null ? json['checkin'] as Timestamp : null,
      checkout: json['checkout'] != null ? json['checkout'] as Timestamp : null,
      id: json['id'] != null ? json['id'] as String : null,
      name: json['name'] != null ? json['name'] as String : null,
      location: json['location'] != null ? json['location'] as String : null,
    );
  }

  /// Creates a copy of the current CheckIn instance with optional new values
  CheckIn copyWith({
    Timestamp? checkin,
    Timestamp? checkout,
    String? name,
    String? id,
  }) {
    return CheckIn(
      checkin: checkin ?? this.checkin,
      checkout: checkout ?? this.checkout,
      name: name ?? this.name,
      id: id ?? this.id,
      location: location ?? this.location,
    );
  }

  /// Converts the CheckIn object to JSON format
  Map<String, dynamic> toJson() {
    return {
      'checkin': checkin,
      'checkout': checkout,
      'name': name,
      'id': id,
      'location': location,

    };
  }
}


