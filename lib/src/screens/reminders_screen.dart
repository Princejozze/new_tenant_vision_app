import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> with SingleTickerProviderStateMixin {
  List<Reminder> _reminders = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadReminders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReminders() async {
    print('Loading reminders...');
    final prefs = await SharedPreferences.getInstance();
    final remindersJson = prefs.getString('reminders');
    
    if (remindersJson != null && remindersJson.isNotEmpty) {
      final decoded = jsonDecode(remindersJson) as List;
      setState(() {
        _reminders = decoded.map((json) => Reminder.fromJson(json)).toList();
      });
      print('Loaded ${_reminders.length} reminders');
    } else {
      print('No reminders found');
    }
  }

  Future<void> _saveReminders() async {
    print('Saving ${_reminders.length} reminders');
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(_reminders.map((r) => r.toJson()).toList());
    await prefs.setString('reminders', jsonString);
    print('Saved successfully');
  }

  void _addReminder(String title, DateTime dueDate, String notes) {
    final reminder = Reminder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      dueDate: dueDate,
      notes: notes,
      isCompleted: false,
    );
    
    setState(() {
      _reminders.add(reminder);
    });
    _saveReminders();
    Navigator.pop(context);
  }

  void _toggleCompletion(Reminder reminder) {
    setState(() {
      final index = _reminders.indexOf(reminder);
      _reminders[index] = Reminder(
        id: reminder.id,
        title: reminder.title,
        dueDate: reminder.dueDate,
        notes: reminder.notes,
        isCompleted: !reminder.isCompleted,
      );
    });
    _saveReminders();
  }

  void _deleteReminder(Reminder reminder) {
    setState(() {
      _reminders.remove(reminder);
    });
    _saveReminders();
  }

  @override
  Widget build(BuildContext context) {
    final activeReminders = _reminders.where((r) => !r.isCompleted).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    final completedReminders = _reminders.where((r) => r.isCompleted).toList()
      ..sort((b, a) => a.id.compareTo(b.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReminderList(activeReminders),
          _buildReminderList(completedReminders),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: () => _showAddDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Add Reminder'),
            )
          : null,
    );
  }

  Widget _buildReminderList(List<Reminder> reminders) {
    if (reminders.isEmpty) {
      return const Center(child: Text('No reminders'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reminders.length,
      itemBuilder: (context, index) {
        final reminder = reminders[index];
        final isOverdue = !reminder.isCompleted && reminder.dueDate.isBefore(DateTime.now());

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: isOverdue ? Colors.red[50] : null,
          child: ListTile(
            leading: Checkbox(
              value: reminder.isCompleted,
              onChanged: (value) => _toggleCompletion(reminder),
            ),
            title: Text(
              reminder.title,
              style: reminder.isCompleted
                  ? const TextStyle(decoration: TextDecoration.lineThrough)
                  : TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isOverdue ? Colors.red : null,
                    ),
            ),
            subtitle: Text(DateFormat('MMM dd, yyyy').format(reminder.dueDate)),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: const Text('Delete'),
                  onTap: () {
                    Future.delayed(Duration.zero, () {
                      _deleteReminder(reminder);
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddDialog() {
    final titleController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Reminder'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(selectedDate == null
                    ? 'Select Date'
                    : DateFormat('MMM dd, yyyy').format(selectedDate!)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setDialogState(() => selectedDate = date);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty && selectedDate != null) {
                  _addReminder(titleController.text, selectedDate!, '');
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class Reminder {
  final String id;
  final String title;
  final DateTime dueDate;
  final String notes;
  final bool isCompleted;

  Reminder({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.notes,
    required this.isCompleted,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'dueDate': dueDate.toIso8601String(),
        'notes': notes,
        'isCompleted': isCompleted,
      };

  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder(
        id: json['id'] as String,
        title: json['title'] as String,
        dueDate: DateTime.parse(json['dueDate'] as String),
        notes: json['notes'] as String,
        isCompleted: json['isCompleted'] as bool? ?? false,
      );
}


