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
      print('Error fetching user data: $e');
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    List<Widget> _widgetOptions = <Widget>[
      DashboardContent(userName: _userName!),
      AttendanceHistoryScreen(),
      ProfilePage(),
    ];

    return MaterialApp(
      themeMode: ThemeMode.system,
      darkTheme: ThemeData.dark(),
      theme: ThemeData.light(),
      home: Scaffold(
        backgroundColor: isDarkMode ? Colors.black : Colors.grey[100],
        appBar: _selectedIndex == 0
            ? AppBar(
          title: Text('Dashboard'),
          backgroundColor: Colors.blueAccent,
          centerTitle: true,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(0),
            ),
          ),
          actions: _userRole == 'admin'
              ? [
            IconButton(
              icon: Icon(Icons.admin_panel_settings_outlined),
              tooltip: 'Admin Panel',
              onPressed: _navigateToAdmin,
            ),
          ]
              : null,
        )
            : null,
        body: AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          child: _widgetOptions[_selectedIndex],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
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
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _updateTime());
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
    return DateFormat('dd MMM yyyy').format(now);
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
              colors: [Colors.blueAccent, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundImage: AssetImage('assets/images/default.png'),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${getGreeting()},',
                      style: TextStyle(fontSize: 22, color: Colors.white70),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '${widget.userName} 👋',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          '📅 ${getCurrentDate()}   🕒 $_time',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        SizedBox(height: screenHeight * 0.03),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: screenWidth * 0.05,
              mainAxisSpacing: screenHeight * 0.03,
              childAspectRatio: 1.0,
              children: [
                _buildGridCard(
                    label: 'Attendance',
                    icon: Icons.access_time,
                    context: context,
                    destination: ReportAttendanceScreen()),
                _buildGridCard(
                    label: 'Notification',
                    icon: Icons.notifications_active,
                    context: context,
                    destination: NotificationsScreen()),
                _buildGridCard(
                    label: 'Leave',
                    icon: Icons.beach_access,
                    context: context,
                    destination: LeaveManagementScreen()),
                _buildGridCard(
                    label: 'Check In/Out',
                    icon: Icons.check_circle_outline,
                    context: context,
                    destination:
                    LiveAttendanceScreen(employeeName: widget.userName)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGridCard({
    required String label,
    required IconData icon,
    required BuildContext context,
    required Widget destination,
  }) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: Colors.black12,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => destination,
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        },
        splashColor: Colors.blueAccent.withOpacity(0.3),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 38, color: Colors.blueAccent),
              SizedBox(height: 14),
              Text(
                label,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}