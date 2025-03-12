import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tamar_attendence/models/profiledetails.dart';
import 'package:tamar_attendence/services/profile_services.dart';

class PersonalInformationScreen extends StatefulWidget {
  @override
  _PersonalInformationScreenState createState() => _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  final DatabaseService _databaseService = DatabaseService();

  User? _user;
  File? _profileImage;
  bool _isLoading = false;
  ProfileDetails? _profileDetails;
  final Map<String, TextEditingController> controllers = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    _user = _auth.currentUser;
    if (_user != null) {
      controllers.clear();

      final docSnapshot = await FirebaseFirestore.instance.collection('ProfileInformation').doc(_user!.uid).get();
      if (docSnapshot.exists) {
        setState(() {
          _profileDetails = ProfileDetails.fromJson(docSnapshot.data()!);
        });

        controllers['Name'] = TextEditingController(text: _profileDetails?.name ?? '');
        controllers['Employee ID'] = TextEditingController(text: _profileDetails?.EmployeeID ?? '');
        controllers['Email'] = TextEditingController(text: _profileDetails?.email ?? '');
        controllers['Phone'] = TextEditingController(text: _profileDetails?.phone ?? '');
        controllers['Date of Birth'] = TextEditingController(text: _profileDetails?.dateofbirth ?? '');
        controllers['Address'] = TextEditingController(text: _profileDetails?.address ?? '');
        controllers['Department'] = TextEditingController(text: _profileDetails?.department ?? '');
        controllers['Joining Date'] = TextEditingController(text: _profileDetails?.joiningDate ?? '');
        controllers['Position'] = TextEditingController(text: _profileDetails?.position ?? '');
        controllers['Education'] = TextEditingController(text: _profileDetails?.education ?? '');
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      setState(() {
        _profileImage = imageFile;
      });

      if (_user != null) {
        String filePath = 'profile_images/${_user!.uid}.jpg';
        TaskSnapshot uploadTask = await FirebaseStorage.instance.ref(filePath).putFile(imageFile);
        String downloadUrl = await uploadTask.ref.getDownloadURL();

        setState(() {
          _profileDetails = _profileDetails?.copyWith(profileImage: downloadUrl);
        });

        await _databaseService.addData(_profileDetails!);
      }
    }
  }

  Future<void> _saveUserData() async {
    if (_user != null && _profileDetails != null) {
      setState(() {
        _isLoading = true;
      });

      final updatedProfile = _profileDetails!.copyWith(
        name: controllers['Name']?.text ?? '',
        EmployeeID: controllers['Employee ID']?.text ?? '',
        email: controllers['Email']?.text ?? '',
        phone: controllers['Phone']?.text ?? '',
        dateofbirth: controllers['Date of Birth']?.text ?? '',
        address: controllers['Address']?.text ?? '',
        department: controllers['Department']?.text ?? '',
        joiningDate: controllers['Joining Date']?.text ?? '',
        position: controllers['Position']?.text ?? '',
        education: controllers['Education']?.text ?? '',
      );

      await _databaseService.addData(updatedProfile);

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile updated successfully!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Personal Information"),
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: _profileDetails?.profileImage != null && _profileDetails!.profileImage!.isNotEmpty
                      ? NetworkImage(_profileDetails!.profileImage!)
                      : AssetImage('assets/new.png') as ImageProvider,
                ),
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.camera_alt, color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Text(
              _profileDetails?.name ?? 'New User',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              _profileDetails?.position ?? 'Not Assigned',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 20),
            ...controllers.entries.map((entry) => _buildInfoTile(entry.key, entry.value)).toList(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveUserData,
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Save'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, TextEditingController controller) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: ListTile(
        title: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: title, border: InputBorder.none),
        ),
      ),
    );
  }
}