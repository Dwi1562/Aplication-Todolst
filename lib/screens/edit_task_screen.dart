import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../services/db_service.dart';

class EditTaskScreen extends StatefulWidget {
  final TaskModel task;

  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late TextEditingController titleController;
  late DateTime selectedDate;
  late String selectedCategory;
  bool isPinned = false;
  bool hasReminder = false;

  List<String> categories = ['Kerja', 'Pribadi', 'Wishlist', 'Semua'];

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.task.title);
    selectedDate = widget.task.date;
    selectedCategory = widget.task.category ?? 'Kerja';
    isPinned = widget.task.isPinned == true;
    hasReminder = widget.task.hasReminder == true;
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _saveEdit() async {
    final updatedTask = TaskModel(
      id: widget.task.id,
      title: titleController.text,
      date: selectedDate,
      isCompleted: widget.task.isCompleted,
      category: selectedCategory,
      isPinned: isPinned,
      hasReminder: hasReminder,
    );

    await DBService.updateTask(updatedTask);

    Navigator.pop(context,
        true); // kembali ke halaman sebelumnya dengan tanda update berhasil
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task berhasil diperbarui')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Edit Tugas"), backgroundColor: Colors.white,),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input judul
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Judul Tugas"),
            ),
            const SizedBox(height: 10),

            // Pilih tanggal
            ListTile(
              selectedColor: Colors.white,
              title: const Text("Tanggal"),
              subtitle: Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDate,
            ),

            // Dropdown kategori
            DropdownButtonFormField<String>(
              value: categories.contains(selectedCategory)
                  ? selectedCategory
                  : categories.first,
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
              decoration: const InputDecoration(labelText: "Kategori"),
            ),

            const SizedBox(height: 10),

            // Checkbox untuk pin & reminder
            Row(
              children: [
                Checkbox(
                  value: isPinned,
                  onChanged: (val) {
                    setState(() {
                      isPinned = val ?? false;
                    });
                  },
                ),
                const Text("Tandai (Pin)"),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  value: hasReminder,
                  onChanged: (val) {
                    setState(() {
                      hasReminder = val ?? false;
                    });
                  },
                ),
                const Text("Pengingat"),
              ],
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _saveEdit,
              child: const Text("Simpan Perubahan"),
            ),
          ],
        ),
      ),
    );
  }
}
