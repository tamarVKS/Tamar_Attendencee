import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamar_attendence/models/employeesdata.dart';
import 'package:tamar_attendence/services/employeesdatabaseservices.dart';

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
  File? _image;
  final DatabaseService _databaseService = DatabaseService();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take a photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveEmployeeData() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        Employeesdata newEmployee = Employeesdata(
          name: _name,
          email: _email,
          number: _phone,
          department: _department,
          jobtitle: _jobTitle,
          password: _password,
          retypepassword: _retypePassword,
        );
        await _databaseService.addEmployeesData(newEmployee);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Employee added successfully!")));
      } catch (e) {
        print("Error saving employee: $e");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to add employee.")));
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
                onTap: _showImageSourceDialog,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null ? Icon(Icons.add_a_photo, size: 50, color: Colors.grey[700]) : null,
                ),
              ),
              SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 5,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      buildTextField('Name', Icons.person, (value) => setState(() => _name = value!)),
                      buildTextField('Email', Icons.email, (value) => setState(() => _email = value!)),
                      buildTextField('Phone', Icons.phone, (value) => setState(() => _phone = value!)),
                      buildDropdown('Department', ['HR', 'Engineering', 'Sales', 'Marketing'],
                              (newValue) => setState(() => _department = newValue!)),
                      buildDropdown('Job Title', ['Manager', 'Developer', 'Designer', 'Analyst'],
                              (newValue) => setState(() => _jobTitle = newValue!)),
                      buildTextField('Password', Icons.lock, (value) => setState(() => _password = value!), obscureText: true),
                      buildTextField('Retype Password', Icons.lock, (value) => setState(() => _retypePassword = value!), obscureText: true),
                    ],
                  ),
                ),
              ),
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

  Widget buildTextField(String label, IconData icon, Function(String?) onSaved, {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        obscureText: obscureText,
        validator: (value) => value!.isEmpty ? 'This field is required' : null,
        onChanged: onSaved,
      ),
    );
  }

  Widget buildDropdown(String label, List<String> items, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
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
      ),
    );
  }
}
