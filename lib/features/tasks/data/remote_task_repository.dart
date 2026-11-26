import '../domain/task.dart';
import 'task_api_service.dart';
import 'task_repository.dart';

class RemoteTaskRepository implements TaskRepository {
  RemoteTaskRepository(this._apiService);

  final TaskApiService _apiService;
  List<Task> _tasks = [];

  @override
  Future<List<Task>> getTasks() async {
    _tasks = await _apiService.getTasks();
    return List.unmodifiable(_tasks);
  }

  @override
  void save(Task task) {
    final index = _tasks.indexWhere((item) => item.id == task.id);
    if (index == -1) return;
    _tasks[index] = task;
  }

  @override
  Future<Task> createTask(Task task) async {
    final created = await _apiService.createTask(task);
    final merged = Task(
      id: created.id,
      title: created.title,
      description: task.description,
      priority: task.priority,
      isCompleted: created.isCompleted,
      userId: created.userId,
    );
    _tasks.add(merged);
    return merged;
  }

  @override
  Future<Task> updateTask(Task task) async {
    final updated = await _apiService.updateTask(task);
    final index = _tasks.indexWhere((item) => item.id == task.id);
    if (index != -1) {
      _tasks[index] = Task(
        id: updated.id,
        title: updated.title,
        description: _tasks[index].description,
        priority: _tasks[index].priority,
        isCompleted: updated.isCompleted,
        userId: updated.userId,
      );
    }
    return _tasks[index];
  }

  @override
  Future<void> deleteTask(int id) async {
    await _apiService.deleteTask(id);
    _tasks.removeWhere((item) => item.id == id);
  }
}
