// create constructor
class SignupDetails {
  final String Email;
  final String id;
  final String password;

  SignupDetails({
    required this.Email,
    required this.id,
    required this.password,
  });

  // Corrected fromJson constructor
 SignupDetails.fromJson(Map<String, Object?> json) : this(
   Email: json['Email'] ! as String,
   id: json['id'] ! as String,
   password: json['password'] ! as String,
 );


  SignupDetails copyWith({
    String? Email,
    String? id,
    String? password,
  }) {
    return SignupDetails(
      Email: Email ?? this.Email,
      id: id ?? this.id,
      password: password ?? this.password,
    );
  }
  Map<String, Object?> toJson() {
    return {
      'Email': Email,
      'id': id,
      'password': password,
    };
  }
}
