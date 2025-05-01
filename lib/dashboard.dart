import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:tamar_attendence/adminpages/admin.dart';
import 'package:tamar_attendence/profile.dart';
import 'package:tamar_attendence/report_attendance.dart';
import 'package:marquee/marquee.dart';
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
  String? _userEmail;
  String? _userProfileImage;
  bool _isLoading = true;
  bool _isClockedIn = false;
  DateTime? _lastClockInTime;
  String _currentLocation = "Fetching location...";
  String _todayStatus = "Not checked in";
  int _pendingRequests = 0;
  int _upcomingHolidays = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchAttendanceStatus();
    _fetchPendingRequests();
    _fetchUpcomingHolidays();
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
          _userEmail = data['email'] ?? '';
          _userProfileImage = data['profileImage'] ?? '';
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchAttendanceStatus() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      final snapshot = await FirebaseFirestore.instance
          .collection('attendance')
          .where('userId', isEqualTo: widget.userId)
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .orderBy('date', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        setState(() {
          _isClockedIn = data['clockOut'] == null;
          _lastClockInTime = data['date'].toDate();
          _todayStatus = _isClockedIn ? "Clocked In" : "Completed";

          // Simulate location fetch
          _currentLocation = _isClockedIn
              ? "Office (12.3456, 78.9012)"
              : "Not currently at work";
        });
      }
    } catch (e) {
      print('Error fetching attendance status: $e');
    }
  }

  Future<void> _fetchPendingRequests() async {
    // Simulate API call
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _pendingRequests = 3; // Example value
    });
  }

  Future<void> _fetchUpcomingHolidays() async {
    // Simulate API call
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _upcomingHolidays = 2; // Example value
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToAdmin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AdminPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFFFFB200)),
              SizedBox(height: 16),
              Text(
                'Loading your dashboard...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Color(0xFF001F3F),
      );
    }

    List<Widget> _widgetOptions = <Widget>[
      DashboardContent(
        userName: _userName!,
        userEmail: _userEmail ?? '',
        profileImage: _userProfileImage,
        isClockedIn: _isClockedIn,
        lastClockInTime: _lastClockInTime,
        currentLocation: _currentLocation,
        todayStatus: _todayStatus,
        pendingRequests: _pendingRequests,
        upcomingHolidays: _upcomingHolidays,
        onClockInOut: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LiveAttendanceScreen(
                employeeName: _userName!,
              ),
            ),
          ).then((_) => _fetchAttendanceStatus());
        },
      ),
      AttendanceHistoryScreen(),
      LeaveManagementScreen(),
      NotificationsScreen(),
      ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: Color(0xFF001F3F),
      appBar: _selectedIndex == 0
          ? AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF006778), Color(0xFF003459)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          if (_userRole == 'admin')
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: IconButton(
                icon: Icon(Icons.admin_panel_settings_outlined,
                    color: Color(0xFFFFB200), size: 28),
                tooltip: 'Admin Panel',
                onPressed: _navigateToAdmin,
              ),
            ),
        ],
      )
          : null,
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: _widgetOptions[_selectedIndex],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF003459), Color(0xFF001F3F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: _pendingRequests > 0
                  ? Badge(
                label: Text(_pendingRequests.toString()),
                child: Icon(Icons.calendar_today_outlined),
              )
                  : Icon(Icons.calendar_today_outlined),
              activeIcon: _pendingRequests > 0
                  ? Badge(
                label: Text(_pendingRequests.toString()),
                child: Icon(Icons.calendar_today),
              )
                  : Icon(Icons.calendar_today),
              label: 'Leave',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                child: Icon(Icons.notifications_outlined),
                smallSize: 8,
                backgroundColor: Colors.red,
              ),
              activeIcon: Badge(
                child: Icon(Icons.notifications),
                smallSize: 8,
                backgroundColor: Colors.red,
              ),
              label: 'Alerts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Color(0xFFFFB200),
          unselectedItemColor: Colors.white60,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}

class DashboardContent extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String? profileImage;
  final bool isClockedIn;
  final DateTime? lastClockInTime;
  final String currentLocation;
  final String todayStatus;
  final int pendingRequests;
  final int upcomingHolidays;
  final VoidCallback onClockInOut;

  DashboardContent({
    required this.userName,
    required this.userEmail,
    this.profileImage,
    required this.isClockedIn,
    this.lastClockInTime,
    required this.currentLocation,
    required this.todayStatus,
    required this.pendingRequests,
    required this.upcomingHolidays,
    required this.onClockInOut,
  });

  @override
  _DashboardContentState createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  late Timer _timer;
  String _time = DateFormat('hh:mm:ss a').format(DateTime.now());
  bool _showMoreStats = false;

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
    if (hour >= 5 && hour < 12) return 'Good Morning';
    if (hour >= 12 && hour < 17) return 'Good Afternoon';
    if (hour >= 17 && hour < 21) return 'Good Evening';
    return 'Good Night';
  }

  String getCurrentDate() {
    final now = DateTime.now();
    return DateFormat('EEEE, MMMM d, yyyy').format(now);
  }

  String _formatDuration(DateTime? time) {
    if (time == null) return "--:--";
    final duration = DateTime.now().difference(time);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  Widget _buildStatsCard(String title, String value, IconData icon, Color color, [String? subtitle]) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Color(0xFF003459),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color color = const Color(0xFF003459),
    bool isHighlighted = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: color,
          border: isHighlighted
              ? Border.all(color: Color(0xFFFFB200), width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFFB200).withOpacity(isHighlighted ? 0.3 : 0.1),
              ),
              child: Icon(icon, size: 28, color: Color(0xFFFFB200)),
            ),
            SizedBox(height: 12),
            Container(
              height: 20,
              width: double.infinity,
              child: Marquee(
                text: title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                scrollAxis: Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.center,
                blankSpace: 20.0,
                velocity: 20.0,
                pauseAfterRound: Duration(seconds: 1),
                startPadding: 10.0,
                accelerationDuration: Duration(seconds: 1),
                accelerationCurve: Curves.linear,
                decelerationDuration: Duration(milliseconds: 500),
                decelerationCurve: Curves.easeOut,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceStatusCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: widget.isClockedIn ? Color(0xFF1B5E20) : Color(0xFF003459),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  widget.isClockedIn ? Icons.check_circle : Icons.timer,
                  color: widget.isClockedIn ? Colors.greenAccent : Color(0xFFFFB200),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isClockedIn ? "Currently Clocked In" : "Ready to Clock In",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      widget.isClockedIn
                          ? "Working for ${_formatDuration(widget.lastClockInTime)}"
                          : "Tap below to start your day",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: widget.onClockInOut,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.isClockedIn ? Colors.redAccent : Color(0xFFFFB200),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: Size(double.infinity, 48),
              ),
              child: Text(
                widget.isClockedIn ? "CLOCK OUT" : "CLOCK IN",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(height: 8),
            Text(
              widget.currentLocation,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(24, 24, 24, 32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF006778), Color(0xFF003459)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: widget.profileImage != null && widget.profileImage!.isNotEmpty
                          ? NetworkImage(widget.profileImage!)
                          : AssetImage('assets/default-avatar.png') as ImageProvider,
                      child: widget.profileImage == null || widget.profileImage!.isEmpty
                          ? Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${getGreeting()} 👋',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            widget.userName,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            widget.userEmail,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Today is',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            getCurrentDate(),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Status: ${widget.todayStatus}',
                            style: TextStyle(
                              color: widget.isClockedIn ? Colors.greenAccent : Color(0xFFFFB200),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xFFFFB200).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _time,
                          style: TextStyle(
                            color: Color(0xFFFFB200),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Attendance Status Card
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: _buildAttendanceStatusCard(),
          ),

          // Stats Section
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                GridView.count(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  children: [
                    _buildStatsCard(
                        'Worked Hours',
                        '42.5h',
                        Icons.timer_outlined,
                        Colors.blue,
                        '+3.5h overtime'
                    ),
                    _buildStatsCard(
                        'Leaves Left',
                        '${12 - widget.pendingRequests}/12',
                        Icons.beach_access_outlined,
                        Colors.teal,
                        '${widget.pendingRequests} pending'
                    ),
                    if (_showMoreStats) ...[
                      _buildStatsCard(
                          'This Month',
                          '18d',
                          Icons.calendar_view_month,
                          Colors.purple,
                          '2 days remaining'
                      ),
                      _buildStatsCard(
                          'Upcoming Holidays',
                          widget.upcomingHolidays.toString(),
                          Icons.celebration,
                          Colors.orange,
                          'Next: New Year'
                      ),
                    ] else ...[
                      _buildStatsCard(
                          'Weekly Avg.',
                          '8.2h',
                          Icons.av_timer,
                          Colors.green,
                          '±0.5h variance'
                      ),
                      _buildStatsCard(
                          'Late Arrivals',
                          '2',
                          Icons.warning_amber,
                          Colors.red,
                          'Last: 5 min late'
                      ),
                    ],
                  ],
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showMoreStats = !_showMoreStats;
                    });
                  },
                  child: Text(
                    _showMoreStats ? 'Show less stats' : 'Show more stats',
                    style: TextStyle(color: Color(0xFFFFB200)),
                  ),
                )
              ],
            ),
          ),

          // Quick Actions
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.8,
                  children: [
                    _buildFeatureCard(
                      title: 'Check In/Out',
                      icon: Icons.fingerprint,
                      onTap: widget.onClockInOut,
                      isHighlighted: !widget.isClockedIn,
                    ),
                    _buildFeatureCard(
                      title: 'Report',
                      icon: Icons.bar_chart,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReportAttendanceScreen(),
                          ),
                        );
                      },
                    ),
                    _buildFeatureCard(
                      title: 'Request Leave',
                      icon: Icons.beach_access,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LeaveManagementScreen(),
                          ),
                        );
                      },
                    ),
                    _buildFeatureCard(
                      title: 'Face ID',
                      icon: Icons.face,
                      onTap: () {
                        // Implement face recognition
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Face recognition feature coming soon!")),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Recent Activity
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Activity',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AttendanceHistoryScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'View All',
                        style: TextStyle(color: Color(0xFFFFB200)),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFF003459),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildActivityItem(
                        'Checked In',
                        'Today at 08:30 AM',
                        Icons.login,
                        Colors.green,
                        'Office (GPS verified)',
                      ),
                      Divider(color: Colors.white12, height: 24),
                      _buildActivityItem(
                        'Checked Out',
                        'Yesterday at 05:45 PM',
                        Icons.logout,
                        Colors.red,
                        'Early departure (manager approved)',
                      ),
                      Divider(color: Colors.white12, height: 24),
                      _buildActivityItem(
                        'Leave Approved',
                        '2 days ago',
                        Icons.verified,
                        Colors.blue,
                        'Sick leave for 2 days',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Company Announcements
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Company Announcements',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Card(
                  color: Color(0xFF003459),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.campaign, color: Color(0xFFFFB200)),
                            SizedBox(width: 8),
                            Text(
                              'Holiday Notice',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Spacer(),
                            Text(
                              '2 days ago',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Office will be closed on December 25th for Christmas holiday. Wishing everyone a joyful celebration!',
                          style: TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String subtitle, IconData icon, Color color, String details) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Color(0xFF003459),
            title: Text(title, style: TextStyle(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subtitle, style: TextStyle(color: Colors.white70)),
                SizedBox(height: 8),
                Text(details, style: TextStyle(color: Colors.white)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK', style: TextStyle(color: Color(0xFFFFB200))),
              ),
            ],
          ),
        );
      },
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  details,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.white54),
        ],
      ),
    );
  }
}