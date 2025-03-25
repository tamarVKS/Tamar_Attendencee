import 'package:cloud_firestore/cloud_firestore.dart';

class CheckInOutDetails {
  String? id;
  String name;
  Timestamp checkin;
  Timestamp? checkout;            // ✅ Made checkout nullable
  String? location;               // ✅ Added location field
  String? checkoutLocation;       // ✅ Added checkoutLocation field

  CheckInOutDetails({
    this.id,
    required this.name,
    required this.checkin,
    this.checkout,                // ✅ Made checkout nullable
    this.location,
    this.checkoutLocation,        // ✅ Added checkoutLocation to constructor
  });

  // ✅ fromJson constructor
  CheckInOutDetails.fromJson(Map<String, Object?> json)
      : id = json['id'] as String?,
        name = json['name']! as String,
        checkin = json['checkin']! as Timestamp,
        checkout = json['checkout'] as Timestamp?,               // ✅ Nullable checkout
        location = json['location'] as String?,                   // ✅ Map location field
        checkoutLocation = json['checkoutLocation'] as String?;   // ✅ Map checkoutLocation field

  // ✅ toJson method (including location and checkoutLocation)
  Map<String, Object?> toJson() {
    return {
      'id': id,
      'name': name,
      'checkin': checkin,
      'checkout': checkout,
      'location': location,
      'checkoutLocation': checkoutLocation,     // ✅ Added checkoutLocation
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
  }) {
    return CheckInOutDetails(
      id: id ?? this.id,
      name: name ?? this.name,
      checkin: checkin ?? this.checkin,
      checkout: checkout ?? this.checkout,
      location: location ?? this.location,
      checkoutLocation: checkoutLocation ?? this.checkoutLocation,
    );
  }
}
