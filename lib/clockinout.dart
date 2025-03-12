import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamar_attendence/models/checkin_details.dart';
import 'package:tamar_attendence/models/checkout_details.dart';
import 'package:tamar_attendence/services/clockinDatabase.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

class LiveAttendanceScreen extends StatefulWidget {
  @override
  _LiveAttendanceScreenState createState() => _LiveAttendanceScreenState();
}

class _LiveAttendanceScreenState extends State<LiveAttendanceScreen> {
  final DatabaseService _databaseService = DatabaseService();
  bool isCheckedIn = false;
  bool isLoading = false;
  String? checkInTime;
  String? checkOutTime;
  String? checkInLocation;
  String? checkOutLocation;
  String? checkInId;
  bool isLate = false;

  Future<String?> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return 'Location services are disabled.';
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return 'Location permissions are denied';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return 'Location permissions are permanently denied. Please enable them in settings.';
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks.first;
      return "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
    } catch (e) {
      return "Error getting location details";
    }
  }

  Future<void> clockIn() async {
    setState(() => isLoading = true);
    String? location = await _getCurrentLocation();
    if (location == null) {
      setState(() => isLoading = false);
      return;
    }

    Timestamp now = Timestamp.now();
    DateTime currentTime = now.toDate();
    DateTime lateThreshold = DateTime(currentTime.year, currentTime.month, currentTime.day, 9, 30);
    isLate = currentTime.isAfter(lateThreshold);

    CheckIn checkInRecord = CheckIn(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      checkin: now,
      checkout: null,
      name: "Employee Name",
      location: location,
    );

    await _databaseService.addCheckIn(checkInRecord);

    setState(() {
      checkInId = checkInRecord.id;
      checkInTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(currentTime);
      checkInLocation = location;
      isCheckedIn = true;
      isLoading = false;
    });
  }

  Future<void> clockOut() async {
    if (!isCheckedIn || checkInId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You need to check in first.')),
      );
      return;
    }

    setState(() => isLoading = true);
    String? location = await _getCurrentLocation();
    if (location == null) {
      setState(() => isLoading = false);
      return;
    }

    Timestamp now = Timestamp.now();

    // FIX: Add the missing location argument
    await _databaseService.clockOut(checkInId!, now.toDate(), location);

    setState(() {
      checkOutTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now.toDate());
      checkOutLocation = location;
      isCheckedIn = false;
      isLoading = false;
    });
  }


  Widget _buildAttendanceHistory() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('attendance').orderBy('checkin', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No attendance history found."));
        }

        return Expanded(
          child: ListView(
            children: snapshot.data!.docs.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

              DateTime? checkInTime = (data['checkin'] != null)
                  ? (data['checkin'] as Timestamp).toDate()
                  : null;
              DateTime? checkOutTime = (data['checkout'] != null)
                  ? (data['checkout'] as Timestamp).toDate()
                  : null;
              String? checkInLocation = data['checkin_location'] ?? 'Not recorded';
              String? checkOutLocation = data['checkout_location'] ?? 'Not checked out';

              return Card(
                child: ListTile(
                  title: Text("Date: ${checkInTime != null ? DateFormat('yyyy-MM-dd').format(checkInTime) : 'N/A'}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Check-In: ${checkInTime != null ? DateFormat('HH:mm:ss').format(checkInTime) : 'Not recorded'}"),
                      Text("Location: $checkInLocation"),
                      Text("Check-Out: ${checkOutTime != null ? DateFormat('HH:mm:ss').format(checkOutTime) : 'Not checked out'}"),
                      Text("Location: $checkOutLocation"),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Live Attendance')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton('CHECK IN', Icons.login, Colors.green, isCheckedIn ? null : clockIn),
                _buildActionButton('CHECK OUT', Icons.logout, Colors.red, isCheckedIn ? clockOut : null),
              ],
            ),
            SizedBox(height: 20),
            _buildInfoCard('Check-In Time', checkInTime, isLate ? Colors.red : Colors.black),
            if (isLate)
              Text("Late Check-In", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            _buildInfoCard('Check-In Location', checkInLocation),
            _buildInfoCard('Check-Out Time', checkOutTime),
            _buildInfoCard('Check-Out Location', checkOutLocation),
            SizedBox(height: 20),
            Text("Attendance History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            _buildAttendanceHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon, Color color, VoidCallback? onPressed) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading ? CircularProgressIndicator(color: Colors.white) : Icon(icon, color: Colors.white),
      label: Text(text),
      style: ElevatedButton.styleFrom(backgroundColor: onPressed == null ? Colors.grey : color),
    );
  }

  Widget _buildInfoCard(String title, String? value, [Color textColor = Colors.black]) {
    return Card(
      child: ListTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
        subtitle: Text(value ?? 'Not recorded yet', style: TextStyle(color: textColor)),
      ),
    );
  }
}
