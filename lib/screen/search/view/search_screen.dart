import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_firebase_app/routes/app_route.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _allTasks = [];
  List<DocumentSnapshot> _filteredResults = [];

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  void _fetchTasks() async {
    final results = await FirebaseFirestore.instance
        .collection('tasks')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .get();

    setState(() {
      _allTasks = results.docs;
      _filteredResults = _allTasks;
    });
  }

  void _search(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredResults = _allTasks;
      });
      return;
    }

    final filtered = _allTasks.where((task) {
      final title = task['title'].toString().toLowerCase();
      return title.contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredResults = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            AppRoute().navigateToDisplayTask(context);
          },
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by Title...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: _search,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _filteredResults.isEmpty
                  ? const Center(
                child: Text(
                  'No tasks found',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
                  : ListView.builder(
                itemCount: _filteredResults.length,
                itemBuilder: (context, index) {
                  final result = _filteredResults[index];
                  return ListTile(
                    title: Text(result['title'],),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Category: ${result['category']}'),
                        Text('Completed: ${result['isCompleted']}'),
                        Text('Favorite: ${result['isFavorite']}'),
                        Text('Time: ${result['time']}'),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
