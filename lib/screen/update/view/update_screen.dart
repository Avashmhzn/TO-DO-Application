import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class UpdateTaskPage extends StatefulWidget {
  final String taskId;

  const UpdateTaskPage({super.key, required this.taskId});

  @override
  _UpdateTaskPageState createState() => _UpdateTaskPageState();
}

class _UpdateTaskPageState extends State<UpdateTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  bool _isCompleted = false;
  bool _isFavorite = false;
  String _selectedCategory = 'Completed';
  TimeOfDay _selectedTime = TimeOfDay.now();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTask();
  }

  Future<void> _fetchTask() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('User not logged in');
        return;
      }

      DocumentSnapshot task = await FirebaseFirestore.instance
          .collection('tasks')
          .doc(widget.taskId)
          .get();

      if (task.exists && task['userId'] == user.uid) {
        setState(() {
          _titleController.text = task['title'];
          _isCompleted = task['isCompleted'];
          _isFavorite = task['isFavorite'];
          _selectedCategory = task['category'];
          DateTime taskDateTime = task['timestamp'].toDate();
          _selectedTime = TimeOfDay.fromDateTime(taskDateTime);
          _selectedDate = taskDateTime;
          _isLoading = false;
        });
      } else {
        print('Task not found or user mismatch');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching task: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(3000),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _updateTask() async {
    if (_formKey.currentState!.validate()) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('User not logged in');
        return;
      }

      DateTime taskDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(widget.taskId)
          .update({
        'title': _titleController.text,
        'isCompleted': _isCompleted,
        'isFavorite': _isFavorite,
        'category': _selectedCategory,
        'timestamp': taskDateTime,
        'userId': user.uid,
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Update Task',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        "Title",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          hintText: 'Enter your title',
                          hintStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 14),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(
                              color: Colors.black12,
                              width: 2.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(
                              color: Colors.black12,
                              width: 2.0,
                            ),
                          ),
                        ),
                        maxLines: 4,
                        minLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text('Completed: ', style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                          Switch(
                            value: _isCompleted,
                            onChanged: (value) {
                              setState(() {
                                _isCompleted = value;
                              });
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('Favorite: ',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: Icon(
                              _isFavorite ? Icons.star : Icons.star_border,
                              color: _isFavorite ? Colors.yellow : Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _isFavorite = !_isFavorite;
                              });
                            },
                          ),
                        ],
                      ),
                      DropdownButtonFormField(
                        value: _selectedCategory,
                        items: [
                          'Priority',
                          'Work',
                          'Personal',
                          'Others',
                        ]
                            .map((category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value as String;
                          });
                        },
                        decoration: const InputDecoration(
                            labelText: 'Select Task Category',labelStyle: TextStyle(fontSize: 18,fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText:
                              'Selected Time: ${_selectedTime.format(context)}',
                          labelStyle: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        onTap: () => _selectTime(context),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText:
                              'Selected Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
                          labelStyle: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        onTap: () => _selectDate(context),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _updateTask,
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.black),
                          fixedSize: MaterialStateProperty.all<Size>(
                              const Size(500, 50)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                        ),
                        child: const Text(
                          "Update Task ",
                          style: TextStyle(
                            color: Colors.white, //changed color
                            fontWeight: FontWeight.bold,
                          ),
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
