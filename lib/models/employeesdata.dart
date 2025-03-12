class Employeesdata{
  final String name;
  final String email;
  final String number;
  final String department;
  final String jobtitle;
  final String password;
  final String retypepassword;


  Employeesdata({
    required this.name,
    required this.email,
    required this.number,
    required this.department,
    required this.jobtitle,
    required this.password,
    required this.retypepassword
  });

  // corrected fromJson Constructor
  Employeesdata.fromJson(Map<String,Object?> json): this(
     name: json['name']! as String,
     email: json['email']! as String,
     number: json['number']! as String,
     department: json['department']! as String,
     jobtitle: json['jobtitle']! as String,
     password: json['password']! as String,
     retypepassword: json['retypepassword'] ! as String,
  );

  Employeesdata copyWith({
    String? name,
    String? email,
    String? number,
    String? department,
    String? jobtitle,
    String? password,
    String? retypepassword,
  }){
    return Employeesdata(
      name: name ?? this.name,
      email: email ?? this.email,
      number: number ?? this.number,
      department: department ?? this.department,
      jobtitle: jobtitle ?? this.jobtitle,
      password: password ?? this. password,
      retypepassword: retypepassword ?? this. retypepassword,
    );
  }

  Map<String, Object?> toJson(){
    return {
      'name': name,
      'email': email,
      'number': number,
      'department': department,
      'jobtitle': jobtitle,
      'password': password,
      'retypepassword': retypepassword,
    };
  }


}