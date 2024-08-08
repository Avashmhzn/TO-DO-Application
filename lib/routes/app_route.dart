import 'package:flutter/material.dart';
import 'package:todo_firebase_app/screen/addtask/view/add_task.dart';
import 'package:todo_firebase_app/screen/allTask/view/display.dart';
import 'package:todo_firebase_app/screen/display_task/view/display_task.dart';
import 'package:todo_firebase_app/screen/home/view/home_screen.dart';
import 'package:todo_firebase_app/screen/login/view/login_screen.dart';
import 'package:todo_firebase_app/screen/search/view/search_screen.dart';
import 'package:todo_firebase_app/screen/signup/view/signup_screen.dart';
import 'package:todo_firebase_app/screen/update/view/update_screen.dart';



class AppRoute {
   navigateToLoginScreen(BuildContext context) {
    return Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  navigateToSignup(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const SignupScreen(),
      ),
    );
  }

  navigateToDisplayTask(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const TaskScreen(),
      ),
    );
  }
  navigateToAddScreen(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const AddTask(),
      ),
    );
  }

  navigateToDisplayScreen(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => DisplayScreen(),
      ),
    );
  }

   navigateToHomeScreen(BuildContext context) {
     Navigator.of(context).pushReplacement(
       MaterialPageRoute(
         builder: (_) => const HomeScreen(),
       ),
     );
   }

   navigateToSearchScreen(BuildContext context) {
     Navigator.of(context).pushReplacement(
       MaterialPageRoute(
         builder: (_) =>  SearchScreen(),
       ),
     );
   }

}