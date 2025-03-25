class SignupDetails {
  final String id;   // Add the id field
  final String Email;
  final String password;

  SignupDetails({
    required this.id,        // Include the id field
    required this.Email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,               // Include id in Firestore document
      'Email': Email,
      'password': password,
    };
  }

  factory SignupDetails.fromJson(Map<String, dynamic> json) {
    return SignupDetails(
      id: json['id'] ?? '',   // Assign a default empty string if missing
      Email: json['Email'] ?? '',
      password: json['password'] ?? '',
    );
  }
}
