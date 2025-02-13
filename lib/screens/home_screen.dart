import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> todos = [];

  // control TextField input
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priorityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchTodos();
  }

  Future<void> fetchTodos() async {
    final response = await http.get(Uri.parse('http://localhost:3000/todos'));
    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      setState(() {
        todos = List<Map<String, dynamic>>.from(responseData);
      });
    } else {
      throw Exception('Failed to load todos');
    }
  }

  Future<void> addTodo() async {
    _titleController.clear();
    _descriptionController.clear();
    _priorityController.clear();

    final newTodoData = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        // use StatefulBuilder to update the dialog content
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add ToDo'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(hintText: 'Enter ToDo title'),
                  ),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(hintText: 'Enter description'),
                  ),
                  TextField(
                    controller: _priorityController,
                    decoration: InputDecoration(hintText: 'Enter priority (0-5)'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (_titleController.text.isNotEmpty && 
                        _descriptionController.text.isNotEmpty) {
                      Navigator.of(context).pop({
                        'title': _titleController.text,
                        'description': _descriptionController.text,
                        'priority': int.tryParse(_priorityController.text) ?? 0
                      });
                    }
                  },
                  child: Text('Add'),
                ),
              ],
            );
          }
        );
      },
    );

    if (newTodoData != null) {
      final response = await http.post(
        Uri.parse('http://localhost:3000/todos'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(newTodoData),
      );

      if (response.statusCode == 201) {
        fetchTodos();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('New ToDo added: ${newTodoData['title']}')),
        );
      } else {
        throw Exception('Failed to add todo');
      }
    }
  }

  Future<void> deleteTodo(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3000/todos/$id'),
      );

      if (response.statusCode == 200) {
        setState(() {
          todos.removeWhere((todo) => todo['id'] == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ToDo deleted successfully')),
        );
      } else {
        throw Exception('Failed to delete todo');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting todo: $error')),
      );
    }
  }

  // 添加确认删除对话框
  Future<void> showDeleteConfirmation(int id) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this todo?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                deleteTodo(id);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> updateTodo(int id) async {
    // 設置初始值
    _titleController.text = todos.firstWhere((todo) => todo['id'] == id)['title'];
    _descriptionController.text = todos.firstWhere((todo) => todo['id'] == id)['description'];
    _priorityController.text = todos.firstWhere((todo) => todo['id'] == id)['priority'].toString();

    final updatedTodoData = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Update ToDo'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(labelText: 'Title'),
                  ),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: 'Description'),
                  ),
                  TextField(
                    controller: _priorityController,
                    decoration: InputDecoration(labelText: 'Priority (0-5)'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (_titleController.text.isNotEmpty && 
                        _descriptionController.text.isNotEmpty) {
                      Navigator.of(context).pop({
                        'title': _titleController.text,
                        'description': _descriptionController.text,
                        'priority': int.tryParse(_priorityController.text) ?? 0
                      });
                    }
                  },
                  child: Text('Update'),
                ),
              ],
            );
          }
        );
      },
    );

    if (updatedTodoData != null) {
      try {
        final response = await http.put(
          Uri.parse('http://localhost:3000/todos/$id'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(updatedTodoData),
        );

        if (response.statusCode == 200) {
          fetchTodos(); // 重新獲取更新後的列表
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ToDo updated successfully')),
          );
        } else {
          throw Exception('Failed to update todo');
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating todo: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ToDo List'),
      ),
      body: ListView.builder(
        itemCount: todos.length,
        itemBuilder: (BuildContext context, int index) {
          return Dismissible(
            key: Key(todos[index]['id'].toString()),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 20),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              deleteTodo(todos[index]['id']);
            },
            confirmDismiss: (direction) async {
              return await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Confirm Delete'),
                    content: Text('Are you sure you want to delete this todo?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text('Delete'),
                      ),
                    ],
                  );
                },
              );
            },
            child: ListTile(
              title: Text(todos[index]['title']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Description: ${todos[index]['description'] ?? 'No description'}'),
                  Text('Priority: ${todos[index]['priority']}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => updateTodo(todos[index]['id']),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => showDeleteConfirmation(todos[index]['id']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addTodo,
        child: Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    // clear the controllers when the widget is disposed
    _titleController.dispose();
    _descriptionController.dispose();
    _priorityController.dispose();
    super.dispose();
  }

}
