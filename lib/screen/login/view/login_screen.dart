import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_firebase_app/routes/app_route.dart';
import 'package:todo_firebase_app/user_auth/firebase_auth_implementation/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  bool _obscureText = true;
  bool _isLoading = false;
  String emailErrorMessage = '';
  String passwordErrorMessage = '';

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RegExp emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
  final RegExp passwordRegex =
      RegExp(r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$");

  final AuthService _authService = AuthService();
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _colorAnimation = ColorTween(
      begin: Colors.red,
      end: Colors.blue,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool validateEmail(String email) {
    return emailRegex.hasMatch(email.trim());
  }

  bool validatePassword(String password) {
    return passwordRegex.hasMatch(password.trim());
  }

  Future<void> saveUserLoggedIn(bool isLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
  }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      await _authService.signOut();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      print('Logout failed: $e');
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      setState(() {
        _isLoading = true;
      });

      await FirebaseAuth.instance.signOut();
      await _authService.signOut();

      User? user = await _authService.signInWithGoogle();

      if (user != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        AppRoute().navigateToDisplayTask(context);
      } else {
        print('Google sign in failed');
      }
    } catch (e) {
      print('Error signing in with Google: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    setState(() {
      emailErrorMessage = '';
      passwordErrorMessage = '';
    });

    if (email.isEmpty || password.isEmpty) {
      if (email.isEmpty) {
        setState(() {
          emailErrorMessage = 'Please enter your email';
        });
      }
      if (password.isEmpty) {
        setState(() {
          passwordErrorMessage = 'Please enter your password';
        });
      }
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          await saveUserLoggedIn(true);
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          showErrorSnackbar(context, 'User not found in Firestore',
              backgroundColor: Colors.red);
        }
      }
    } on FirebaseAuthException catch (ex) {
      showErrorSnackbar(context, 'Login failed: ${ex.message}',
          backgroundColor: Colors.red);
    }
  }

  Future<void> sendPasswordResetEmail() async {
    String email = emailController.text.trim();

    if (email.isEmpty) {
      showErrorSnackbar(context, "Please enter your email",
          backgroundColor: Colors.orange);
      return;
    } else if (!validateEmail(email)) {
      showErrorSnackbar(context, "Invalid email format",
          backgroundColor: Colors.orange);
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      showErrorSnackbar(context, "Password reset email sent",
          backgroundColor: Colors.green);
    } on FirebaseAuthException catch (ex) {
      showErrorSnackbar(context, "Error: ${ex.message}",
          backgroundColor: Colors.red);
    }
  }

  void showErrorSnackbar(BuildContext context, String message,
      {Color backgroundColor = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        width: 120,
                        height: 120,
                        color: Colors.black,
                        child: Stack(
                          children: [
                            Positioned(
                              left: -16,
                              bottom: -18,
                              child: Image.asset(
                                'assets/image/logo.png',
                                width: 110,
                                height: 110,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Center(
                    child: Text(
                      "FocusCraft",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: Text(
                      'Email',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      height: 50,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          cursorColor: Colors.grey,
                          decoration: const InputDecoration(
                            hintText: 'Enter your email',
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (emailErrorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
                      child: Text(
                        emailErrorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 15),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
                    child: Text('Password:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      height: 50,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          obscureText: _obscureText,
                          controller: passwordController,
                          keyboardType: TextInputType.visiblePassword,
                          cursorColor: Colors.grey,
                          decoration: InputDecoration(
                            hintText: 'Enter your password',
                            border: InputBorder.none,
                            hintStyle: const TextStyle(color: Colors.grey),
                            suffixIcon: _obscureText == true
                                ? IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _obscureText = false;
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.remove_red_eye_outlined,
                                      size: 20,
                                    ),
                                  )
                                : IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _obscureText = true;
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.visibility_off,
                                      size: 20,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (passwordErrorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
                      child: Text(
                        passwordErrorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          onTap: () {
                            sendPasswordResetEmail();
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          backgroundColor: Colors.black,
                        ),
                        onPressed: () {
                          login();
                        },
                        label: const Text(
                          'Log in',
                          style: TextStyle(color: Colors.white, fontSize: 17),
                        ),
                        icon: Container(), // Remove loader
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        'Or',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Colors.black),
                        ),
                        onPressed: _isLoading ? null : _signInWithGoogle,
                        icon: _isLoading
                            ? CircularProgressIndicator(
                                valueColor: _colorAnimation,
                              )
                            : Brand(Brands.google),
                        label: SizedBox(
                          width: 300,
                          height: 50,
                          child: Center(
                            child: const Text(
                              'Sign in with Google',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 17),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(fontSize: 15),
                      ),
                      GestureDetector(
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 15),
                        ),
                        onTap: () => AppRoute().navigateToSignup(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
