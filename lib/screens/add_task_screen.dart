import 'package:flutter/material.dart';
import 'package:todolist_ukk/models/task_model.dart';
import 'package:todolist_ukk/services/db_service.dart';

class AddTaskScreen extends StatefulWidget {
   final VoidCallback? onTaskAdded;

  const AddTaskScreen({super.key, this.onTaskAdded});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final titleController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String selectedCategory = 'Semua';
  bool isReminderOn = false;
  bool isPinned = false;

  // List kategori
  final categories = ['Semua', 'Kerja', 'Pribadi', 'Wishlist'];

  void saveTask() async {
    if (titleController.text.trim().isEmpty) return;

    final task = TaskModel(
      title: titleController.text.trim(),
      date: selectedDate,
      isCompleted: false,
      category: selectedCategory,
      hasReminder: isReminderOn,
      isPinned: isPinned,
    );

    await DBService.insertTask(task);
    widget.onTaskAdded?.call(); // trigger callback ke luar

    Navigator.pop(context); // kembali ke home
  }

  // Picker tanggal
  Future<void> pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Tambah Task"), backgroundColor: Colors.white,),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Judul Task
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Judul",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Picker Tanggal
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.date_range),
              title: const Text("Tanggal"),
              subtitle: Text("${selectedDate.toLocal()}".split(' ')[0]),
              onTap: pickDate,
            ),
            const SizedBox(height: 10),

            // Dropdown Kategori
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(
                labelText: "Kategori",
                border: OutlineInputBorder(),
              ),
              items: categories
                  .map((cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(cat),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedCategory = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Switch Reminder
            SwitchListTile(
              title: const Text("Aktifkan Pengingat"),
              value: isReminderOn,
              onChanged: (val) {
                setState(() {
                  isReminderOn = val;
                });
              },
              secondary: const Icon(Icons.notifications),
            ),

            // Switch Pin
            SwitchListTile(
              title: const Text("Sematkan Task (Pin)"),
              value: isPinned,
              onChanged: (val) {
                setState(() {
                  isPinned = val;
                });
              },
              secondary: const Icon(Icons.push_pin),
            ),
            const SizedBox(height: 20),

            // Tombol Simpan
            ElevatedButton.icon(
              onPressed: saveTask,
              icon: const Icon(Icons.save),
              label: const Text("Simpan Task"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontSize: 16),
              ),
            )
          ],
        ),
      ),
    );
  }
}
