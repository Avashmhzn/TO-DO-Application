import 'package:flutter/material.dart';
import 'package:todo_firebase_app/routes/app_route.dart';
import 'package:todo_firebase_app/screen/allTask/view/display.dart';
import 'package:todo_firebase_app/screen/completedscreen/view/completed.dart';
import 'package:todo_firebase_app/screen/home/view/home_screen.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leadingWidth: 40,
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: Container(
                      width: 100,
                      height: 100,
                      color: Colors.black,
                      child: Stack(children: [
                        Positioned(
                          left: -8,
                          bottom: -10,
                          child: Image.asset(
                            'assets/image/logo.png',
                            width: 35,
                            height: 35,
                            color: Colors.white,
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('FocusCraft',style: TextStyle(
                      fontSize: 25, fontWeight: FontWeight.w600, height: 1,fontFamily:'Sfpro'),),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          // Search action
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications),
                        onPressed: () {
                          // Notification action
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () {
                          // Menu action
                        },
                      ),
                    ],
                  );
                } else {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          // Search action
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications),
                        onPressed: () {
                          // Notification action
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () {
                          // Menu action
                        },
                      ),
                    ],
                  );
                }
              },
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: Colors.black,
            tabAlignment: TabAlignment.center,
            labelColor: Colors.black,

            tabs: [
              Tab(text: 'All',),
              Tab(text: 'Work'),
              Tab(text: 'Personal'),
              Tab(text: 'Other'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body:  TabBarView(
          children: [
            DisplayScreen(),
            const HomeScreen(),
            const HomeScreen(),
            const HomeScreen(),
            CompletedScreen(),
          ],
        ),
        backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black,
          shape: const CircleBorder(side: BorderSide(color: Colors.blueGrey)),
          onPressed: () {
            AppRoute().navigateToAddScreen(context);
          },
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 30,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}