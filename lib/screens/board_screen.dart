import 'package:flutter/material.dart';
import 'package:todolist_ukk/screens/calender_screen.dart';
import 'package:todolist_ukk/screens/home_screen.dart';
import 'package:todolist_ukk/screens/profile_screen.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';
import '../services/db_service.dart';

class TaskBoardScreen extends StatefulWidget {
  final UserModel user;
  const TaskBoardScreen({super.key, required this.user});

  @override
  State<TaskBoardScreen> createState() => _TaskBoardScreenState();
}

class _TaskBoardScreenState extends State<TaskBoardScreen> {
  List<TaskModel> allTasks = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  void loadTasks() async {
    final data = await DBService.getAllTasks();
    setState(() {
      allTasks = data;
    });
  }

  List<TaskModel> getTasksByStatus(String status) {
    final now = DateTime.now();
    if (status == 'To Do') {
      return allTasks
          .where((task) => !task.isCompleted && task.date.isAfter(now))
          .toList();
    } else if (status == 'In Progress') {
      return allTasks
          .where((task) => !task.isCompleted && task.date.isBefore(now))
          .toList();
    } else if (status == 'Done') {
      return allTasks.where((task) => task.isCompleted).toList();
    }
    return [];
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TaskBoardScreen(user: widget.user),
          ),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(user: widget.user),
          ),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CalendarScreen(user: widget.user),
          ),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProfileScreen(user: widget.user),
          ),
        );
        break;
    }
  }

  // buildColumn()
  Widget buildColumn(String title, List<TaskModel> tasks) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 10),
            tasks.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'Tidak ada task',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  )
                : ListView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: tasks
                        .map(
                          (task) => Card(
                            child: ListTile(
                              title: Text(task.title),
                              subtitle: Text(task.category),
                              trailing: task.isCompleted
                                  ? Icon(Icons.check_circle,
                                      color: Colors.green)
                                  : null,
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text('Task Board'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildColumn('To Do', getTasksByStatus('To Do')),
            buildColumn('In Progress', getTasksByStatus('In Progress')),
            buildColumn('Done', getTasksByStatus('Done')),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 0)
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TaskBoardScreen(user: widget.user),
              ),
            );
          if (index == 1)
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(user: widget.user),
              ),
            );
          if (index == 2)
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CalendarScreen(user: widget.user),
              ),
            );
          if (index == 3)
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(user: widget.user),
              ),
            );
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Tugas'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Kalender'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Milikku'),
        ],
      ),
    );
  }
}
