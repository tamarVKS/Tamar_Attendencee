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
      debugShowCheckedModeBanner: false,
      initialRoute: '/login_screen',
      onGenerateRoute: (settings) {
        // Handle named routes with parameters
        if (settings.name == '/clockinout') {
          final args = settings.arguments as Map<String, dynamic>? ?? {};
          return MaterialPageRoute(
            builder: (context) => LiveAttendanceScreen(
              employeeName: args['employeeName'] ?? 'Unknown',
            ),
          );
        }

        // Default named routes
        switch (settings.name) {
          case '/splash':
            return MaterialPageRoute(builder: (context) => Splashscreen());
          case '/login_screen':
            return MaterialPageRoute(builder: (context) => LoginScreen());
          case '/dashboard':
            return MaterialPageRoute(builder: (context) => DashboardScreen());
          case '/profile':
            return MaterialPageRoute(builder: (context) => ProfilePage());
          case '/attendance_history':
            return MaterialPageRoute(builder: (context) => AttendanceHistoryScreen());
          case '/report_attendance':
            return MaterialPageRoute(builder: (context) => ReportAttendanceScreen());
          case '/leave_page':
            return MaterialPageRoute(builder: (context) => LeaveManagementScreen());
          case '/notification_page':
            return MaterialPageRoute(builder: (context) => NotificationsScreen());
          case '/personalInformation':
            return MaterialPageRoute(builder: (context) => PersonalInformationScreen());
          case '/changePassword':
            return MaterialPageRoute(builder: (context) => ChangePasswordScreen());
          case '/forget_password':
            return MaterialPageRoute(builder: (context) => ForgotPasswordPage());
          case '/employees_details':
            return MaterialPageRoute(builder: (context) => EmployeeScreens());
          case '/admin':
            return MaterialPageRoute(builder: (context) => AdminPage());
          case '/modal_employee_details':
            return MaterialPageRoute(builder: (context) => EmployeeScreen());
          case '/modal_employee_form':
            return MaterialPageRoute(builder: (context) => EmployeeForm());
          default:
            return MaterialPageRoute(builder: (context) => LoginScreen());
        }
      },
    );
  }
}
