import '../domain/task.dart';
import 'task_repository.dart';

class LocalTaskRepository implements TaskRepository {
  final List<Task> _tasks = [
    const Task(
      id: 1,
      title: 'Planificar las tareas de la semana',
      description: 'Ordenar en TaskFlow las entregas de Aplicaciones Móviles',
      priority: 'Alta',
      isCompleted: false,
      userId: 1,
    ),
    const Task(
      id: 2,
      title: 'Revisar la legibilidad del listado',
      description: 'Comprobar títulos y prioridades en una pantalla pequeña',
      priority: 'Media',
      isCompleted: false,
      userId: 1,
    ),
    const Task(
      id: 3,
      title: 'Completar el panel de objetivo diario',
      description:
          'Agregar y completar pendientes sin superar la meta de cinco',
      priority: 'Baja',
      isCompleted: true,
      userId: 1,
    ),
    const Task(
      id: 4,
      title: 'Validar las tarjetas de TaskFlow',
      description:
          'Comprobar los estados y el desplazamiento de las cinco tareas',
      priority: 'Alta',
      isCompleted: false,
      userId: 1,
    ),
    const Task(
      id: 5,
      title: 'Preparar la entrega del listado local',
      description: 'Guardar capturas y publicar el avance de la sesión tres',
      priority: 'Media',
      isCompleted: false,
      userId: 1,
    ),
  ];

  @override
  Future<List<Task>> getTasks() async => List.unmodifiable(_tasks);

  @override
  void save(Task task) {
    final index = _tasks.indexWhere((item) => item.id == task.id);
    if (index == -1) return;
    _tasks[index] = task;
  }
}
