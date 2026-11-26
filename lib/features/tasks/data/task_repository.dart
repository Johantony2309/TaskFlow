import '../domain/task.dart';

abstract class TaskRepository {
  Future<List<Task>> getTasks();
  void save(Task task);
  Future<Task> createTask(Task task);
  Future<Task> updateTask(Task task);
  Future<void> deleteTask(int id);
}
