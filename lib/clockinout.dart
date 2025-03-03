import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class LiveAttendanceScreen extends StatefulWidget {
  @override
  _LiveAttendanceScreenState createState() => _LiveAttendanceScreenState();
}

class _LiveAttendanceScreenState extends State<LiveAttendanceScreen> {
  String? clockInTime;
  String? clockOutTime;
  bool isCheckedIn = false;
  String? checkInLocation;
  String? checkOutLocation;
  List<Map<String, String>> attendanceHistory = [];

  // Get location with debugging
  Future<String?> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Location services are disabled.')));
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Location permission denied.')));
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Location permissions are permanently denied.')));
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      String location = '${position.latitude}, ${position.longitude}';
      print('📍 Current Location: $location');
      return location;
    } catch (e) {
      print('❌ Error getting location: $e');
      return null;
    }
  }

  // Check-In Function
  Future<void> clockIn() async {
    String? location = await _getCurrentLocation();
    if (location == null) return;

    String time = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    print('✅ Check-In Time: $time');

    setState(() {
      clockInTime = time;
      checkInLocation = location;
      isCheckedIn = true;
      clockOutTime = null;
      checkOutLocation = null;
      attendanceHistory.add({'type': 'Check In', 'time': clockInTime!, 'location': checkInLocation!});
    });
  }

  // Check-Out Function
  Future<void> clockOut() async {
    if (!isCheckedIn) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('You need to check in first.')));
      return;
    }

    String? location = await _getCurrentLocation();
    if (location == null) return;

    String time = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    print('✅ Check-Out Time: $time');

    setState(() {
      clockOutTime = time;
      checkOutLocation = location;
      isCheckedIn = false;
      attendanceHistory.add({'type': 'Check Out', 'time': clockOutTime!, 'location': checkOutLocation!});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Live Attendance'), backgroundColor: Colors.blueAccent),
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
            _buildInfoCard('Check-In Time', clockInTime),
            _buildInfoCard('Check-In Location', checkInLocation),
            _buildInfoCard('Check-Out Time', clockOutTime),
            _buildInfoCard('Check-Out Location', checkOutLocation),
            SizedBox(height: 20),
            Text('Attendance History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Expanded(
              child: attendanceHistory.isEmpty
                  ? Center(child: Text('No records yet.'))
                  : ListView.builder(
                itemCount: attendanceHistory.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(attendanceHistory[index]['type'] == 'Check In' ? Icons.login : Icons.logout,
                        color: attendanceHistory[index]['type'] == 'Check In' ? Colors.green : Colors.red),
                    title: Text('${attendanceHistory[index]['type']} at ${attendanceHistory[index]['time']}'),
                    subtitle: Text('Location: ${attendanceHistory[index]['location']}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon, Color color, VoidCallback? onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: onPressed == null ? Colors.grey : color,
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      ),
    );
  }

  Widget _buildInfoCard(String title, String? value) {
    return Card(
      child: ListTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value ?? 'Not recorded yet', style: TextStyle(color: Colors.grey)),
      ),
    );
  }
}
