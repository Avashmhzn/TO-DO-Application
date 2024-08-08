import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CompletedScreen extends StatelessWidget {
  const CompletedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tasks')
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .where('isCompleted', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No tasks completed today.'));
          }

          var completedTasks = snapshot.data!.docs;
          Map<String, List<DocumentSnapshot>> groupedTasks = {};

          for (var document in completedTasks) {
            DateTime taskDate = document['timestamp'].toDate();
            String formattedDate = DateFormat('yyyy/MM/dd').format(taskDate);
            if (!groupedTasks.containsKey(formattedDate)) {
              groupedTasks[formattedDate] = [];
            }
            groupedTasks[formattedDate]!.add(document);
          }

          return ListView(
            padding: EdgeInsets.zero,
            children: groupedTasks.entries.map((entry) {
              String date = entry.key;
              List<DocumentSnapshot> tasks = entry.value;

              return TaskCategory(
                title: date,
                tasks: tasks,
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class TaskCategory extends StatelessWidget {
  final String title;
  final List<DocumentSnapshot> tasks;

  const TaskCategory({super.key,
    required this.title,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ...tasks.map((task) => TaskItem(task: task)).toList(),
      ],
    );
  }
}

class TaskItem extends StatelessWidget {
  final DocumentSnapshot task;

  const TaskItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    Timestamp timestamp = task['timestamp'];
    DateTime taskDate = timestamp.toDate();
    TimeOfDay taskTime = TimeOfDay.fromDateTime(taskDate);
    return SingleChildScrollView(
      child: ListTile(
        title: Row(
          children: [
            Text(task['title'],style: const TextStyle(fontWeight: FontWeight.bold),),
          ],
        ),
        subtitle: Text(
          '${DateFormat('EEE, MMM d').format(taskDate)}  ${taskTime.format(context)}',
          style: const TextStyle(color: Colors.green,fontWeight: FontWeight.bold),
        ),
        leading: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(task['category'] ?? ''),
          ],
        ),
      ),
    );
  }
}
