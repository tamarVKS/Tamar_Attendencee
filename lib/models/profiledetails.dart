class ProfileDetails{

  final String attendance;
  final String designation;
  final String email;
  final String hour;
  final String late;
  final String leave;
  final String name;

  ProfileDetails({
    required this.attendance,
    required this.designation,
    required this.email,
    required this.hour,
    required this.late,
    required this.leave,
    required this.name
  });

  // corrected fromJson Constructor
ProfileDetails.fromJson(Map<String, dynamic> json): this(
    attendance: json['attendance'] ! as String,
    designation: json['designation'] ! as String,
    email: json['email'] ! as String,
    hour: json['hour']! as String,
    late: json['late']! as String,
   name: json['name']! as String,
   leave: json['leave']! as String,
);

  ProfileDetails copyWith({
    String? attendance,
    String? designation,
    String? email,
    String? hour,
    String? late,
    String? leave,
    String ? name,
  }) {
    return ProfileDetails(
      attendance: attendance ?? this.attendance,
      designation: designation ?? this.designation,
      email: email ?? this.email,
      hour: hour ?? this.hour,
      late: late ?? this.late,
      leave: leave ?? this.leave,
      name: name ?? this.name,
    );
  }
  Map<String, Object?> toJson() {
    return {
      'attendance': attendance,
      'designation': designation,
      'email': email,
      'hour': hour,
      'late': late,
      'leave': leave,
      'name': name,
    };
  }


}