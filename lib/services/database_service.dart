import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_app_firebase/models/todo.dart';

// ignore: constant_identifier_names
const String TODO_COLLECTION_REF = "todos";

class DatabaseService {
  final _firestore = FirebaseFirestore.instance;
  late final CollectionReference _todosRef;
  DatabaseService() {
    _todosRef = _firestore.collection(TODO_COLLECTION_REF).withConverter<Todo>(
        fromFirestore: (snapshots, _) => Todo.fromJson(
              snapshots.data()!,
            ),
        toFirestore: (todo, _) => todo.toJson());
  }

  Stream<QuerySnapshot> getTodos() {
    return _todosRef.snapshots();
  }

  void addTodo(Todo todo) {
    _todosRef.add(todo);
  }

  void updateTodo(String id, Todo todo) {
    _todosRef.doc(id).update(todo.toJson());
  }

  void deleteTodo(String id) {
    _todosRef.doc(id).delete();
  }
}
