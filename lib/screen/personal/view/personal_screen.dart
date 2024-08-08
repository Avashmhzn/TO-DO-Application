import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_firebase_app/screen/home/view/home_screen.dart';
import 'package:todo_firebase_app/screen/update/view/update_screen.dart';

class PersonalScreen extends StatefulWidget {
  const PersonalScreen({super.key});

  @override
  State<PersonalScreen> createState() => _PersonalScreenState();
}

class _PersonalScreenState extends State<PersonalScreen> {
  final _personStream = FirebaseFirestore.instance
      .collection('tasks')
      .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
      .where('category', isEqualTo: 'Personal')
      .snapshots();
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: _personStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.docs.isEmpty) {
            return const HomeScreen();
          }

          List<DocumentSnapshot> todayTasks = [];
          List<DocumentSnapshot> futureTasks = [];
          List<DocumentSnapshot> completedTasks = [];

          DateTime now = DateTime.now();
          String todayDate = DateFormat('yyyy-MM-dd').format(now);

          snapshot.data!.docs.forEach((document) {
            Timestamp timestamp = document['timestamp'];
            DateTime taskDate = timestamp.toDate();
            bool isCompleted = document['isCompleted'];
            if (isCompleted) {
              completedTasks.add(document);
            } else if (DateFormat('yyyy-MM-dd').format(taskDate) == todayDate) {
              todayTasks.add(document);
            } else {
              futureTasks.add(document);
            }
          });

          return ListView(
            padding: EdgeInsets.zero, // Remove default padding
            children: [
              TaskCategory(
                title: 'Today',
                tasks: todayTasks,
                limit: 2,
                showAllButton: true,
              ),
              TaskCategory(
                title: 'Future',
                tasks: futureTasks,
              ),
              TaskCategory(
                title: 'Completed Today',
                tasks: completedTasks,
                limit: 2,
                showAllButton: true,
              ),
            ],
          );
        },
      ),
    );
  }
}
class TaskCategory extends StatefulWidget {
  final String title;
  final List<DocumentSnapshot> tasks;
  final int? limit;
  final bool showAllButton;

  TaskCategory({
    required this.title,
    required this.tasks,
    this.limit,
    this.showAllButton = false,
  });

  @override
  _TaskCategoryState createState() => _TaskCategoryState();
}

class _TaskCategoryState extends State<TaskCategory> {
  bool showAll = false;

  @override
  Widget build(BuildContext context) {
    List<DocumentSnapshot> tasksToShow = widget.tasks;
    if (!showAll && widget.limit != null && widget.tasks.length > widget.limit!) {
      tasksToShow = widget.tasks.sublist(0, widget.limit!);
    }

    return ExpansionTile(
      iconColor: Colors.black,
      title: Text(widget.title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      initiallyExpanded: true,
      children: [
        ...tasksToShow.map((task) => TaskItem(task: task)).toList(),
        if (widget.showAllButton && widget.tasks.length > widget.limit!)
          Padding(
            padding: const EdgeInsets.only(left: 150),
            child: TextButton(
              onPressed: () {
                setState(() {
                  showAll = !showAll;
                });
              },
              child: Text(showAll ? 'Show Less' : 'Show All',style: TextStyle(color: Colors.black),),
            ),
          ),
      ],
    );
  }
}
class TaskItem extends StatelessWidget {
  final DocumentSnapshot task;

  TaskItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    Timestamp timestamp = task['timestamp'];
    DateTime taskDate = timestamp.toDate();
    TimeOfDay taskTime = TimeOfDay.fromDateTime(taskDate);
    bool isCompleted = task['isCompleted'];

    return GestureDetector(
      onLongPress: () {
        _showDeleteConfirmationDialog(context, task);
      },
      child: ListTile(
        leading: Checkbox(
          value: isCompleted,
          shape: const CircleBorder(side: BorderSide(
            width: 2.0
          )),
          activeColor: Colors.black,
          onChanged: (bool? value) {
            changeTodoStatus(task, value);
          },
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                task['title'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            if (!isCompleted)
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UpdateTaskPage(taskId: task.id),
                    ),
                  );
                },
              ),
            IconButton(
              icon: Icon(Icons.flag,
                  color: isCompleted ? Colors.green : Colors.red),
              onPressed: () {
                // Flag task as important
              },
            ),
          ],
        ),
        subtitle: Text(
          '${DateFormat('EEE, MMM d').format(taskDate)}  ${taskTime.format(context)}',
          style: TextStyle(color: isCompleted ? Colors.green : Colors.red),
        ),
      ),
    );
  }

  void changeTodoStatus(DocumentSnapshot<Object?> task, bool? value) {
    FirebaseFirestore.instance.collection('tasks').doc(task.id).update({
      'isCompleted': value,
    });
  }
  void _showDeleteConfirmationDialog(
      BuildContext context, DocumentSnapshot task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Delete Task'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                _deleteTask(task);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteTask(DocumentSnapshot task) {
    FirebaseFirestore.instance.collection('tasks').doc(task.id).delete();
  }
}
