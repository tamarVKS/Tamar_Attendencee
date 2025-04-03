class ProfileDetails{

  final name;
  final email;
  final phone;
  final address;
  final department;
  final joiningDate;
  final dateofbirth;
  final position;
  final education;
  final EmployeeID;
  final profileImage;

  ProfileDetails({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.department,
    required this.joiningDate,
    required this.dateofbirth,
    required this.position,
    required this.education,
    required this.EmployeeID,
    required this.profileImage,
  });

  // corrected fromJson Constructor
ProfileDetails.fromJson(Map<String, dynamic> json): this(
    name: json['name'] ! as String,
    email: json['email'] ! as String,
    phone: json['phone'] ! as String,
    address: json['address'] ! as String,
    department: json['department'] ! as String,
    joiningDate: json['joiningDate'] ! as String,
    dateofbirth: json['dateofbirth'] ! as String,
    position: json['position'] ! as String,
    education: json['education'] ! as String,
    EmployeeID: json['EmployeeID'] ! as String,
    profileImage: json['profileImage'] ! as String,

);


  ProfileDetails copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? department,
    String? joiningDate,
    String? dateofbirth,
    String? position,
    String? education,
    String? EmployeeID,
    String? profileImage,
  }) {
    return ProfileDetails(
      name:  name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address:address?? this.address,
      department: department ?? this.department,
      joiningDate: joiningDate ?? this.joiningDate,
      dateofbirth: dateofbirth ?? this.dateofbirth,
      position: position ?? this.position,
      education: education ?? this.education,
      EmployeeID: EmployeeID ?? this.EmployeeID,
      profileImage: profileImage ?? this.profileImage,

    );
  }
  Map<String, Object?> toJson() {
    return {
      'name':name,
      'email':email,
      'phone':phone,
      'address':address,
      'department':department,
      'joiningDate':joiningDate,
      'dateofbirth':dateofbirth,
      'position':position,
      'education':education,
      'EmployeeID':EmployeeID,
      'profileImage':profileImage,
    };

  }


}