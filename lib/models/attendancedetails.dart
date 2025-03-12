import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceDetails {
  final Timestamp date;
  final String name;
  final Timestamp clockIn;
  final Timestamp clockOut;

  AttendanceDetails({
    required this.date,
    required this.name,
    required this.clockIn,
    required this.clockOut,
  });

  // Corrected fromJson Constructor
  AttendanceDetails.fromJson(Map<String, dynamic> json): this(
    date: json['date']! as Timestamp,
    name: json['name']! as String,
    clockIn: json['clockIn']! as Timestamp,
    clockOut: json['clockOut']! as Timestamp,
  );

  AttendanceDetails copyWith({
    Timestamp? date,
    String? name,
    Timestamp? clockIn,
    Timestamp? clockOut,
  }) {
    return AttendanceDetails(
      date: date ?? this.date,
      name: name ?? this.name,
      clockIn: clockIn ?? this.clockIn,
      clockOut: clockOut ?? this.clockOut,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'date': date,
      'name': name,
      'clockIn': clockIn,
      'clockOut': clockOut,
    };
  }
}
