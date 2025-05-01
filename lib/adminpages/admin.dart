import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _greeting = '';
  String _formattedDate = '';
  String _formattedTime = '';
  Timer? _timer;

  String? _fullName = 'Admin';
  String? _profileImageUrl;

  // Stats variables
  int _totalEmployees = 0;
  int _presentToday = 0;
  int _onLeave = 0;
  int _pendingRequests = 0;

  @override
  void initState() {
    super.initState();
    _updateGreetingTime();
    _fetchUserDetails();
    _fetchDashboardStats();
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _updateGreetingTime());
  }

  Future<void> _fetchDashboardStats() async {
    // Get total employees count
    final employeesQuery = await _firestore.collection('employees').get();

    // Get today's attendance (you'll need to adjust this query based on your data structure)
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final attendanceQuery = await _firestore.collection('attendance')
        .where('date', isEqualTo: today)
        .where('status', isEqualTo: 'present')
        .get();

    // Get pending leave requests (adjust query as needed)
    final leaveQuery = await _firestore.collection('leave_requests')
        .where('status', isEqualTo: 'pending')
        .get();

    // Get employees on leave today
    final onLeaveQuery = await _firestore.collection('leave_requests')
        .where('startDate', isLessThanOrEqualTo: today)
        .where('endDate', isGreaterThanOrEqualTo: today)
        .where('status', isEqualTo: 'approved')
        .get();

    setState(() {
      _totalEmployees = employeesQuery.size;
      _presentToday = attendanceQuery.size;
      _pendingRequests = leaveQuery.size;
      _onLeave = onLeaveQuery.size;
    });
  }

  void _updateGreetingTime() {
    final hour = DateTime.now().hour;
    final now = DateTime.now();
    String greeting = (hour < 12)
        ? 'Good Morning'
        : (hour < 18)
        ? 'Good Afternoon'
        : 'Good Evening';

    setState(() {
      _greeting = greeting;
      _formattedDate = DateFormat('dd MMM yyyy').format(now);
      _formattedTime = DateFormat('hh:mm:ss a').format(now);
    });
  }

  Future<void> _fetchUserDetails() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        setState(() {
          _fullName = data?['fullName'] ?? 'Admin';
          _profileImageUrl = data?['profileImageUrl'];
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Confirm Logout'),
        content: Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _auth.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () => _showLogoutConfirmation(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 25, horizontal: 16),
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
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 28,
                      backgroundImage: _profileImageUrl != null
                          ? NetworkImage(_profileImageUrl!)
                          : AssetImage('assets/default-avatar.png') as ImageProvider,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting,
                          style: TextStyle(fontSize: 18, color: Colors.white70),
                        ),
                        SizedBox(height: 2),
                        Text(
                          _fullName ?? 'Admin',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          '📅 $_formattedDate   🕒 $_formattedTime',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            // Quick Stats Section
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today\'s Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[800],
                    ),
                  ),
                  SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _buildStatCard('Total Employees', '$_totalEmployees', Icons.people, Colors.blue),
                      _buildStatCard('Present Today', '$_presentToday', Icons.check_circle, Colors.green),
                      _buildStatCard('On Leave', '$_onLeave', Icons.beach_access, Colors.orange),
                      _buildStatCard('Pending Requests', '$_pendingRequests', Icons.notifications_active, Colors.red),
                    ],
                  ),
                ],
              ),
            ),

            // Quick Actions Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[800],
                    ),
                  ),
                  SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.0,
                    children: [
                      _buildMenuCard('Employee Management', Icons.people_alt, context, '/modal_employee_details'),
                      _buildMenuCard('Attendance Report', Icons.assignment, context, '/attendance_history'),
                      _buildMenuCard('Leave Approvals', Icons.not_interested, context, '/modal_Leave_approval'),
                      _buildMenuCard('Office Settings', Icons.settings, context, '/Office_Settings'),
                      _buildMenuCard('Add New Employee', Icons.person_add, context, '/modal_employee_form'),
                      _buildMenuCard('Reports', Icons.analytics, context, '/reports'),
                    ],
                  ),
                ],
              ),
            ),

            // Recent Activity Section
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[800],
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/activity_log'),
                        child: Text('View All'),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(12),
                    child: Column(
                      children: [
                        _buildActivityItem('John Doe checked in late', 'Today, 09:15 AM'),
                        Divider(),
                        _buildActivityItem('New leave request from Sarah', 'Today, 08:30 AM'),
                        Divider(),
                        _buildActivityItem('System update completed', 'Yesterday, 11:45 PM'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ]),
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: color),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(String label, IconData icon, BuildContext context, String route) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            )],
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: Colors.blueAccent),
            ),
            SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[800],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, String time) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blueAccent.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.notifications_none, size: 20, color: Colors.blueAccent),
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        time,
        style: TextStyle(fontSize: 12, color: Colors.grey),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {
        // Handle activity item tap
      },
    );
  }
}