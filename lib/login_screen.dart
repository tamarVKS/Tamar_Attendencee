// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:tamar_attendence/dashboard.dart';
import 'package:tamar_attendence/adminpages/admin.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final LocalAuthentication auth = LocalAuthentication();

  bool isLoading = false;
  bool rememberMe = false;
  bool _obscurePassword = true;

  final String adminEmail = "pradeep@gmail.com";
  final String adminPassword = "123456";

  Future<void> login() async {
    setState(() {
      isLoading = true;
    });

    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      if (email == adminEmail && password == adminPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Admin Login Successful")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminPage()),
        );
      } else {
        final UserCredential userCredential =
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        String userId = userCredential.user!.uid;

        if (rememberMe) {
          await _storage.write(key: 'email', value: email);
          await _storage.write(key: 'password', value: password);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User Login Successful")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardScreen(userId: userId),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Login failed';
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> biometricLogin() async {
    try {
      final bool canCheckBiometrics = await auth.canCheckBiometrics;
      final bool isDeviceSupported = await auth.isDeviceSupported();

      if (!canCheckBiometrics || !isDeviceSupported) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biometric authentication not supported on this device')),
        );
        return;
      }

      final isAuthenticated = await auth.authenticate(
        localizedReason: 'Scan your fingerprint to login',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (isAuthenticated) {
        final email = await _storage.read(key: 'email');
        final password = await _storage.read(key: 'password');

        if (email != null && password != null) {
          emailController.text = email;
          passwordController.text = password;
          await login();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No credentials found. Please login first.')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Biometric authentication failed: $e')),
      );
    }
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.black87),
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.black54,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF006778), Color(0xFF003459)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Company Logo Instead of Text
                Image.asset(
                  'assets/tamar.png',
                  height: 80,
                ),
                const SizedBox(height: 30),
                const Text(
                  '👋 Welcome Back!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Login to your account',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildTextField(emailController, "Email", Icons.email_outlined),
                      const SizedBox(height: 20),
                      _buildTextField(passwordController, "Password", Icons.lock_outline, isPassword: true),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Checkbox(
                            value: rememberMe,
                            onChanged: (val) => setState(() => rememberMe = val ?? false),
                            activeColor: const Color(0xFFFFB200),
                          ),
                          const Text("Remember Me"),
                          const Spacer(),
                          TextButton(
                            onPressed: () => Navigator.pushNamed(context, '/forget_password'),
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(color: Color(0xFF003459)),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: biometricLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF003459),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(Icons.fingerprint, color: Colors.white),
                          label: const Text(
                            "Login with Biometrics",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFB200),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                AnimatedOpacity(
                  duration: const Duration(seconds: 2),
                  opacity: 1,
                  child: Column(
                    children: [
                      const Text(
                        "🚀 Powered by TAMAR Software",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          FaIcon(FontAwesomeIcons.linkedin, color: Colors.white70, size: 20),
                          SizedBox(width: 16),
                          FaIcon(FontAwesomeIcons.twitter, color: Colors.white70, size: 20),
                          SizedBox(width: 16),
                          FaIcon(FontAwesomeIcons.building, color: Colors.white70, size: 20),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
