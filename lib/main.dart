import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tamar_attendence/forget_password.dart';
import 'package:tamar_attendence/perosnalInformation.dart';
import 'package:tamar_attendence/profile.dart';
import 'package:tamar_attendence/report_attendance.dart';
import 'package:tamar_attendence/signup_page.dart';
import 'SignIn.dart';
import 'admin.dart';
import 'attendance_history.dart';
import 'changePassword.dart';
import 'clockinout.dart';
import 'dashboard.dart';
import 'employee_details.dart';
import 'firebase_options.dart';
import 'leavepage.dart';
import 'login_screen.dart';
import 'notification_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //FirebaseAuth auth = FirebaseAuth.instance;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase Initialized Successfully");
  } catch (e) {
    print("Firebase Initialization Failed: $e");
  }
  runApp( MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: 'profile',
    routes: {
      'login_screen': (context) => LoginScreen(),
      'SignIn':(context) => SignInPage(),
      'signup_page':(context)=>SignUpPage(),
      'dashboard':(context) =>DashboardScreen(),
      'clockinout':(context) =>LiveAttendanceScreen(),
      'profile':(context) => ProfilePage(),
      'admin':(context)=>AdminPage(),
      'employee_details':(context)=> EmployeeScreen(),
      'attendance_history':(context)=> AttendanceHistoryScreen(),
      'report_attendance':(context)=>ReportAttendanceScreen(),
      'leave page':(context)=>LeaveManagementScreen(),
      'notification_page':(context)=> NotificationsScreen(),
      'personalInformation':(context)=>PersonalInformationScreen(),
      'changePassword':(context)=> ChangePasswordScreen(),
      'forget_password' : (context) => ForgotPasswordPage()
    },
  ));
}
