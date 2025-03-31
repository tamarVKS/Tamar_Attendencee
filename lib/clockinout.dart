import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:tamar_attendence/models/checkinout.dart';
import 'package:tamar_attendence/services/clockinDatabase.dart';

class LiveAttendanceScreen extends StatefulWidget {
  final String employeeName;

  const LiveAttendanceScreen({Key? key, required this.employeeName}) : super(key: key);

  @override
  _LiveAttendanceScreenState createState() => _LiveAttendanceScreenState();
}

class _LiveAttendanceScreenState extends State<LiveAttendanceScreen> {
  final DatabaseServicescheckinout _databaseService = DatabaseServicescheckinout();

  bool isCheckedIn = false;
  bool isLoading = false;
  String? checkInTime;
  String? checkOutTime;
  String? checkInLocation;
  String? checkOutLocation;
  String? checkInId;
  bool isLate = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchLatestCheckInStatus();  // ✅ Fetch latest status every time the screen is visited
  }

  // ✅ Fetch Latest Check-In Status
  Future<void> _fetchLatestCheckInStatus() async {
    var snapshot = await _databaseService.getCheckTime().first;
    if (snapshot.docs.isNotEmpty) {
      var latestDoc = snapshot.docs.first;
      var data = latestDoc.data() as Map<String, dynamic>;

      CheckInOutDetails details = CheckInOutDetails.fromJson(data);

      setState(() {
        isCheckedIn = details.checkout == null;  // If checkout is null, still checked in
        checkInId = latestDoc.id;
        checkInTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(details.checkin.toDate());
        checkInLocation = details.location ?? "Unknown";
        checkOutTime = details.checkout != null
            ? DateFormat('yyyy-MM-dd HH:mm:ss').format(details.checkout!.toDate())
            : null;
        checkOutLocation = details.checkoutLocation ?? "Unknown";
      });
    } else {
      // No records: reset to default state
      setState(() {
        isCheckedIn = false;
        checkInTime = null;
        checkOutTime = null;
        checkInLocation = null;
        checkOutLocation = null;
        checkInId = null;
      });
    }
  }

  // ✅ Fetch Current Location
  Future<String?> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return 'Location services are disabled.';

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return 'Location permissions are denied.';
    }

    if (permission == LocationPermission.deniedForever) {
      return 'Location permissions are permanently denied. Please enable them in settings.';
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);
      Placemark place = placemarks.first;
      return "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
    } catch (e) {
      return "Error getting location details";
    }
  }

  // ✅ Clock In Function
  Future<void> clockIn() async {
    setState(() => isLoading = true);

    String? location = await _getCurrentLocation();
    if (location == null) {
      setState(() => isLoading = false);
      return;
    }

    DateTime now = DateTime.now();
    DateTime lateThreshold = DateTime(now.year, now.month, now.day, 9, 30);
    isLate = now.isAfter(lateThreshold);

    CheckInOutDetails checkInData = CheckInOutDetails(
      name: widget.employeeName,
      checkin: Timestamp.fromDate(now),
      location: location,
    );

    await _databaseService.addCheckInOutData(checkInData).then((docRef) {
      setState(() {
        checkInId = docRef.id;
        checkInTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
        checkInLocation = location;
        isCheckedIn = true;
        isLoading = false;
      });
    }).catchError((error) {
      print('Error adding check-in: $error');
      setState(() => isLoading = false);
    });
  }

  // ✅ Clock Out Function
  Future<void> clockOut() async {
    if (!isCheckedIn || checkInId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to check in first.')),
      );
      return;
    }

    setState(() => isLoading = true);

    String? location = await _getCurrentLocation();
    if (location == null) {
      setState(() => isLoading = false);
      return;
    }

    DateTime now = DateTime.now();

    await _databaseService.updateCheckOutData(
      checkInId!,
      Timestamp.fromDate(now),
      location,
    ).then((_) {
      setState(() {
        checkOutTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
        checkOutLocation = location;
        isCheckedIn = false;
        isLoading = false;
      });
    }).catchError((error) {
      print('Error updating check-out: $error');
      setState(() => isLoading = false);
    });
  }

  // ✅ Build UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.blueAccent, title: const Text('Live Attendance')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton('CHECK IN', Icons.login, Colors.green, isCheckedIn ? null : clockIn),
                  _buildActionButton('CHECK OUT', Icons.logout, Colors.red, isCheckedIn ? clockOut : null),
                ],
              ),
              const SizedBox(height: 20),
              _buildInfoCard('Check-In Time', checkInTime, isLate ? Colors.red : Colors.black),
              if (isLate)
                const Text("Late Check-In", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              _buildInfoCard('Check-In Location', checkInLocation),
              _buildInfoCard('Check-Out Time', checkOutTime),
              _buildInfoCard('Check-Out Location', checkOutLocation),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon, Color color, VoidCallback? onPressed) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading ? const CircularProgressIndicator(color: Colors.white) : Icon(icon),
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
