import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tamar_attendence/services/database_service.dart';
import 'package:tamar_attendence/models/profiledetails.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseService _databaseService = DatabaseService();

  ProfileDetails? employee;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
    String userEmail = _auth.currentUser?.email ?? '';
    if (userEmail.isNotEmpty) {
      ProfileDetails? fetchedEmployee = await _databaseService.getEmployeeByEmail(userEmail);
      if (mounted) {
        setState(() {
          employee = fetchedEmployee;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("PROFILE")),
      body: employee == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Name: ${employee!.name}"),
            Text("Email: ${employee!.email}"),
            Text("Designation: ${employee!.designation}"),
            Text("Attendance: ${employee!.attendance}"),
          ],
        ),
      ),
    );
  }
}
