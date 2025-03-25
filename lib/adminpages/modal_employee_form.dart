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
  String _name = '';
  String _email = '';
  String _phone = '';
  String _department = '';
  String _jobTitle = '';
  String _password = '';
  String _retypePassword = '';
  bool _obscurePassword = true;
  bool _obscureRetypePassword = true;
  File? _image;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ✅ Pick Image
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // ✅ Upload Image to Firebase Storage
  Future<String?> _uploadImage(File image) async {
    try {
      String fileName = 'employees/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = _storage.ref().child(fileName);
      UploadTask uploadTask = ref.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Failed to upload image: $e');
      return null;
    }
  }

  // ✅ Create User in Firebase Auth and Save Data in Firestore
  Future<void> _saveEmployeeData() async {
    if (_formKey.currentState!.validate()) {
      if (_password != _retypePassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Passwords do not match.")),
        );
        return;
      }

      _formKey.currentState!.save();

      try {
        // 🌟 Create Firebase Auth User
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );

        String? imageUrl;

        if (_image != null) {
          imageUrl = await _uploadImage(_image!);
        }

        // 🌟 Save Employee Data to Firestore
        await _firestore.collection('employees').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'name': _name,
          'email': _email,
          'phone': _phone,
          'department': _department,
          'jobTitle': _jobTitle,
          'imageUrl': imageUrl ?? '', // Store image URL or empty string
          'createdAt': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Employee added successfully!")),
        );

        // ✅ Clear the form
        _formKey.currentState!.reset();
        setState(() {
          _image = null;
          _name = '';
          _email = '';
          _phone = '';
          _department = '';
          _jobTitle = '';
          _password = '';
          _retypePassword = '';
        });

      } catch (e) {
        print('Error saving employee: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to add employee: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee Form', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              GestureDetector(
                onTap: () => _pickImage(ImageSource.gallery),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null
                      ? Icon(Icons.add_a_photo, size: 50, color: Colors.grey[700])
                      : null,
                ),
              ),
              SizedBox(height: 20),
              buildTextField('Name', Icons.person, (value) => _name = value!),
              buildTextField('Email', Icons.email, (value) => _email = value!),
              buildTextField('Phone', Icons.phone, (value) => _phone = value!),
              buildDropdown('Department', ['HR', 'Engineering', 'Sales', 'Marketing'],
                      (newValue) => _department = newValue!),
              buildDropdown('Job Title', ['Manager', 'Developer', 'Designer', 'Analyst'],
                      (newValue) => _jobTitle = newValue!),
              buildPasswordField('Password', Icons.lock, (value) => _password = value!,
                  obscureText: _obscurePassword, toggleVisibility: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  }),
              buildPasswordField('Retype Password', Icons.lock, (value) => _retypePassword = value!,
                  obscureText: _obscureRetypePassword, toggleVisibility: () {
                    setState(() => _obscureRetypePassword = !_obscureRetypePassword);
                  }),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveEmployeeData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                ),
                child: Text('Save', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, IconData icon, Function(String?) onSaved) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (value) => value!.isEmpty ? 'This field is required' : null,
        onChanged: onSaved,
      ),
    );
  }

  Widget buildDropdown(String label, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(Icons.arrow_drop_down_circle, color: Colors.blueAccent),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Please select an option' : null,
    );
  }

  Widget buildPasswordField(String label, IconData icon, Function(String?) onSaved,
      {required bool obscureText, required Function toggleVisibility}) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: () => toggleVisibility(),
        ),
        border: OutlineInputBorder(),
      ),
      obscureText: obscureText,
      onChanged: onSaved,
    );
  }
}
