import 'package:flutter/material.dart';
import 'package:tamar_attendence/profile.dart';
import 'package:tamar_attendence/report_attendance.dart';
import 'attendance_history.dart';
import 'clockinout.dart';
import 'leavepage.dart';
import 'notification_page.dart';

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    DashboardContent(),
    AttendanceHistoryScreen(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

class DashboardContent extends StatelessWidget {
  String getGreeting() {
    int hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 18) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: screenHeight * 0.03),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            getGreeting(),  // Dynamic greeting based on time
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            'Happy working',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: screenHeight * 0.03),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: screenWidth * 0.04,
              mainAxisSpacing: screenHeight * 0.02,
              childAspectRatio: 1.1,
              children: [
                _buildButton('ATTENDANCE', Icons.access_time, context, ReportAttendanceScreen()),
                _buildButton('Notification', Icons.notifications, context, NotificationsScreen()),
                _buildButton('Leave', Icons.logout, context, LeaveManagementScreen()),
                _buildButton('CheckIn/CheckOut', Icons.check_box, context, LiveAttendanceScreen()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String label, IconData icon, BuildContext context, Widget screen) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        padding: EdgeInsets.all(12.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(color: Colors.grey),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.blueAccent),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 16, color: Colors.black),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
