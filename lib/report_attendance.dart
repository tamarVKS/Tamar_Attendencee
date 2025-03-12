import 'package:flutter/material.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class ReportAttendanceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Report Attendance'),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () async {
              await _generateAndDownloadPDF();
            },
          ),
        ],
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '2025-02-07 to 2025-02-07',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: 4, // Replace with the actual number of attendance records
                itemBuilder: (context, index) {
                  return AttendanceRecordCard();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateAndDownloadPDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Attendance Report', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text('Date: 2025-02-07 to 2025-02-07', style: pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              context: context,
              headers: ['Date', 'Name', 'Department', 'Clock In', 'Clock Out'],
              data: [
                ['2025-02-07', 'John Doe', 'IT', '09:00 AM', '05:00 PM'],
                ['2025-02-07', 'Jane Smith', 'HR', '09:15 AM', '05:10 PM'],
              ],
            ),
          ],
        ),
      ),
    );

    if (await Permission.storage.request().isGranted) {
      final directory = await getExternalStorageDirectory();
      final path = directory!.path;
      final file = File('$path/Attendance_Report.pdf');
      await file.writeAsBytes(await pdf.save());
      print('PDF saved at: $path/Attendance_Report.pdf');
    } else {
      print('Storage permission denied');
    }
  }
}

class AttendanceRecordCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Friday, Feb 7 - John Doe',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'IT Department',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.login, color: Colors.green),
                        SizedBox(width: 8.0),
                        Text('CLOCK IN'),
                      ],
                    ),
                    Text('09:00 AM', style: TextStyle(color: Colors.grey)),
                  ],
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 8.0),
                        Text('CLOCK OUT'),
                      ],
                    ),
                    Text('05:00 PM', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
