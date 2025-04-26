import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:todolist_ukk/models/task_model.dart';
import 'package:todolist_ukk/models/user_model.dart';
import 'package:todolist_ukk/screens/board_screen.dart';
import 'package:todolist_ukk/screens/home_screen.dart';
import 'package:todolist_ukk/screens/profile_screen.dart';
import 'package:todolist_ukk/services/db_service.dart';

class CalendarScreen extends StatefulWidget {
  final UserModel user;

  const CalendarScreen({super.key, required this.user});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<TaskModel>> _events = {};
  List<TaskModel> _selectedTasks = [];
  int _currentIndex = 2; // Kalender tab index

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  // Load & group task berdasarkan tanggal
  void _loadTasks() async {
    final tasks = await DBService.getAllTasks();
    final Map<DateTime, List<TaskModel>> grouped = {};

    for (var task in tasks) {
      final taskDate =
          DateTime.utc(task.date.year, task.date.month, task.date.day);
      if (grouped[taskDate] == null) {
        grouped[taskDate] = [];
      }
      grouped[taskDate]!.add(task);
    }

    setState(() {
      _events = grouped;
      if (_selectedDay != null) {
        _selectedTasks = _getTasksForDay(_selectedDay!);
      }
    });
  }

  List<TaskModel> _getTasksForDay(DateTime day) {
    return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Kalender"),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: _getTasksForDay,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _selectedTasks = _getTasksForDay(selectedDay);
              });
            },
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              leftChevronVisible: false,
              rightChevronVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            calendarStyle: const CalendarStyle(
              todayDecoration:
                  BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
              selectedDecoration:
                  BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
              markerDecoration: BoxDecoration(
                  color: Colors.redAccent, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _selectedTasks.isEmpty
                ? const Center(child: Text("Tidak ada tugas di hari ini"))
                : ListView.builder(
                    itemCount: _selectedTasks.length,
                    itemBuilder: (_, index) {
                      final task = _selectedTasks[index];
                      return ListTile(
                        leading: Icon(
                          task.isPinned == true
                              ? Icons.push_pin
                              : Icons.task_alt,
                          color: task.isPinned == true
                              ? Colors.orange
                              : Colors.green,
                        ),
                        title: Text(task.title),
                        subtitle: Text(task.category),
                        trailing: task.hasReminder == true
                            ? const Icon(Icons.notifications_active)
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
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
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu',),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Tugas'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Kalender'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Milikku'),
        ],
      ),
    );
  }
}
