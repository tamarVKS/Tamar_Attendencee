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
  bool _isAdmin = false;

  late Future<void> _loadDataFuture;
  final Map<String, TextEditingController> controllers = {};

  @override
  void initState() {
    super.initState();
    _loadDataFuture = _loadUserData();
  }

  Future<void> _loadUserData() async {
    _user = _auth.currentUser;

    if (_user != null) {
      final adminDoc = await FirebaseFirestore.instance
          .collection('Admins')
          .doc(_user!.uid)
          .get();
      _isAdmin = adminDoc.exists;

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

  Future<void> _pickImage() async {
    if (!_isAdmin) return;

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      await _uploadImage();
    }
  }

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

  Future<void> _saveUserData() async {
    if (!_isAdmin || _user == null) return;

    setState(() => _isSaving = true);
    if (_profileImage != null) await _uploadImage();

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
      'Employment Type': controllers['Employment Type']?.text ?? '',
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
      backgroundColor: const Color(0xFF001F3F),
      appBar: AppBar(
        title: const Text("Personal Information"),
        backgroundColor: const Color(0xFF003459),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: _loadDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error loading data", style: TextStyle(color: Colors.redAccent)));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 65,
                      backgroundColor: Colors.grey[400],
                      backgroundImage: _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                          ? NetworkImage(_profileImageUrl!)
                          : AssetImage('assets/new.png') as ImageProvider,
                    ),
                    if (_isAdmin)
                      GestureDetector(
                        onTap: _pickImage,
                        child: const CircleAvatar(
                          radius: 20,
                          backgroundColor: Color(0xFFFFD700),
                          child: Icon(Icons.camera_alt, color: Colors.black),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                ...controllers.entries.map((entry) => _buildTile(entry.key, entry.value)).toList(),
                const SizedBox(height: 30),
                if (_isAdmin)
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveUserData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text('Save', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTile(String title, TextEditingController controller) {
    return Card(
      color: Colors.white.withOpacity(0.05),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: TextField(
          controller: controller,
          enabled: _isAdmin,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: title,
            labelStyle: const TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
