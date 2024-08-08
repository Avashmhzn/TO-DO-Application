import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:todo_firebase_app/routes/app_route.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _obscureText = true;
  bool _obscureText1 = true;
  bool rememberPassword = true;

  TextEditingController emailController = TextEditingController();
  RegExp emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
  bool validateEmail(String email) {
    String email0 = email.trim();

    if (emailRegex.hasMatch(email0)) {
      return true;
    } else {
      return false;
    }
  }


  TextEditingController passwordController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey();
  RegExp passValid = RegExp(r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$");
  bool validatePassword(String pass) {
    String password = pass.trim();
    if (passValid.hasMatch(password)) {
      return true;
    } else {
      return false;
    }
  }

  TextEditingController rePasswordController = TextEditingController();
  RegExp rpassValid = RegExp(r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$");
  bool validatePassword1(String pass) {
    String password = pass.trim();

    if (passValid.hasMatch(password)) {
      return true;
    } else {
      return false;
    }
  }

  void createAccount() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String rPassword = rePasswordController.text.trim();

    if (email == "" || password == "" || rPassword == "") {
      log('password enter your email');
    } else if (password != rPassword) {
      log('Passwords do not match!');
    } else if (email == 'email-already-in-use') {
      log('The account already exists for that email.');
    } else {
      try{
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        var authCredential = userCredential.user;
        print(authCredential!.uid);
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set({
          'email':emailController.text,
          'password':passwordController.text,
        });
        if (userCredential.user != null){
          AppRoute().navigateToLoginScreen(context);
        }
      } on FirebaseAuthException catch (ex){
        log(ex.code.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 20,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: () {},
        ),
        title: const Row(
          children: [
            SizedBox(width: 8),
            Text('Registration',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    fontFamily: 'Sfpro')),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Create a free\naccount',
                      style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w600,
                          height: 1,
                          fontFamily: 'Sfpro'),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Email',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(
                            10), // Change the border radius here
                      ),
                      height: 50,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          cursorColor: Colors.grey,
                          validator: (value){
                            if (value == null || value.isEmpty) {
                              return 'Email must not be empty';
                            } else {
                              bool result = validateEmail(value);
                              if (result) {
                                return null;
                              } else {
                                return "Email Must contain '@'";
                              }
                            }
                          },
                          decoration: const InputDecoration(
                            hintText: 'Enter your email',
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Password',
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      height: 50,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          obscureText: _obscureText,
                          obscuringCharacter: '*',
                          controller: passwordController,
                          keyboardType: TextInputType.visiblePassword,
                          cursorColor: Colors.grey,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Password must not be empty';
                            } else {
                              bool result = validatePassword(value);
                              if (result) {
                                return null;
                              } else {
                                return "Password should contain 8 Characters , Capital, small letter and number";
                              }
                            }
                          },
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
                                  Icons.remove_red_eye,
                                  size: 20,
                                ))
                                : IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscureText = true;
                                  });
                                },
                                icon: const Icon(
                                  Icons.visibility_off,
                                  size: 20,
                                )),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Repeat Password',
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      height: 50,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          obscureText: _obscureText1,
                          obscuringCharacter: '*',
                          controller: rePasswordController,
                          keyboardType: TextInputType.visiblePassword,
                          cursorColor: Colors.grey,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Password must not be empty';
                            } else {
                              bool result = validatePassword1(value);
                              if (result) {
                                return null;
                              } else {
                                return "Password should contain 8 Characters , Capital, small letter and number";
                              }
                            }
                          },
                          decoration: InputDecoration(
                            hintText: 'Enter your password again',
                            border: InputBorder.none,
                            hintStyle: const TextStyle(color: Colors.grey),
                            suffixIcon: _obscureText1 == true
                                ? IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscureText1 = false;
                                  });
                                },
                                icon: const Icon(
                                  Icons.remove_red_eye,
                                  size: 20,
                                ))
                                : IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscureText1 = true;
                                  });
                                },
                                icon: const Icon(
                                  Icons.visibility_off,
                                  size: 20,
                                )),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      height: 60,
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            backgroundColor: Colors.black),
                        onPressed: () {
                          createAccount();
                        },
                        label: const Text(
                          'Register',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          'Or',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 50,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              border: Border.all(color: Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(MdiIcons.google,
                                    color: Colors.red, size: 30),
                                const SizedBox(width: 10, height: 20),
                                const Text(
                                  'Continue with Google',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 15,
                            height: 15,
                          ),
                          Container(
                            height: 50,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              border: Border.all(color: Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.apple,
                                  size: 30,
                                ),
                                SizedBox(width: 10, height: 20),
                                Text(
                                  'Continue with Apple',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 80,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "If You Have A Account ",
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  AppRoute().navigateToLoginScreen(context);
                                },
                                child: const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Sfpro',
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
