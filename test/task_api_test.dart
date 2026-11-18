import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:taskflow/features/tasks/data/remote_task_repository.dart';
import 'package:taskflow/features/tasks/data/task_api_service.dart';
import 'package:taskflow/features/tasks/domain/task.dart';
import 'package:taskflow/features/tasks/presentation/task_list_screen.dart';
import 'package:taskflow/features/tasks/presentation/tasks_view_model.dart';

class ControlledApiService extends TaskApiService {
  final response = Completer<List<Task>>();
  int calls = 0;
  @override
  Future<List<Task>> getTasks() {
    calls++;
    return response.future.then((tasks) => List<Task>.of(tasks));
  }
}

void main() {
  final remoteTask = Task.fromJson({
    'id': 1,
    'userId': 1,
    'title': 'delectus aut autem',
    'completed': false,
  });

  test('El JSON remoto usa completed y valores de ejemplo', () {
    expect(remoteTask.isCompleted, isFalse);
    expect(remoteTask.description, 'Sin descripción (API)');
    expect(remoteTask.priority, 'Sin prioridad (API)');
    final local = Task.fromJson({
      'id': 7,
      'userId': 1,
      'title': 'Local',
      'description': 'Propia',
      'priority': 'Alta',
      'isCompleted': false,
      'completed': true,
    });
    expect(local.isCompleted, isFalse);
    expect(local.description, 'Propia');
    expect(local.priority, 'Alta');
  });

  test(
    'Alternar estado no consulta la API y recargar recupera el remoto',
    () async {
      final service = ControlledApiService();
      final repository = RemoteTaskRepository(service);
      final vm = TasksViewModel(repository);
      final loading = vm.loadTasks();
      expect(vm.isLoading, isTrue);
      service.response.complete([remoteTask]);
      await loading;
      vm.toggleCompleted(1);
      expect(vm.findTask(1)!.isCompleted, isTrue);
      expect(service.calls, 1);
      await vm.loadTasks();
      expect(vm.findTask(1)!.isCompleted, isFalse);
      expect(service.calls, 2);
      vm.dispose();
    },
  );

  testWidgets('La lista comunica carga y fallo de conexión', (tester) async {
    final service = ControlledApiService();
    final vm = TasksViewModel(RemoteTaskRepository(service));
    final loading = vm.loadTasks();
    await tester.pumpWidget(
      ChangeNotifierProvider<TasksViewModel>(
        create: (_) => vm,
        child: const MaterialApp(home: TaskListScreen()),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    service.response.completeError(StateError('Fallo de conexión controlado'));
    await loading;
    await tester.pumpAndSettle();
    expect(find.text('No se pudieron cargar las tareas.'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
