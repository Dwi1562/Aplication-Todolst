import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todolist_ukk/screens/add_task_screen.dart';
import 'package:todolist_ukk/screens/board_screen.dart';
import 'package:todolist_ukk/screens/home_screen.dart';
import 'package:todolist_ukk/screens/calender_screen.dart';
import 'package:todolist_ukk/screens/edit_task_screen.dart';
import 'package:todolist_ukk/screens/profile_screen.dart';

// Import model dan service lokal
import '../models/user_model.dart';
import '../models/task_model.dart';
import '../services/db_service.dart';

class HomeScreen extends StatefulWidget {
  final UserModel user;
  HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// State dari HomeScreen
class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1;
  final titleController =
      TextEditingController(); // Controller untuk input judul task
  List<TaskModel> tasks = []; // List semua task dari database
  String selectedCategory =
      'Semua'; // Kategori yang dipilih user (untuk filter)

  @override
  void initState() {
    super.initState();
    loadTasks(); // Ambil data task dari database saat layar pertama kali muncul
  }

  // Fungsi ambil data task dari DB berdasarkan kategori
  void loadTasks() async {
    final data = await DBService.getTasksByCategory(selectedCategory);
    setState(() {
      tasks = data;
    });
  }

  void toggleTaskCompletion(TaskModel task) async {
    TaskModel updatedTask = TaskModel(
      id: task.id,
      title: task.title,
      date: task.date,
      category: task.category,
      isCompleted: !task.isCompleted,
      hasReminder: task.hasReminder,
      isPinned: task.isPinned,
    );

    await DBService.updateTask(updatedTask); // Simpan ke database
    loadTasks(); // Reload data setelah update
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

  // Filter task berdasarkan waktu: sebelumnya, hari ini, mendatang, atau selesai
  List<TaskModel> getTasksByDateRange(String type) {
    final today = DateTime.now();
    return tasks.where((task) {
      final taskDate = task.date;
      if (type == 'Sebelumnya')
        return taskDate.isBefore(today) && !task.isCompleted;
      if (type == 'Hari ini')
        return isSameDay(taskDate, today) && !task.isCompleted;
      if (type == 'Masa mendatang')
        return taskDate.isAfter(today) && !task.isCompleted;
      if (type == 'Selesai') return task.isCompleted;
      return false;
    }).toList();
  }

  // Cek apakah dua tanggal adalah hari yang sama
  bool isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  // Widget untuk menampilkan daftar task berdasarkan waktu tertentu
  Widget buildSection(String title, List<TaskModel> items) {
    if (items.isEmpty)
      return SizedBox(); // Kalau tidak ada task, jangan tampilkan apa-apa
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        ...items.map((task) => ListTile(
              onLongPress: () =>
                  showDeleteDialog(task), // Hapus task saat long press
              leading: GestureDetector(
                onTap: () => toggleTaskCompletion(task),
                child: Icon(
                  task.isCompleted
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: task.isCompleted
                      ? Colors.grey
                      : const Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              title: Text(
                task.title,
                style: TextStyle(
                  decoration: task.isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
              subtitle: Text(DateFormat('MM-dd').format(task.date)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (task.hasReminder == true)
                    Icon(Icons.notifications_none, size: 18),
                  if (task.isPinned == true)
                    Icon(Icons.flag_outlined, size: 18),
                  // Tombol edit
                  if (!task.isCompleted)
                    IconButton(
                      icon: Icon(Icons.edit, size: 18),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditTaskScreen(task: task),
                          ),
                        );

                        if (result == true)
                          loadTasks(); // Reload data jika task berhasil diubah
                      },
                    ),
                  // Tombol hapus
                  IconButton(
                    icon: Icon(Icons.delete, size: 18),
                    onPressed: () => showDeleteDialog(task),
                  ),
                ],
              ),
            )),
        SizedBox(height: 16),
      ],
    );
  }

  // Dialog konfirmasi untuk menghapus task
  void showDeleteDialog(TaskModel task) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Hapus Tugas'),
        content: Text('Yakin ingin menghapus "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              await DBService.deleteTask(task.id!); // Hapus dari DB
              Navigator.pop(context);
              loadTasks(); // Refresh tampilan
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Tugas berhasil dihapus')),
              );
            },
            child: Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("Tugas Saya"), backgroundColor: Colors.white),
      // Bagian isi halaman
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Kategori tab sebagai filter (Semua, Kerja, Pribadi, Wishlist)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['Semua', 'Kerja', 'Pribadi', 'Wishlist']
                  .map((e) => ChoiceChip(
                        label: Text(e),
                        backgroundColor: Colors.white,
                        selected: selectedCategory == e,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => selectedCategory = e);
                            loadTasks(); // Ganti kategori
                          }
                        },
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            // Menampilkan task berdasarkan waktu
            if (getTasksByDateRange('Sebelumnya').isEmpty &&
                getTasksByDateRange('Hari ini').isEmpty &&
                getTasksByDateRange('Masa mendatang').isEmpty &&
                getTasksByDateRange('Selesai').isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: Text(
                    "Tidak ada data tugas",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              )
            else ...[
              buildSection("Sebelumnya", getTasksByDateRange('Sebelumnya')),
              buildSection("Hari ini", getTasksByDateRange('Hari ini')),
              buildSection(
                  "Masa mendatang", getTasksByDateRange('Masa mendatang')),
              buildSection("Selesai Hari Ini", getTasksByDateRange('Selesai')),
            ]
          ],
        ),
      ),
      // Tombol tambah task
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddTaskScreen(
                onTaskAdded: () {
                  loadTasks(); // ini untuk refresh Home
                  // bisa tambahkan trigger ke Calendar juga
                },
              ),
            ),
          );
          // Setelah kembali dari AddTask, refresh task
        },
        child: Icon(Icons.add),
      ),
      // Navigasi bawah (bottom navigation)
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
