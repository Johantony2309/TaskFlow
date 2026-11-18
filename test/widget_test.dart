import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/main.dart';
import 'package:taskflow/task.dart';

void main() {
  test('Las cinco tareas conservan ids, estados y usuario', () {
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

  testWidgets('Cada tarjeta abre su detalle y permite regresar', (
    tester,
  ) async {
    await tester.pumpWidget(const TaskFlowApp());
    await tester.pumpAndSettle();
    expect(find.text('Mis tareas'), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
    for (final task in demoTasks) {
      await tester.scrollUntilVisible(find.text(task.title), 150);
      await tester.tap(find.text(task.title));
      await tester.pumpAndSettle();
      expect(find.text('Detalle de tarea'), findsOneWidget);
      expect(find.text(task.description), findsOneWidget);
      expect(find.text('ID: ${task.id}'), findsOneWidget);
      expect(find.text('Usuario: 1'), findsOneWidget);
      expect(
        find.text(
          task.isCompleted ? 'Estado: completada' : 'Estado: pendiente',
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Volver al listado'));
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
