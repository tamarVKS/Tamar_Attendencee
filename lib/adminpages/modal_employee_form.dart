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
  String _imageUrl = 'assets/default_image.jpg';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ✅ Pick Image
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // ✅ Upload Image to Firebase Storage
  Future<void> _uploadImage(File image) async {
    try {
      String fileName = 'employees/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = _storage.ref().child(fileName);
      UploadTask uploadTask = ref.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      String uploadedUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        _imageUrl = uploadedUrl; // ✅ Set new image URL after upload
      });
    } catch (e) {
      print('⚠️ Image upload failed: $e');
      // ✅ If upload fails, keep the default image
    }
  }

  // ✅ Save Employee Data in Firestore
  Future<void> _saveEmployeeData() async {
    if (_formKey.currentState!.validate()) {
      if (_password != _retypePassword) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Passwords do not match.")));
        return;
      }

      _formKey.currentState!.save();

      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: _email, password: _password);

        // ✅ If no uploaded image, use the hardcoded default
        String finalImageUrl = _imageUrl.isNotEmpty ? _imageUrl : 'assets/default_image.jpg';

        await _firestore.collection('employees').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'name': _name,
          'email': _email,
          'phone': _phone,
          'department': _department,
          'jobTitle': _jobTitle,
          'imageUrl': finalImageUrl,
          'createdAt': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("✅ Employee added successfully!")));

        _formKey.currentState!.reset();
        setState(() {
          _image = null;
          _imageUrl = 'assets/default_image.jpg'; // ✅ Reset to default image
          _name = _email = _phone = _department = _jobTitle = _password = _retypePassword = '';
        });

      } catch (e) {
        print('⚠️ Error saving employee: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Failed to add employee: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Employee Form', style: TextStyle(fontWeight: FontWeight.bold)), centerTitle: true, backgroundColor: Colors.blueAccent,),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _image != null
                      ? FileImage(_image!) as ImageProvider
                      : NetworkImage(_imageUrl), // ✅ Always use a valid image URL
                  child: _image == null ? Icon(Icons.camera_alt, size: 30, color: Colors.white) : null,
                ),
              ),
              SizedBox(height: 20),
              buildTextField('Name', Icons.person, (value) => _name = value!),
              buildTextField('Email', Icons.email, (value) => _email = value!),
              buildTextField('Phone', Icons.phone, (value) => _phone = value!),
              buildDropdown('Department', ['HR', 'Engineering', 'Sales', 'Marketing'], (newValue) => _department = newValue!),
              buildDropdown('Job Title', ['Manager', 'Developer', 'Designer', 'Analyst'], (newValue) => _jobTitle = newValue!),
              buildPasswordField('Password', Icons.lock, (value) => _password = value!, obscureText: _obscurePassword, toggleVisibility: () {
                setState(() => _obscurePassword = !_obscurePassword);
              }),
              buildPasswordField('Retype Password', Icons.lock, (value) => _retypePassword = value!, obscureText: _obscureRetypePassword, toggleVisibility: () {
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

  // ✅ Helper Method: Standard Text Field
  Widget buildTextField(String label, IconData icon, Function(String?) onSave) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon), border: OutlineInputBorder()),
        validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
        onSaved: onSave,
      ),
    );
  }

  // ✅ Helper Method: Dropdown Field
  Widget buildDropdown(String label, List<String> options, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(Icons.arrow_drop_down), border: OutlineInputBorder()),
        items: options.map((option) => DropdownMenuItem(value: option, child: Text(option))).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'Please select $label' : null,
      ),
    );
  }

  // ✅ Helper Method: Password Field
  Widget buildPasswordField(String label, IconData icon, Function(String?) onSave, {required bool obscureText, required VoidCallback toggleVisibility}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: IconButton(icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility), onPressed: toggleVisibility),
          border: OutlineInputBorder(),
        ),
        validator: (value) => value!.length < 6 ? 'Password must be at least 6 characters' : null,
        onSaved: onSave,
      ),
    );
  }
}
