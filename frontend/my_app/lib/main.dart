import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(ToDoApp());

class Task {
  final int id;
  final String title;
  final bool completed;
  final String dueDate;
  final String endDate;
  final String? startTime;
  final String? endTime;

  Task({
    required this.id,
    required this.title,
    required this.completed,
    required this.dueDate,
    required this.endDate,
    this.startTime,
    this.endTime,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      completed: json['completed'],
      dueDate: json['dueDate'],
      endDate: json['endDate'] ?? json['dueDate'],
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'completed': completed,
      'dueDate': dueDate,
      'endDate': endDate,
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}

class ToDoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ToDoHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ToDoHomePage extends StatefulWidget {
  @override
  _ToDoHomePageState createState() => _ToDoHomePageState();
}

class _ToDoHomePageState extends State<ToDoHomePage> {
  final TextEditingController _controller = TextEditingController();
  List<Task> tasks = [];
  DateTime? _selectedDueDate;
  DateTime? _selectedEndDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  final String baseUrl = 'http://localhost:8080/api/tasks';

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          tasks = data.map((json) => Task.fromJson(json)).toList();
        });
      }
    } catch (e) {
      print('Error fetching tasks: $e');
    }
  }

  String _formatTime(TimeOfDay? time) {
    return time != null ? time.format(context) : '';
  }

  TimeOfDay? _parseTime(String timeStr) {
    if (timeStr.isEmpty) return null;
    try {
      final parts = timeStr.split(' ');
      final hm = parts[0].split(':').map(int.parse).toList();
      int hour = hm[0];
      int minute = hm[1];
      if (parts.length > 1) {
        if (parts[1] == 'PM' && hour != 12) hour += 12;
        if (parts[1] == 'AM' && hour == 12) hour = 0;
      }
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return null;
    }
  }

  DateTime? _combineDateTime(String dateStr, String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return null;
    final date = DateTime.tryParse(dateStr);
    if (date == null) return null;
    final parts = timeStr.split(" ");
    final hm = parts[0].split(":").map(int.parse).toList();
    int hour = hm[0];
    int minute = hm[1];
    if (parts.length > 1) {
      if (parts[1] == "PM" && hour != 12) hour += 12;
      if (parts[1] == "AM" && hour == 12) hour = 0;
    }
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  Future<void> _addTask() async {
    if (_controller.text.isEmpty ||
        _selectedDueDate == null ||
        _selectedEndDate == null ||
        _startTime == null ||
        _endTime == null) return;

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': _controller.text,
          'completed': false,
          'dueDate': _selectedDueDate!.toIso8601String(),
          'endDate': _selectedEndDate!.toIso8601String(),
          'startTime': _formatTime(_startTime),
          'endTime': _formatTime(_endTime),
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final task = Task.fromJson(jsonDecode(response.body));
        setState(() {
          tasks.add(task);
          _controller.clear();
          _selectedDueDate = null;
          _selectedEndDate = null;
          _startTime = null;
          _endTime = null;
        });
      }
    } catch (e) {
      print('Error adding task: $e');
    }
  }

  void _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDueDate = picked);
  }

  void _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: _selectedDueDate ?? DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedEndDate = picked);
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      setState(() {
        if (isStart) _startTime = picked;
        else _endTime = picked;
      });
    }
  }

  Widget _buildInfoRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_selectedDueDate != null)
            Text("📅 Start: ${_selectedDueDate!.toLocal().toString().split(' ')[0]}"),
          if (_selectedEndDate != null)
            Text("🏁 End: ${_selectedEndDate!.toLocal().toString().split(' ')[0]}"),
          if (_startTime != null) Text("⏱️ Start Time: ${_startTime!.format(context)}"),
          if (_endTime != null) Text("🛑 End Time: ${_endTime!.format(context)}"),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task, int index) {
    return Card(
      child: ListTile(
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.completed ? TextDecoration.lineThrough : TextDecoration.none,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
            "📅 ${task.dueDate.split('T')[0]} → ${task.endDate.split('T')[0]} | ⏱️ ${task.startTime} - 🛑 ${task.endTime}"),
        leading: Checkbox(value: task.completed, onChanged: (_) => _toggleTask(index)),
        trailing: Wrap(
          spacing: 8,
          children: [
            IconButton(icon: Icon(Icons.edit, color: Colors.blue), onPressed: () => _editTask(task)),
            IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteTask(task.id)),
          ],
        ),
      ),
    );
  }

  List<Task> get _completedTasks => tasks.where((t) => t.completed).toList();

  List<Task> get _inactiveTasks => tasks.where((t) {
    if (t.completed) return false;
    final now = DateTime.now();
    final start = _combineDateTime(t.dueDate, t.startTime);
    return start != null && start.isAfter(now);
  }).toList();

  List<Task> get _activeTasks => tasks.where((t) {
    if (t.completed) return false;
    final now = DateTime.now();
    final start = _combineDateTime(t.dueDate, t.startTime);
    final end = _combineDateTime(t.endDate, t.endTime);
    return start != null && end != null && now.isAfter(start) && now.isBefore(end);
  }).toList();

  List<Task> get _deadlineTasks => tasks.where((t) {
    if (t.completed) return false;
    final end = _combineDateTime(t.endDate, t.endTime);
    return end != null && end.isBefore(DateTime.now());
  }).toList();

  Future<void> _toggleTask(int index) async {
    final task = tasks[index];
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/${task.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': task.id,
          'title': task.title,
          'completed': !task.completed,
          'dueDate': task.dueDate,
          'endDate': task.endDate,
          'startTime': task.startTime,
          'endTime': task.endTime,
        }),
      );
      if (response.statusCode == 200) _fetchTasks();
    } catch (e) {
      print('Error updating task: $e');
    }
  }

  Future<void> _deleteTask(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
      if (response.statusCode == 200) {
        setState(() => tasks.removeWhere((task) => task.id == id));
      }
    } catch (e) {
      print('Error deleting task: $e');
    }
  }

  Future<void> _editTask(Task task) async {
    final titleController = TextEditingController(text: task.title);
    DateTime? dueDate = DateTime.tryParse(task.dueDate);
    DateTime? endDate = DateTime.tryParse(task.endDate);
    TimeOfDay? start = _parseTime(task.startTime ?? '');
    TimeOfDay? end = _parseTime(task.endTime ?? '');

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("✏️ Edit Task"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: titleController, decoration: InputDecoration(labelText: "Title")),
                ElevatedButton(
                  onPressed: _pickDueDate,
                  child: Text(dueDate != null ? "📅 ${dueDate.toLocal().toString().split(' ')[0]}" : "Pick Start Date"),
                ),
                ElevatedButton(
                  onPressed: _pickEndDate,
                  child: Text(endDate != null ? "🏁 ${endDate.toLocal().toString().split(' ')[0]}" : "Pick End Date"),
                ),
                ElevatedButton(
                  onPressed: () => _pickTime(true),
                  child: Text(start != null ? "⏱️ ${start.format(context)}" : "Pick Start Time"),
                ),
                ElevatedButton(
                  onPressed: () => _pickTime(false),
                  child: Text(end != null ? "🛑 ${end.format(context)}" : "Pick End Time"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            TextButton(
              child: Text("Update"),
              onPressed: () async {
                final response = await http.put(
                  Uri.parse('$baseUrl/${task.id}'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({
                    'id': task.id,
                    'title': titleController.text,
                    'completed': task.completed,
                    'dueDate': dueDate?.toIso8601String(),
                    'endDate': endDate?.toIso8601String(),
                    'startTime': _formatTime(start),
                    'endTime': _formatTime(end),
                  }),
                );
                if (response.statusCode == 200) _fetchTasks();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 30),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.deepPurple, Colors.purple]),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Column(
              children: [
                Text("📝 To-Do App", style: TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold)),
                Text("${_completedTasks.length} of ${tasks.length} tasks completed", style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _controller, decoration: InputDecoration(hintText: "Enter task title"))),
                IconButton(icon: Icon(Icons.calendar_today), onPressed: _pickDueDate),
                IconButton(icon: Icon(Icons.flag), onPressed: _pickEndDate),
                IconButton(icon: Icon(Icons.play_arrow), onPressed: () => _pickTime(true)),
                IconButton(icon: Icon(Icons.stop), onPressed: () => _pickTime(false)),
                IconButton(icon: Icon(Icons.add_circle, color: Colors.purple), onPressed: _addTask),
              ],
            ),
          ),
          _buildInfoRow(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(12),
              children: [
                if (_inactiveTasks.isNotEmpty) ...[
                  Text('🕓 Inactive Tasks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
                  ..._inactiveTasks.map((t) => _buildTaskCard(t, tasks.indexOf(t))),
                ],
                if (_activeTasks.isNotEmpty) ...[
                  Text('✅ Active Tasks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ..._activeTasks.map((t) => _buildTaskCard(t, tasks.indexOf(t))),
                ],
                if (_deadlineTasks.isNotEmpty) ...[
                  Text('⏰ Overdue Tasks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
                  ..._deadlineTasks.map((t) => _buildTaskCard(t, tasks.indexOf(t))),
                ],
                if (_completedTasks.isNotEmpty) ...[
                  Text('✔ Completed Tasks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                  ..._completedTasks.map((t) => _buildTaskCard(t, tasks.indexOf(t))),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
