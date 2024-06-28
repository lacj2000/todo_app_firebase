import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_app_firebase/models/todo.dart';
import 'package:todo_app_firebase/services/database_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _textEditingController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: _buildUI(),
      floatingActionButton: FloatingActionButton(
        onPressed: _displayTextInputDialog,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: const Icon(
          Icons.add,
          color: Colors.black,
        ),
      ),
    );
  }

  void _displayTextInputDialog() async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Add Task'),
            content: TextField(
              controller: _textEditingController,
              decoration: const InputDecoration(hintText: "Todo..."),
            ),
            actions: <Widget>[
              MaterialButton(
                  textColor: Colors.black,
                  color: Theme.of(context).colorScheme.primaryContainer,
                  onPressed: () {
                    Navigator.pop(context);
                    if (_textEditingController.text != "") {
                      Todo newTodo = Todo(
                          task: _textEditingController.text,
                          isDone: false,
                          createdAt: Timestamp.now(),
                          updatedAt: Timestamp.now());
                      _databaseService.addTodo(newTodo);
                    }
                    _textEditingController.clear();
                  },
                  child: const Text("Save"))
            ],
          );
        });
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Text(widget.title),
      centerTitle: true,
    );
  }

  Widget _buildUI() {
    return SafeArea(
        child: Column(
      children: [
        _messagesListView(),
      ],
    ));
  }

  Widget _messagesListView() {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.8,
      width: MediaQuery.sizeOf(context).width,
      child: StreamBuilder(
        stream: _databaseService.getTodos(),
        builder: (context, snapshot) {
          List todos = snapshot.data?.docs ?? [];
          if (todos.isEmpty) {
            return const Center(
              child: Text("Add To Do!"),
            );
          }
          return ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                Todo todo = todos[index].data();
                String idTodo = todos[index].id;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 10,
                  ),
                  child: ListTile(
                      tileColor: Theme.of(context).colorScheme.primaryContainer,
                      title: Text(todo.task),
                      subtitle: Text(
                        DateFormat("h:mm | dd MMM yy")
                            .format(todo.updatedAt.toDate()),
                      ),
                      trailing: Checkbox(
                        value: todo.isDone,
                        onChanged: (value) {
                          Todo updateTodo = todo.copyWith(
                              isDone: !todo.isDone, updatedAt: Timestamp.now());
                          _databaseService.updateTodo(idTodo, updateTodo);
                        },
                      ),
                      onLongPress: () => _databaseService.deleteTodo(idTodo)),
                );
              });
        },
      ),
    );
  }
}
