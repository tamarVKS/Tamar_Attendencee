import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tamar_attendence/adminpages/admin.dart';
import 'package:tamar_attendence/adminpages/modal_employee_details.dart';
import 'package:tamar_attendence/adminpages/modal_employee_form.dart';
import 'package:tamar_attendence/adminpages/modal_Leave.dart';
import 'package:tamar_attendence/adminpages/modal_Leave_approval.dart';
import 'package:tamar_attendence/attendance_history.dart';
import 'package:tamar_attendence/changePassword.dart';
import 'package:tamar_attendence/clockinout.dart';
import 'package:tamar_attendence/dashboard.dart';
import 'package:tamar_attendence/employees_details.dart';
import 'package:tamar_attendence/firebase_options.dart';
import 'package:tamar_attendence/forget_password.dart';
import 'package:tamar_attendence/login_screen.dart';
import 'package:tamar_attendence/notification_page.dart';
import 'package:tamar_attendence/perosnalInformation.dart';
import 'package:tamar_attendence/profile.dart';
import 'package:tamar_attendence/report_attendance.dart';
import 'package:tamar_attendence/screen/splash.dart';
import 'package:tamar_attendence/signup_page.dart';
import 'package:tamar_attendence/leavepage.dart';

import 'adminpages/Office_Settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tamar Attendance',
      initialRoute: '/splash',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: AuthGate(), // 👈 New logic for handling persistent login
      onGenerateRoute: (settings) {
        final args = settings.arguments as Map<String, dynamic>? ?? {};

        switch (settings.name) {
          case '/splash':
            return MaterialPageRoute(builder: (_) => Splashscreen());
          case '/login_screen':
            return MaterialPageRoute(builder: (_) => LoginScreen());
          case '/signup':
            return MaterialPageRoute(builder: (_) => SignUpPage());
          case '/profile':
            return MaterialPageRoute(builder: (_) => ProfilePage());
          case '/attendance_history':
            return MaterialPageRoute(builder: (_) => AttendanceHistoryScreen());
          case '/report_attendance':
            return MaterialPageRoute(builder: (_) => ReportAttendanceScreen());
          case '/leave_page':
            return MaterialPageRoute(builder: (_) => LeaveManagementScreen());
          case '/notification_page':
            return MaterialPageRoute(builder: (_) => NotificationsScreen());
          case '/personalInformation':
            return MaterialPageRoute(builder: (_) => PersonalInformationScreen());
          case '/changePassword':
            return MaterialPageRoute(builder: (_) => ChangePasswordScreen());
          case '/forget_password':
            return MaterialPageRoute(builder: (_) => ForgotPasswordPage());
          case '/employees_details':
            return MaterialPageRoute(builder: (_) => EmployeeScreens());
          case '/admin':
            return MaterialPageRoute(builder: (_) => AdminPage());
          case '/modal_employee_details':
            return MaterialPageRoute(builder: (_) => EmployeeScreen());
          case 'Office_Settings':
            return MaterialPageRoute(builder: (_) => OfficeSettingsPage());
          case '/modal_employee_form':
            return MaterialPageRoute(builder: (_) => EmployeeForm());
          case '/modal_Leave_approval':
            return MaterialPageRoute(builder: (_) => LeaveApprovalScreen());
          case '/modal_Leave':
            return MaterialPageRoute(builder: (_) => Modalleave());
          case '/dashboard':
            return MaterialPageRoute(
              builder: (_) => DashboardScreen(userId: args['userId'] ?? ''),
            );
          case '/clockinout':
            return MaterialPageRoute(
              builder: (_) => LiveAttendanceScreen(
                employeeName: args['employeeName'] ?? 'Unknown',
              ),
            );
          default:
            return MaterialPageRoute(builder: (_) => LoginScreen());
        }
      },
    );
  }
}

/// This widget checks if a user is logged in and navigates accordingly
class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Splashscreen(); // You can keep your animated splash here
        } else if (snapshot.hasData) {
          // If user is logged in, send to dashboard
          final userId = snapshot.data!.uid;
          return DashboardScreen(userId: userId);
        } else {
          // If not logged in, go to login
          return LoginScreen();
        }
      },
    );
  }
}
