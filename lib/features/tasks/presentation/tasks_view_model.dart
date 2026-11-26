import 'package:flutter/foundation.dart';

import '../data/task_repository.dart';
import '../domain/task.dart';

class TasksViewModel extends ChangeNotifier {
  TasksViewModel(this._repository);

  final TaskRepository _repository;
  List<Task> _tasks = [];
  bool isLoading = false;
  String? errorMessage;

  List<Task> get tasks => List.unmodifiable(_tasks);

  bool get isEmpty => !isLoading && errorMessage == null && _tasks.isEmpty;

  Future<void> loadTasks() async {
    if (isLoading) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _tasks = await _repository.getTasks();
    } catch (error) {
      errorMessage = 'No se pudieron cargar las tareas.';
      _tasks = [];
      debugPrint('Error al cargar tareas: $error');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Task? findTask(int? id) {
    if (id == null) return null;
    for (final task in _tasks) {
      if (task.id == id) return task;
    }
    return null;
  }

  void toggleCompleted(int id) {
    final current = findTask(id);
    if (current == null) return;

    final updated = current.copyWith(isCompleted: !current.isCompleted);
    _repository.save(updated);
    _tasks = [
      for (final task in _tasks)
        if (task.id == id) updated else task,
    ];
    notifyListeners();
  }

  Future<bool> createTask(Task task) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final created = await _repository.createTask(task);
      _tasks = [..._tasks, created];
      isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      errorMessage = 'No se pudo crear la tarea.';
      isLoading = false;
      notifyListeners();
      debugPrint('Error al crear tarea: $error');
      return false;
    }
  }

  Future<bool> updateTask(Task task) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final updated = await _repository.updateTask(task);
      _tasks = [
        for (final t in _tasks)
          if (t.id == task.id) updated else t,
      ];
      isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      errorMessage = 'No se pudo actualizar la tarea.';
      isLoading = false;
      notifyListeners();
      debugPrint('Error al actualizar tarea: $error');
      return false;
    }
  }

  Future<bool> deleteTask(int id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteTask(id);
      _tasks = _tasks.where((t) => t.id != id).toList();
      isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      errorMessage = 'No se pudo eliminar la tarea.';
      isLoading = false;
      notifyListeners();
      debugPrint('Error al eliminar tarea: $error');
      return false;
    }
  }
}
