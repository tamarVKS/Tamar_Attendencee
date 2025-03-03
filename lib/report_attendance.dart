import 'package:flutter/material.dart';

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
            onPressed: () {
              // Add download functionality here
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
              '[MMMMEEEEd] - [name]', // Replace with actual date and name
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '[department]', // Replace with actual department
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
                    Text('[time_in]', style: TextStyle(color: Colors.grey)), // Replace with actual clock-in time
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
                    Text('[time_out]', style: TextStyle(color: Colors.grey)), // Replace with actual clock-out time
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