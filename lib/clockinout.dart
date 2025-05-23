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
  String? workedHours;

  @override
  void initState() {
    super.initState();
    _fetchLatestCheckInStatus();
  }

  Future<void> _fetchLatestCheckInStatus() async {
    var snapshot = await _databaseService.getCheckTimeByName(widget.employeeName).first;

    if (snapshot.docs.isNotEmpty) {
      var latestDoc = snapshot.docs.first;
      var data = latestDoc.data() as Map<String, dynamic>;

      CheckInOutDetails details = CheckInOutDetails.fromJson(data);
      DateTime? checkin = details.checkin?.toDate();
      DateTime? checkout = details.checkout?.toDate();

      setState(() {
        isCheckedIn = details.checkout == null;
        checkInId = latestDoc.id;
        checkInTime = checkin != null ? DateFormat('hh:mm a').format(checkin) : null;
        checkInLocation = details.location ?? "Unknown";
        checkOutTime = checkout != null ? DateFormat('hh:mm a').format(checkout) : null;
        checkOutLocation = details.checkoutLocation ?? "Unknown";
        isLate = details.isLate ?? false;

        if (checkin != null && checkout != null) {
          Duration duration = checkout.difference(checkin);
          workedHours = _formatDuration(duration);
        } else {
          workedHours = null;
        }
      });
    } else {
      setState(() {
        isCheckedIn = false;
        checkInTime = null;
        checkOutTime = null;
        checkInLocation = null;
        checkOutLocation = null;
        checkInId = null;
        isLate = false;
        workedHours = null;
      });
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours.toString().padLeft(2, '0')}h ${minutes.toString().padLeft(2, '0')}m';
  }

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

    DateTime now = DateTime.now();
    DateTime lateThreshold = DateTime(now.year, now.month, now.day, 9, 30);
    isLate = now.isAfter(lateThreshold);

    CheckInOutDetails checkInData = CheckInOutDetails(
      name: widget.employeeName,
      checkin: Timestamp.fromDate(now),
      location: location,
      isLate: isLate,
    );

    await _databaseService.addCheckInOutData(checkInData).then((docRef) {
      setState(() {
        checkInId = docRef.id;
        checkInTime = DateFormat('hh:mm a').format(now);
        checkInLocation = location;
        isCheckedIn = true;
        isLoading = false;
        workedHours = null;
      });
    }).catchError((error) {
      print('Error adding check-in: $error');
      setState(() => isLoading = false);
    });
  }

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
      DateTime checkinTime = DateFormat('hh:mm a').parse(checkInTime!);
      Duration duration = now.difference(checkinTime);

      setState(() {
        checkOutTime = DateFormat('hh:mm a').format(now);
        checkOutLocation = location;
        isCheckedIn = false;
        isLoading = false;
        workedHours = _formatDuration(duration);
      });
    }).catchError((error) {
      print('Error updating check-out: $error');
      setState(() => isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: Color(0xFF003459),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: Color(0xFF001F3F),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: _buildModernActionButton(
                    text: 'Check In',
                    icon: Icons.login,
                    color: Colors.green.shade400,
                    onPressed: isCheckedIn ? null : clockIn,
                    isLoading: isLoading,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildModernActionButton(
                    text: 'Check Out',
                    icon: Icons.logout,
                    color: Colors.red.shade400,
                    onPressed: isCheckedIn ? clockOut : null,
                    isLoading: isLoading,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Text(
              'Today\'s Details',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            _buildModernInfoCard(
              title: 'Check-In Time',
              value: checkInTime,
              icon: Icons.access_time_outlined,
              valueColor: isLate ? Color(0xFFFFB200) : Colors.white,
              isLate: isLate,
            ),
            const SizedBox(height: 12),
            _buildModernInfoCard(
              title: 'Check-In Location',
              value: checkInLocation,
              icon: Icons.location_on_outlined,
              valueColor: Colors.white,
            ),
            const SizedBox(height: 12),
            _buildModernInfoCard(
              title: 'Check-Out Time',
              value: checkOutTime,
              icon: Icons.logout_outlined,
              valueColor: Colors.white,
            ),
            const SizedBox(height: 12),
            _buildModernInfoCard(
              title: 'Check-Out Location',
              value: checkOutLocation,
              icon: Icons.location_on_outlined,
              valueColor: Colors.white,
            ),
            const SizedBox(height: 12),
            if (workedHours != null)
              _buildModernInfoCard(
                title: 'Worked Hours',
                value: workedHours,
                icon: Icons.timer_outlined,
                valueColor: Colors.white,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernActionButton({
    required String text,
    required IconData icon,
    required Color color,
    VoidCallback? onPressed,
    required bool isLoading,
  }) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: onPressed == null ? Colors.grey.shade700 : color,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      child: isLoading
          ? const SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
      )
          : Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernInfoCard({
    required String title,
    required String? value,
    required IconData icon,
    required Color valueColor,
    bool isLate = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF003459),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value ?? 'Not recorded yet',
                  style: TextStyle(
                    color: valueColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isLate)
                  const Padding(
                    padding: EdgeInsets.only(top: 4.0),
                    child: Text(
                      "Late Check-In",
                      style: TextStyle(color: Color(0xFFFFB200), fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
