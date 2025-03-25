import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PersonalInformationScreen extends StatefulWidget {
  @override
  _PersonalInformationScreenState createState() => _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  User? _user;
  File? _profileImage;
  String? _profileImageUrl;
  bool _isSaving = false;
  bool _isAdmin = false; // 🔥 Admin permission flag

  late Future<void> _loadDataFuture;
  final Map<String, TextEditingController> controllers = {};

  @override
  void initState() {
    super.initState();
    _loadDataFuture = _loadUserData();
  }

  /// ✅ Load User Data and Check Admin Permission
  Future<void> _loadUserData() async {
    _user = _auth.currentUser;

    if (_user != null) {
      // 🔥 Check if the user is an admin
      final adminDoc = await FirebaseFirestore.instance
          .collection('Admins') // Ensure you have an "Admins" collection
          .doc(_user!.uid)
          .get();

      _isAdmin = adminDoc.exists; // Admin if document exists

      // 🔥 Load user profile information
      final docSnapshot = await FirebaseFirestore.instance
          .collection('ProfileInformation')
          .doc(_user!.uid)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        _profileImageUrl = data?['profileImage'] ?? '';

        controllers['Name'] = TextEditingController(text: data?['name'] ?? '');
        controllers['Employee ID'] = TextEditingController(text: data?['EmployeeID'] ?? '');
        controllers['Email'] = TextEditingController(text: data?['email'] ?? '');
        controllers['Phone'] = TextEditingController(text: data?['phone'] ?? '');
        controllers['Date of Birth'] = TextEditingController(text: data?['dateofbirth'] ?? '');
        controllers['Address'] = TextEditingController(text: data?['address'] ?? '');
        controllers['Department'] = TextEditingController(text: data?['department'] ?? '');
        controllers['Joining Date'] = TextEditingController(text: data?['joiningDate'] ?? '');
        controllers['Position'] = TextEditingController(text: data?['position'] ?? '');
        controllers['Employment Type'] = TextEditingController(text: data?['Employment Type'] ?? '');
      } else {
        for (var key in [
          'Name', 'Employee ID', 'Email', 'Phone', 'Date of Birth',
          'Address', 'Department', 'Joining Date', 'Position', 'Employment Type'
        ]) {
          controllers[key] = TextEditingController();
        }
      }
    }
  }

  /// ✅ Pick and Upload Image (Admin Only)
  Future<void> _pickImage() async {
    if (!_isAdmin) return;  // Prevent non-admins from picking an image

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });

      await _uploadImage();
    }
  }

  /// ✅ Upload Image and Save URL (Admin Only)
  Future<void> _uploadImage() async {
    if (_user != null && _profileImage != null && _isAdmin) {
      String filePath = 'profile_images/${_user!.uid}.jpg';

      try {
        TaskSnapshot uploadTask = await FirebaseStorage.instance
            .ref(filePath)
            .putFile(_profileImage!);

        String downloadUrl = await uploadTask.ref.getDownloadURL();

        setState(() {
          _profileImageUrl = downloadUrl;
        });

        await FirebaseFirestore.instance
            .collection('ProfileInformation')
            .doc(_user!.uid)
            .set({'profileImage': _profileImageUrl}, SetOptions(merge: true));

      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }

  /// ✅ Save User Data (Admin Only)
  Future<void> _saveUserData() async {
    if (!_isAdmin || _user == null) return;

    setState(() => _isSaving = true);

    if (_profileImage != null) {
      await _uploadImage();
    }

    final Map<String, dynamic> userData = {
      'name': controllers['Name']?.text ?? '',
      'EmployeeID': controllers['Employee ID']?.text ?? '',
      'email': controllers['Email']?.text ?? '',
      'phone': controllers['Phone']?.text ?? '',
      'dateofbirth': controllers['Date of Birth']?.text ?? '',
      'address': controllers['Address']?.text ?? '',
      'department': controllers['Department']?.text ?? '',
      'joiningDate': controllers['Joining Date']?.text ?? '',
      'position': controllers['Position']?.text ?? '',
      'profileImage': _profileImageUrl ?? ''
    };

    await FirebaseFirestore.instance
        .collection('ProfileInformation')
        .doc(_user!.uid)
        .set(userData, SetOptions(merge: true));

    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Profile updated successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Personal Information"),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
      ),
      body: FutureBuilder(
        future: _loadDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading data"));
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 65,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                          ? NetworkImage(_profileImageUrl!)
                          : AssetImage('assets/new.png') as ImageProvider,
                    ),
                    if (_isAdmin)  // 🔥 Show camera icon only for admins
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
                SizedBox(height: 20),
                ...controllers.entries.map((entry) => _buildTile(entry.key, entry.value)).toList(),
                SizedBox(height: 30),
                if (_isAdmin)  // 🔥 Save button only for admins
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveUserData,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      backgroundColor: Colors.blueAccent,
                      elevation: 5,
                    ),
                    child: _isSaving
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Save', style: TextStyle(fontSize: 18)),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// ✅ Build Profile Tiles (Disabled for non-admins)
  Widget _buildTile(String title, TextEditingController controller) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: TextField(
          controller: controller,
          enabled: _isAdmin, // 🔥 Disable editing for non-admins
          decoration: InputDecoration(
            labelText: title,
            labelStyle: TextStyle(fontSize: 16, color: Colors.black87),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
