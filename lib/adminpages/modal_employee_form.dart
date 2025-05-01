import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EmployeeForm extends StatefulWidget {
  @override
  _EmployeeFormState createState() => _EmployeeFormState();
}

class _EmployeeFormState extends State<EmployeeForm> {
  final _formKey = GlobalKey<FormState>();
  String _name = '', _email = '', _phone = '', _department = '', _jobTitle = '', _password = '', _retypePassword = '';
  bool _obscurePassword = true, _obscureRetypePassword = true;
  File? _image;
  String? _imageUrl;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String> _uploadImage(File image) async {
    try {
      String fileName = 'employees/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = _storage.ref().child(fileName);
      UploadTask uploadTask = ref.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('⚠️ Image upload failed: $e');
      throw Exception('Image upload failed');
    }
  }

  Future<void> _saveEmployeeData() async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) return;

    if (_password != _retypePassword) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Passwords do not match."), backgroundColor: Colors.red));
      return;
    }

    _formKey.currentState!.save();

    try {
      String finalImageUrl = _image != null
          ? await _uploadImage(_image!)
          : 'https://via.placeholder.com/150';

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _email,
        password: _password,
      );

      if (userCredential.user != null) {
        String uid = userCredential.user!.uid;
        await userCredential.user!.updateDisplayName(_name);
        await userCredential.user!.updatePhotoURL(finalImageUrl);
        await userCredential.user!.reload();

        Map<String, dynamic> employeeData = {
          'uid': uid,
          'name': _name,
          'email': _email,
          'phone': _phone,
          'department': _department,
          'jobTitle': _jobTitle,
          'imageUrl': finalImageUrl,
          'createdAt': Timestamp.now(),
        };

        await _firestore.collection('employees').doc(uid).set(employeeData);

        await _firestore.collection('ProfileInformation').doc(uid).set({
          'uid': uid,
          'name': _name,
          'email': _email,
          'phone': _phone,
          'department': _department,
          'jobTitle': _jobTitle,
          'profileImage': finalImageUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("✅ Employee added successfully!"), backgroundColor: Colors.green));

        _formKey.currentState!.reset();
        setState(() {
          _image = null;
          _imageUrl = null;
          _name = _email = _phone = _department = _jobTitle = _password = _retypePassword = '';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Failed to retrieve user ID."), backgroundColor: Colors.red));
      }
    } catch (e) {
      print('⚠️ Error saving employee: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Failed to add employee: ${e.toString()}"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    'Add New Employee',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      backgroundImage: _image != null
                          ? FileImage(_image!)
                          : (_imageUrl != null
                          ? NetworkImage(_imageUrl!)
                          : AssetImage('assets/default_image.jpg')) as ImageProvider,
                      child: _image == null && _imageUrl == null
                          ? Icon(Icons.camera_alt, color: Colors.grey[700], size: 30)
                          : null,
                    ),
                  ),
                  SizedBox(height: 20),
                  buildTextField('Full Name', Icons.person, (val) => _name = val ?? ''),
                  buildTextField('Email Address', Icons.email, (val) => _email = val ?? ''),
                  buildTextField('Phone Number', Icons.phone, (val) => _phone = val ?? ''),
                  buildDropdown('Department', ['HR', 'Engineering', 'Sales', 'Marketing'], (val) => _department = val ?? ''),
                  buildDropdown('Job Title', ['Manager', 'Developer', 'Designer', 'Analyst'], (val) => _jobTitle = val ?? ''),
                  buildPasswordField('Password', Icons.lock, (val) => _password = val ?? '', _obscurePassword, () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  }),
                  buildPasswordField('Retype Password', Icons.lock_outline, (val) => _retypePassword = val ?? '', _obscureRetypePassword, () {
                    setState(() => _obscureRetypePassword = !_obscureRetypePassword);
                  }),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveEmployeeData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[600],
                      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 60),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text("Save", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, IconData icon, Function(String?) onSave) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: Colors.white),
          filled: true,
          fillColor: Colors.white12,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
        validator: (val) => val == null || val.isEmpty ? 'Please enter $label' : null,
        onSaved: onSave,
      ),
    );
  }

  Widget buildDropdown(String label, List<String> options, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        dropdownColor: Colors.blue[800],
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white70),
          prefixIcon: Icon(Icons.arrow_drop_down, color: Colors.white),
          filled: true,
          fillColor: Colors.white12,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
        items: options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
        validator: (val) => val == null || val.isEmpty ? 'Please select $label' : null,
        onChanged: onChanged,
      ),
    );
  }

  Widget buildPasswordField(String label, IconData icon, Function(String?) onSave, bool obscureText, VoidCallback toggleVisibility) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        obscureText: obscureText,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: Colors.white),
          suffixIcon: IconButton(
            icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.white),
            onPressed: toggleVisibility,
          ),
          filled: true,
          fillColor: Colors.white12,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
        validator: (val) => val == null || val.length < 6 ? 'Password must be at least 6 characters' : null,
        onSaved: onSave,
      ),
    );
  }
}
