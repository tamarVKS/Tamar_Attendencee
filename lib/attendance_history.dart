import 'package:flutter/material.dart';

class AttendanceHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance History', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        elevation: 4.0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.blue.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView.builder(
          padding: EdgeInsets.all(12.0),
          itemCount: 4, // Replace with actual number of records
          itemBuilder: (context, index) {
            return AttendanceCard(
              date: 'Feb 28, 2025',
              name: 'John Doe',
              clockIn: '09:00 AM',
              clockOut: '06:00 PM',
            );
          },
        ),
      ),
    );
  }
}

class AttendanceCard extends StatelessWidget {
  final String date;
  final String name;
  final String clockIn;
  final String clockOut;

  const AttendanceCard({
    required this.date,
    required this.name,
    required this.clockIn,
    required this.clockOut,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$date - $name',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimeEntry(Icons.login, 'CLOCK IN', clockIn, Colors.green),
                _buildTimeEntry(Icons.logout, 'CLOCK OUT', clockOut, Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeEntry(IconData icon, String label, String time, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            SizedBox(width: 6.0),
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        SizedBox(height: 4.0),
        Text(
          time,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
