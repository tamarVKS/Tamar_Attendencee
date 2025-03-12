import 'package:flutter/material.dart';

class Modalleave extends StatefulWidget {
  @override
  _ModalleaveState createState() => _ModalleaveState();
}

class _ModalleaveState extends State<Modalleave> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  String? _selectedApprover;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leave Approval', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Center the content
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Request Leave',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _dateController,
                      decoration: InputDecoration(
                        labelText: 'Leave Dates',
                        hintText: '2024-03-07 to 2024-03-07',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.date_range, color: Colors.black),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    TextField(
                      controller: _reasonController,
                      decoration: InputDecoration(
                        labelText: 'Reason',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.text_snippet, color: Colors.black),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    DropdownButtonFormField<String>(
                      value: _selectedApprover,
                      items: ['CEO', 'HR Shagun', 'Varun']
                          .map((approver) => DropdownMenuItem(
                        value: approver,
                        child: Text(approver),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedApprover = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Select Approver',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person, color: Colors.black),
                      ),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle send request
                        },
                        child: Text('Send Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}