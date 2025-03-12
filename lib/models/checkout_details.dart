import 'package:cloud_firestore/cloud_firestore.dart';

class CheckOut{
  final Timestamp ? checkout;

  CheckOut({
    this.checkout,
  });
/// Factory constructor to safely parse JSON and handle null values
  factory CheckOut.fromJson (Map<String, dynamic> json) {
    return CheckOut(
      checkout: json['checkout'] != null ? json['checkout'] as Timestamp : null,
    );
  }


  CheckOut copyWith({
    Timestamp? checkout,
  }) {
    return CheckOut(
      checkout: checkout ?? this.checkout,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'checkout': checkout,
    };
  }



}