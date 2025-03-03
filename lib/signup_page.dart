import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tamar_attendence/firebase_options.dart';
import 'package:tamar_attendence/models/signupdetails.dart';

const String userCollection = 'Employees';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference _usersCollection;

  DatabaseService() {
    _usersCollection = _firestore.collection(userCollection).withConverter<SignupDetails>(
      fromFirestore: (snapshot, _) => SignupDetails.fromJson(snapshot.data()!),
      toFirestore: (user, _) => user.toJson(),
    );
  }

  Stream<QuerySnapshot> getEmployees() {
    return _usersCollection.snapshots();
  }

  Future<void> addEmployee(SignupDetails employee) async {
    await _usersCollection.add(employee);
  }
}

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  void _registerUser() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match!')),
      );
      return;
    }

    try {
      // 1️.Create User in Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2️. Get Firebase User ID
      String uid = userCredential.user!.uid;

      // 3️.Add User to Firestore
      SignupDetails newUser = SignupDetails(
        Email: _emailController.text.trim(),
        id: uid, // Store Firebase UID instead of manually entered ID
        password: _passwordController.text.trim(),
      );

      await _databaseService.addEmployee(newUser);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User Registered Successfully!')),
      );
      Navigator.pushNamed(context, 'login_screen');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      print("❌ Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: MediaQuery
                        .of(context)
                        .size
                        .height * 0.1), // Keeps content balanced
                    Center(
                      child: Image.asset(
                        'assets/tamar.png', // Replace with your logo asset path
                        height: 75,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Sign Up in Attendity',
                      style: TextStyle(
                          fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Container(height: 2, width: 50, color: Colors.blueAccent),
                    SizedBox(height: 16),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Employee Email',
                        border: OutlineInputBorder(borderRadius: BorderRadius
                            .circular(8.0)),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _idController,
                      decoration: InputDecoration(
                        labelText: 'Employee ID',
                        border: OutlineInputBorder(borderRadius: BorderRadius
                            .circular(8.0)),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: !_passwordVisible,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(borderRadius: BorderRadius
                            .circular(8.0)),
                        suffixIcon: IconButton(
                          icon: Icon(_passwordVisible ? Icons.visibility : Icons
                              .visibility_off),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: !_confirmPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        border: OutlineInputBorder(borderRadius: BorderRadius
                            .circular(8.0)),
                        suffixIcon: IconButton(
                          icon: Icon(
                              _confirmPasswordVisible ? Icons.visibility : Icons
                                  .visibility_off),
                          onPressed: () {
                            setState(() {
                              _confirmPasswordVisible =
                              !_confirmPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _registerUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0)),
                        ),
                        child: Text(
                          'Sign Up',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already have an account?"),
                        TextButton(
                          child: Text("Login"),
                          onPressed: () {
                            Navigator.pushNamed(context, 'login_screen');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}