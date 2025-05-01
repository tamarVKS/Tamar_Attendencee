import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class LeaveManagementScreen extends StatefulWidget {
  @override
  _LeaveManagementScreenState createState() => _LeaveManagementScreenState();
}

class _LeaveManagementScreenState extends State<LeaveManagementScreen> {
  List<Map<String, String>> leaveRequests = [];
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedLeaveType;
  int totalLeave = 24;
  int availableLeave = 24;
  bool isSubmitting = false;
  String? _documentUrl;

  void _showLeaveRequestDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("New Leave Request", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFFFB200))),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDatePickerTile(
                          title: 'Start Date',
                          date: _startDate,
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() {
                                _startDate = picked;
                                _endDate = null;
                              });
                            }
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _buildDatePickerTile(
                          title: 'End Date',
                          date: _endDate,
                          onTap: _startDate == null
                              ? null
                              : () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _startDate!,
                              firstDate: _startDate!,
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() {
                                _endDate = picked;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  DropdownButtonFormField2<String>(
                    value: _selectedLeaveType,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Leave Type',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                    ),
                    buttonStyleData: ButtonStyleData(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                    ),
                    dropdownStyleData: DropdownStyleData(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.white,
                      ),
                    ),
                    items: ['Sick Leave', 'Casual Leave', 'Medical Leave']
                        .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedLeaveType = value),
                    hint: Text("Select leave type", style: TextStyle(color: Colors.grey)),
                  ),
                  SizedBox(height: 15),
                  if (_selectedLeaveType == 'Medical Leave') ...[
                    ElevatedButton.icon(
                      icon: Icon(Icons.attach_file),
                      label: Text('Upload Medical Certificate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _pickFile,
                    ),
                    if (_documentUrl != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Document Uploaded: ${_documentUrl!.split('/').last}',
                          style: TextStyle(color: Colors.green, fontSize: 14),
                        ),
                      ),
                  ],
                  SizedBox(height: 20),
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    child: isSubmitting
                        ? CircularProgressIndicator()
                        : ElevatedButton.icon(
                      key: ValueKey("submitButton"),
                      icon: Icon(Icons.send),
                      label: Text('Submit Request'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFB200),
                        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _submitLeaveRequest(setState),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDatePickerTile({
    required String title,
    required DateTime? date,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date == null ? title : DateFormat('yyyy-MM-dd').format(date),
              style: TextStyle(fontSize: 16, color: date == null ? Colors.grey : Colors.black),
            ),
            Icon(Icons.calendar_today, color: Color(0xFFFFB200)),
          ],
        ),
      ),
    );
  }

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      _uploadFile(file);
    }
  }

  void _uploadFile(File file) async {
    try {
      String fileName = Uuid().v4();
      Reference storageRef = FirebaseStorage.instance.ref().child('medical_certificates/$fileName');
      UploadTask uploadTask = storageRef.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String fileUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        _documentUrl = fileUrl;
      });
    } catch (e) {
      print("Error uploading file: $e");
    }
  }

  void _submitLeaveRequest(StateSetter modalSetState) async {
    if (_startDate == null || _endDate == null || _selectedLeaveType == null) return;

    int leaveDays = _endDate!.difference(_startDate!).inDays + 1;
    if (leaveDays > availableLeave) return;

    modalSetState(() => isSubmitting = true);

    final leaveId = Uuid().v4();
    final formattedDateRange = "${DateFormat('yyyy-MM-dd').format(_startDate!)} to ${DateFormat('yyyy-MM-dd').format(_endDate!)}";

    await FirebaseFirestore.instance.collection('leave_requests').doc(leaveId).set({
      'id': leaveId,
      'employeeId': 'employee_123',
      'type': _selectedLeaveType!,
      'startDate': Timestamp.fromDate(_startDate!),
      'endDate': Timestamp.fromDate(_endDate!),
      'days': leaveDays,
      'status': 'Pending',
      'documentUrl': _documentUrl,
    });

    await Future.delayed(Duration(milliseconds: 500));

    setState(() {
      availableLeave -= leaveDays;
      int centerIndex = (leaveRequests.length / 2).floor();
      leaveRequests.insert(centerIndex, {
        'dateRange': formattedDateRange,
        'type': _selectedLeaveType!,
        'status': 'Pending',
        'days': leaveDays.toString(),
        'documentUrl': _documentUrl ?? 'No document uploaded',
      });
    });

    modalSetState(() {
      isSubmitting = false;
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFF001F3F),
      appBar: AppBar(
        title: Text('Leave Management', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF003459),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.02),
            Container(
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Color(0xFF003459),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Total Leave', style: TextStyle(color: Colors.white, fontSize: 16)),
                    Text('$totalLeave days', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ]),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Available Leave', style: TextStyle(color: Colors.white, fontSize: 16)),
                    Text('$availableLeave days', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ]),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFFB200),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _showLeaveRequestDialog,
              child: Text('Request Leave'),
            ),
            SizedBox(height: screenHeight * 0.03),
            Expanded(
              child: leaveRequests.isEmpty
                  ? Center(child: Text('No leave requests yet.', style: TextStyle(color: Colors.white70)))
                  : ListView.builder(
                itemCount: leaveRequests.length,
                itemBuilder: (context, index) {
                  final leave = leaveRequests[index];
                  return Card(
                    color: Colors.white,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: Icon(Icons.event_note, color: Color(0xFFFFB200)),
                      title: Text('${leave['type']} - ${leave['dateRange']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Status: ${leave['status']}'),
                          Text('Days: ${leave['days']}'),
                          if (leave['documentUrl'] != null && leave['documentUrl'] != 'No document uploaded')
                            GestureDetector(
                              onTap: () {
                                // Optionally open document link
                              },
                              child: Text(
                                'View Document',
                                style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
