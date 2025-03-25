import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:tamar_attendence/models/checkinout.dart';
import 'package:tamar_attendence/services/clockinDatabase.dart';

class LiveAttendanceScreen extends StatefulWidget {
  final String employeeName;               // ✅ Added employeeName parameter

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
  void initState() {
    super.initState();
    _fetchLatestCheckInStatus();
  }

  // ✅ Fetch Latest Check-In Status to display it properly on reload
  Future<void> _fetchLatestCheckInStatus() async {
    var snapshot = await _databaseService.getCheckTime().first;
    if (snapshot.docs.isNotEmpty) {
      var latestDoc = snapshot.docs.first;
      var data = latestDoc.data() as Map<String, dynamic>;

      CheckInOutDetails details = CheckInOutDetails.fromJson(data);

      setState(() {
        isCheckedIn = details.checkout == null;
        checkInId = latestDoc.id;
        checkInTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(details.checkin.toDate());
        checkInLocation = details.location ?? "Unknown";
        checkOutTime = details.checkout != null
            ? DateFormat('yyyy-MM-dd HH:mm:ss').format(details.checkout!.toDate())
            : null;
        checkOutLocation = details.checkoutLocation ?? "Unknown";
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
      checkout: Timestamp.fromDate(now),  // Default checkout time
      location: location,                 // Store check-in location
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

  // ✅ Build Attendance History Stream
  Widget _buildAttendanceHistory() {
    return StreamBuilder<QuerySnapshot>(
      stream: _databaseService.getCheckTime(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No attendance history found."));
        }

        return Expanded(
          child: ListView(
            children: snapshot.data!.docs.map<Widget>((doc) {
              var data = doc.data() as Map<String, dynamic>;
              CheckInOutDetails details = CheckInOutDetails.fromJson(data);

              DateTime? checkInTime = details.checkin.toDate();
              DateTime? checkOutTime = details.checkout?.toDate();

              return Card(
                child: ListTile(
                  title: Text("Date: ${DateFormat('yyyy-MM-dd').format(checkInTime)}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Check-In: ${DateFormat('HH:mm:ss').format(checkInTime)}"),
                      Text("Check-Out: ${checkOutTime != null ? DateFormat('HH:mm:ss').format(checkOutTime) : 'Not checked out'}"),
                      Text("Location: ${details.location ?? 'N/A'}"),
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

  // ✅ Build UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.blueAccent, title: Text('Live Attendance')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(     // ✅ Added scrollable behavior
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
              const SizedBox(height: 20),
              const Text("Attendance History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(
                height: 400,                    // ✅ Add height constraint to prevent overflow
                child: _buildAttendanceHistory(),
              ),
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
