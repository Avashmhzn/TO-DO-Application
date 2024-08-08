import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:todo_firebase_app/routes/app_route.dart';


class AddTask extends StatefulWidget {
  const AddTask({super.key});

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  final FirebaseAuth _auth =FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController titleController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  String get formattedDate => DateFormat('yyyy-MM-dd').format(selectedDate);
  String get formattedTime => selectedTime.format(context);

  String dropdownValue = "Priority";
  bool isFavorite = false;

  bool isSwitched = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(3000),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }
  Future<void> _addTask() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('tasks').add({
          'title': titleController.text,
          'date': selectedDate,
          'time': selectedTime.format(context),
          'category': dropdownValue,
          'isCompleted': isSwitched,
          'isFavorite': isFavorite,
          'userId': user.uid,
          'timestamp': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task added successfully!')),
        );
        AppRoute().navigateToDisplayTask(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add task: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            AppRoute().navigateToDisplayTask(context);
          },
        ),
        title: const Text(
          'Add Task',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Title",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 5.0),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: 'Enter your title',
                  hintStyle: TextStyle(fontWeight: FontWeight.bold),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    borderSide: BorderSide(
                      color: Colors.black12,
                      width: 2.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    borderSide: BorderSide(
                      color: Colors.black12,
                      width: 2.0,
                    ),
                  ),
                ),
                maxLines: 4,
                minLines: 3,
              ),
              const SizedBox(height: 15),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 20,),
                    const Text("Selected date: ",style: TextStyle(fontWeight: FontWeight.bold),),
                    SizedBox(width: 10,),
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: Text(
                        formattedDate,
                        style: const TextStyle(
                          color: Colors.green,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Text("Time: ",style: TextStyle(fontWeight: FontWeight.bold),),
                    SizedBox(width: 10,),
                    InkWell(
                      onTap: () => _selectTime(context),
                      child: Text(
                        formattedTime,
                        style: const TextStyle(
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  const Text(
                    "Select Task Category:",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: dropdownValue,
                    icon: const Icon(Icons.arrow_drop_down),
                    style: const TextStyle(color: Colors.black),
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownValue = newValue!;
                      });
                    },
                    items: const [
                      DropdownMenuItem<String>(
                          value: 'Priority', child: Text('Priority')),
                      DropdownMenuItem<String>(
                          value: 'Work', child: Text('Work')),
                      DropdownMenuItem<String>(
                          value: 'Personal', child: Text('Personal')),
                      DropdownMenuItem<String>(
                          value: 'Others', child: Text('Others')),
                    ],
                  ),
                ],
              ),
             /* const SizedBox(height: 15),
              Row(
                children: [
                  const Text(
                    "Completed:",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 20),
                  FlutterSwitch(
                    width: 60.0,
                    height: 30.0,
                    toggleSize: 20.0,
                    value: isSwitched,
                    borderRadius: 20.0,
                    padding: 4.0,
                    activeColor: Colors.white,
                    inactiveColor: Colors.white,
                    toggleColor: Colors.white,
                    activeToggleColor: Colors.deepPurple.shade300,
                    inactiveToggleColor: Colors.grey.shade300,
                    activeSwitchBorder: Border.all(
                      color: Colors.black,
                      width: 1.0,
                    ),
                    inactiveSwitchBorder: Border.all(
                      color: Colors.grey.shade300,
                      width: 2.0,
                    ),
                    activeIcon: const Icon(
                      Icons.circle,
                      color: Colors.white,
                    ),
                    inactiveIcon: const Icon(
                      Icons.circle,
                      color: Colors.white,
                    ),
                    onToggle: (val) {
                      setState(() {
                        isSwitched = val;
                      });
                    },
                  ),
                ],
              ),*/
              const SizedBox(height: 15),
              Row(
                children: [
                  const Text(
                    "Favourite: ",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.star : Icons.star_border,
                      color: Colors.orange,
                      size: 30,
                    ),
                    onPressed: () {
                      setState(() {
                        isFavorite = !isFavorite;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 250.0),
              ElevatedButton(
                onPressed: _addTask,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
                  fixedSize: MaterialStateProperty.all<Size>(const Size(500, 50)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
                child: const Text(
                  "Save",
                  style: TextStyle(
                    color: Colors.white,//changed color
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}