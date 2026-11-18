import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:taskflow/app/taskflow_app.dart';
import 'package:taskflow/features/tasks/data/local_task_repository.dart';
import 'package:taskflow/features/tasks/presentation/tasks_view_model.dart';
import 'package:taskflow/features/tasks/presentation/task_detail_screen.dart';
import 'package:taskflow/features/tasks/domain/task.dart';

void main() {
  late List<Task> demoTasks;
  setUp(() async {
    demoTasks = await LocalTaskRepository().getTasks();
  });
  test('Las cinco tareas conservan ids, estados y usuario', () async {
    expect(demoTasks.length, 5);
    expect(demoTasks.map((task) => task.id).toSet().length, 5);
    expect(demoTasks.every((task) => task.userId == 1), isTrue);
    expect(demoTasks.where((task) => task.isCompleted).map((task) => task.id), [
      3,
    ]);
    final task = Task.fromJson({
      'id': 7,
      'title': 'Preparar exposición',
      'description': 'Organizar diapositivas y practicar',
      'priority': 'Alta',
      'isCompleted': false,
      'userId': 1,
    });
    expect(task.id, 7);
    expect(task.title, 'Preparar exposición');
    expect(task.priority, 'Alta');
    expect(task.isCompleted, isFalse);
    expect(task.userId, 1);
  });

  test(
    'El cambio es inmutable, se notifica y se pierde al reiniciar',
    () async {
      final repository = LocalTaskRepository();
      final vm = TasksViewModel(repository);
      await vm.loadTasks();
      final original = vm.tasks.first;
      var notifications = 0;
      vm.addListener(() => notifications++);
      vm.toggleCompleted(original.id);
      final updated = vm.findTask(original.id)!;
      expect(updated.isCompleted, !original.isCompleted);
      expect(
        (await repository.getTasks()).first.isCompleted,
        updated.isCompleted,
      );
      expect(original.isCompleted, false);
      expect(updated.id, original.id);
      expect(updated.title, original.title);
      expect(updated.description, original.description);
      expect(updated.priority, original.priority);
      expect(updated.userId, original.userId);
      expect(notifications, 1);
      vm.toggleCompleted(999);
      expect(notifications, 1);
      expect(vm.findTask(null), isNull);
      expect(() => vm.tasks.clear(), throwsUnsupportedError);
      final restarted = TasksViewModel(LocalTaskRepository());
      await restarted.loadTasks();
      expect(restarted.tasks.first.isCompleted, original.isCompleted);
      restarted.dispose();
      vm.dispose();
    },
  );
  testWidgets('Cada tarjeta abre su detalle y permite regresar', (
    tester,
  ) async {
    final viewModel = TasksViewModel(LocalTaskRepository());
    await viewModel.loadTasks();
    appRouter.go('/');
    await tester.pumpWidget(
      ChangeNotifierProvider<TasksViewModel>(
        create: (_) => viewModel,
        child: const TaskFlowApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Mis tareas'), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
    for (final task in demoTasks) {
      await tester.scrollUntilVisible(find.text(task.title), 150);
      await tester.tap(find.text(task.title));
      await tester.pumpAndSettle();
      expect(find.text('Detalle de tarea'), findsOneWidget);
      expect(find.text(task.description), findsOneWidget);
      expect(
        tester.widget<TaskDetailScreen>(find.byType(TaskDetailScreen)).taskId,
        task.id,
      );
      expect(find.text('Usuario: 1'), findsOneWidget);
      expect(
        find.text(
          task.isCompleted ? 'Estado: completada' : 'Estado: pendiente',
        ),
        findsOneWidget,
      );
      await tester.tap(
        find.text(
          task.isCompleted ? 'Marcar como pendiente' : 'Marcar como completada',
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text(
          task.isCompleted ? 'Estado: pendiente' : 'Estado: completada',
        ),
        findsOneWidget,
      );
      await tester.pageBack();
      await tester.pumpAndSettle();
      final tile = tester.widget<ListTile>(
        find.ancestor(
          of: find.text(task.title),
          matching: find.byType(ListTile),
        ),
      );
      expect(
        (tile.leading as Icon).icon,
        task.isCompleted ? Icons.radio_button_unchecked : Icons.check_circle,
      );
      await tester.tap(find.text(task.title));
      await tester.pumpAndSettle();
      expect(
        find.text(
          task.isCompleted ? 'Estado: pendiente' : 'Estado: completada',
        ),
        findsOneWidget,
      );
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(appRouter.routeInformationProvider.value.uri.path, '/');
    }
    for (final id in ['999', 'invalido']) {
      appRouter.go('/task/$id');
      await tester.pumpAndSettle();
      expect(find.text('No se encontró esta tarea.'), findsOneWidget);
    }
    appRouter.go('/');
    await tester.pumpAndSettle();
  });
}
