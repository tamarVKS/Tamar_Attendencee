import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tamar_attendence/adminpages/admin.dart';
import 'package:tamar_attendence/adminpages/modal_employee_details.dart';
import 'package:tamar_attendence/adminpages/modal_employee_form.dart';
import 'package:tamar_attendence/forget_password.dart';
import 'package:tamar_attendence/perosnalInformation.dart';
import 'package:tamar_attendence/profile.dart';
import 'package:tamar_attendence/report_attendance.dart';
import 'package:tamar_attendence/screen/splash.dart';
import 'package:tamar_attendence/signup_page.dart';
import 'SignIn.dart';
import 'adminpages/modal_Leave.dart';
import 'adminpages/modal_Leave_approval.dart';
import 'attendance_history.dart';
import 'changePassword.dart';
import 'clockinout.dart';
import 'dashboard.dart';
import 'employees_details.dart';
import 'firebase_options.dart';
import 'leavepage.dart';
import 'login_screen.dart';
import 'notification_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ Firebase Initialized Successfully");
  } catch (e) {
    print("❌ Firebase Initialization Failed: $e");
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, //  Removes debug banner
      title: 'Tamar Attendance',
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
      themeMode: ThemeMode.system, // 🌙 Enables dark mode support
      initialRoute: '/login_screen',
      onGenerateRoute: (settings) {
        final args = settings.arguments as Map<String, dynamic>? ?? {};

        switch (settings.name) {
          case '/splash':
            return MaterialPageRoute(builder: (_) => Splashscreen());
          case '/login_screen':
            return MaterialPageRoute(builder: (_) => LoginScreen());
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
