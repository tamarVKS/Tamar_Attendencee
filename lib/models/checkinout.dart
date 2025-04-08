import 'package:cloud_firestore/cloud_firestore.dart';

class CheckInOutDetails {
  String? id;
  String name;
  Timestamp checkin;
  Timestamp? checkout;            // ✅ Made checkout nullable
  String? location;               // ✅ Added location field
  String? checkoutLocation;       // ✅ Added checkoutLocation field
  bool isLate;                    // ✅ Added isLate field

  CheckInOutDetails({
    this.id,
    required this.name,
    required this.checkin,
    this.checkout,
    this.location,
    this.checkoutLocation,
    required this.isLate,         // ✅ Required isLate in constructor
  });

  // ✅ fromJson constructor
  CheckInOutDetails.fromJson(Map<String, Object?> json)
      : id = json['id'] as String?,
        name = json['name']! as String,
        checkin = json['checkin']! as Timestamp,
        checkout = json['checkout'] as Timestamp?,
        location = json['location'] as String?,
        checkoutLocation = json['checkoutLocation'] as String?,
        isLate = json['isLate'] as bool? ?? false; // ✅ Default to false if null

  // ✅ toJson method (including location, checkoutLocation, isLate)
  Map<String, Object?> toJson() {
    return {
      'id': id,
      'name': name,
      'checkin': checkin,
      'checkout': checkout,
      'location': location,
      'checkoutLocation': checkoutLocation,
      'isLate': isLate,
    };
  }

  // ✅ copyWith method
  CheckInOutDetails copyWith({
    String? id,
    String? name,
    Timestamp? checkin,
    Timestamp? checkout,
    String? location,
    String? checkoutLocation,
    bool? isLate,
  }) {
    return CheckInOutDetails(
      id: id ?? this.id,
      name: name ?? this.name,
      checkin: checkin ?? this.checkin,
      checkout: checkout ?? this.checkout,
      location: location ?? this.location,
      checkoutLocation: checkoutLocation ?? this.checkoutLocation,
      isLate: isLate ?? this.isLate,
    );
  }
}