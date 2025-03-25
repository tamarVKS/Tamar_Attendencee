import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('attendance')
            .orderBy('checkin', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No attendance history found."));
          }

          var attendanceDocs = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(12.0),
            itemCount: attendanceDocs.length,
            itemBuilder: (context, index) {
              var data = attendanceDocs[index].data() as Map<String, dynamic>;

              DateTime? checkInTime = (data['checkin'] as Timestamp).toDate();
              DateTime? checkOutTime = data['checkout'] != null
                  ? (data['checkout'] as Timestamp).toDate()
                  : null;

              String checkInLocation = data['checkin_location'] ?? 'Unknown';
              String checkOutLocation = data['checkout_location'] ?? 'Not checked out';
              String employeeName = data['employee_name'] ?? 'N/A';

              return AttendanceCard(
                date: DateFormat('yyyy-MM-dd').format(checkInTime),
                name: employeeName,
                clockIn: DateFormat('HH:mm:ss').format(checkInTime),
                clockOut: checkOutTime != null
                    ? DateFormat('HH:mm:ss').format(checkOutTime)
                    : 'Not checked out',
                checkInLocation: checkInLocation,
                checkOutLocation: checkOutLocation,
              );
            },
          );
        },
      ),
    );
  }
}

class AttendanceCard extends StatelessWidget {
  final String date;
  final String name;
  final String clockIn;
  final String clockOut;
  final String checkInLocation;
  final String checkOutLocation;

  const AttendanceCard({
    required this.date,
    required this.name,
    required this.clockIn,
    required this.clockOut,
    required this.checkInLocation,
    required this.checkOutLocation,
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
              style: TextStyle(fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimeEntry(Icons.login, 'CLOCK IN', clockIn, Colors.green,
                    checkInLocation),
                _buildTimeEntry(Icons.logout, 'CLOCK OUT', clockOut, Colors.red,
                    checkOutLocation),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeEntry(IconData icon, String label, String time, Color color,
      String location) {
    return Expanded( // Added Expanded widget to prevent overflow
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: 6.0),
              Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          SizedBox(height: 4.0),
          Text(
            time,
            style: TextStyle(fontSize: 14,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500),
          ),
          Text(
            location,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            overflow: TextOverflow.ellipsis,
            // Added ellipsis for long location names
            maxLines: 1, // Limit the number of lines
          ),
        ],
      ),
    );
  }
}

