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
    print("Firebase Initialized Successfully");
  } catch (e) {
    print("Firebase Initialization Failed: $e");
  }

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/login_screen'
     ,
    routes: {
      '/splash': (context) => Splashscreen(),
      '/login_screen': (context) => LoginScreen(),
      '/SignIn': (context) => SignInPage(),
      '/signup_page': (context) => SignUpPage(),
      '/dashboard': (context) => DashboardScreen(),
      '/clockinout': (context) => LiveAttendanceScreen(employeeName: 'John Doe'),
      '/profile': (context) => ProfilePage(),
      '/attendance_history': (context) => AttendanceHistoryScreen(),
      '/report_attendance': (context) => ReportAttendanceScreen(),
      '/leave_page': (context) => LeaveManagementScreen(),
      '/notification_page': (context) => NotificationsScreen(),
      '/personalInformation': (context) => PersonalInformationScreen(),
      '/changePassword': (context) => ChangePasswordScreen(),
      '/forget_password': (context) => ForgotPasswordPage(),
      '/employees_details': (context) => EmployeeScreens(),
      //'/liveattendance': (context) => LiveAttendanceScreen(),
      '/admin':(context)=>AdminPage(),
      '/modal_employee_details': (context) => EmployeeScreen(),
      '/modal_employee_form':(context) => EmployeeForm()
    },
  ));
}
