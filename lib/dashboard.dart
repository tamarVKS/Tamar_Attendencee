import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:tamar_attendence/adminpages/admin.dart';
import 'package:tamar_attendence/profile.dart';
import 'package:tamar_attendence/report_attendance.dart';
import 'attendance_history.dart';
import 'clockinout.dart';
import 'leavepage.dart';
import 'notification_page.dart';
import 'dart:async';
import 'package:slide_to_act/slide_to_act.dart';

class DashboardScreen extends StatefulWidget {
  final String userId;
  DashboardScreen({required this.userId});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  String? _userName;
  String? _userRole;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        setState(() {
          _userName = data['fullName'] ?? 'User';
          _userRole = data['role'] ?? 'user';
          _isLoading = false;
        });
      } else {
        setState(() {
          _userName = 'User';
          _userRole = 'user';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching user data: \$e');
      setState(() {
        _userName = 'User';
        _userRole = 'user';
        _isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToAdmin() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => AdminPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _navigateToNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NotificationsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFFFFB200))),
      );
    }

    List<Widget> _widgetOptions = <Widget>[
      DashboardContent(userName: _userName!),
      AttendanceHistoryScreen(),
      LeaveManagementScreen(),
      ProfilePage(),
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xFF001F3F),
        appBar: _selectedIndex == 0
            ? AppBar(
          title: Text('Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          backgroundColor: Color(0xFF003459),
          centerTitle: true,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(Icons.notifications, color: Color(0xFFFFB200)),
              tooltip: 'Notifications',
              onPressed: _navigateToNotifications,
            ),
            if (_userRole == 'admin')
              IconButton(
                icon: Icon(Icons.admin_panel_settings_outlined, color: Color(0xFFFFB200)),
                tooltip: 'Admin Panel',
                onPressed: _navigateToAdmin,
              ),
          ],
        )
            : null,
        body: AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          child: _widgetOptions[_selectedIndex],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF003459), Color(0xFF001F3F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
              BottomNavigationBarItem(icon: Icon(Icons.time_to_leave), label: 'Leave'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Color(0xFFFFB200),
            unselectedItemColor: Colors.white60,
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }
}

class DashboardContent extends StatefulWidget {
  final String userName;
  DashboardContent({required this.userName});

  @override
  _DashboardContentState createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  late Timer _timer;
  String _time = DateFormat('hh:mm:ss a').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    setState(() {
      _time = DateFormat('hh:mm:ss a').format(DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 18) return 'Good Afternoon';
    return 'Good Evening';
  }

  String getCurrentDate() {
    final now = DateTime.now();
    return DateFormat('dd MMM, yyyy').format(now);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF006778), Color(0xFF003459)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage('assets/default-avatar.png'),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${getGreeting()},',
                      style: TextStyle(fontSize: 20, color: Colors.white70),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${widget.userName} 👋',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${getCurrentDate()}   |   $_time',
                      style: TextStyle(fontSize: 15, color: Colors.white70),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        SizedBox(height: screenHeight * 0.04),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: screenWidth * 0.04,
              mainAxisSpacing: screenHeight * 0.025,
              childAspectRatio: 1.1,
              children: [
                _buildCircularCard(
                  label: 'Check In/Out',
                  icon: Icons.fingerprint,
                  context: context,
                  destination: LiveAttendanceScreen(employeeName: widget.userName),
                  backgroundColor: Color(0xFF003459),
                  iconColor: Color(0xFFFFB200),
                ),
                // Add other circular dashboard cards here
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCircularCard({
    required String label,
    required IconData icon,
    required BuildContext context,
    required Widget destination,
    Color backgroundColor = Colors.white,
    Color iconColor = Colors.black87,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => destination,
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: iconColor),
            SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: iconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
