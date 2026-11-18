# taskflow

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Alcance de TaskFlow

Problema: necesito organizar actividades académicas y saber cuáles faltan.
Usuario objetivo: estudiante que planifica entregas semanales.

### Historias de usuario y criterios de aceptación
1. Como estudiante, quiero listar mis tareas para ver qué debo hacer.
   Criterio: la lista muestra título, prioridad y estado de cada tarea.
2. Como estudiante, quiero abrir una tarea para leer su descripción.
   Criterio: al tocar una tarjeta aparece el detalle de la tarea elegida.
3. Como estudiante, quiero crear una tarea para registrar un pendiente.
   Criterio: el formulario guarda una tarea válida y la lista la muestra.
4. Como estudiante, quiero editar una tarea para corregir sus datos.
   Criterio: los cambios guardados aparecen en lista y detalle.
5. Como estudiante, quiero eliminar una tarea terminada para limpiar la lista.
   Criterio: después de confirmar, la tarea desaparece de la lista.

### Modelo de datos
Task: id (entero único), title (texto), description (texto),
priority (Alta, Media o Baja), isCompleted (verdadero/falso),
userId (entero que identifica al usuario de prueba).

### Pantallas previstas
Lista: tarjetas de tareas y acción para crear.
Detalle: información completa y futuras acciones de editar o eliminar.
Formulario: campos de título, descripción y prioridad.

### Requisitos no funcionales
La navegación debe tener textos comprensibles.
Un id inexistente debe mostrar un mensaje en vez de cerrar la app.

### Contrato de API que necesitaremos
GET /tasks        listar tareas
GET /tasks/:id    consultar detalle
POST /tasks       crear tarea
PATCH /tasks/:id  actualizar tarea
DELETE /tasks/:id eliminar tarea

La API concreta se elegirá después. Estas rutas son requisitos, no
direcciones de un servidor ya conectado.

### Alcance de esta entrega
Sesión 5: cinco tareas locales personalizadas, lista `/`, detalle `/task/:id`,
conversión JSON y navegación de regreso. Se conserva el panel de objetivo diario
anterior. Crear, editar y eliminar son requisitos futuros; no se implementan
API real, autenticación ni arquitectura MVVM en esta sesión.

Las tareas de Johantony son planificar la semana, revisar la legibilidad,
completar el panel diario (completada), validar las tarjetas y preparar la entrega.
Sus identificadores son 1–5 y pertenecen al usuario de prueba 1.

### Bocetos de las tres pantallas
```text
Lista actual            Detalle actual          Formulario futuro
Mis tareas              Título                  Nueva / Editar tarea
○ Título · prioridad >  Descripción             [Título]
✓ Título · prioridad >  Prioridad y estado      [Descripción]
                        ID y usuario            [Prioridad]
[Crear: futuro]          [Volver al listado]     [Guardar] [Cancelar]
```

### Ejemplo del contrato JSON
```json
{
  "id": 7,
  "title": "Preparar exposición",
  "description": "Organizar diapositivas y practicar",
  "priority": "Alta",
  "isCompleted": false,
  "userId": 1
}
```
`Task.fromJson` convierte un mapa con estos seis campos y tipos en una tarea.
El contrato futuro usará objetos así para detalle y una lista de objetos para
GET /tasks; POST recibirá los datos editables y devolverá la tarea con id;
PATCH recibirá los campos cambiados; DELETE confirmará la eliminación.
No existe un servidor conectado todavía.

### Calidad y ejecución
Usabilidad: estados con iconos y texto en detalle; navegación comprensible.
Mantenibilidad: una única clase Task en lib/task.dart, separada de los widgets.
Rendimiento: ListView.builder construye los elementos según se necesitan.
Robustez: identificadores inválidos o inexistentes muestran un mensaje.

```sh
flutter pub get
flutter run
dart format lib
flutter analyze
flutter test
```
La prueba verifica las cinco rutas de detalle, el retorno, ids únicos, estados,
usuario de prueba, conversión JSON y rutas inválidas.

## API de tareas — sesión 7

TaskFlow consulta JSONPlaceholder, una API REST pública con datos de prueba:
<https://jsonplaceholder.typicode.com/todos?userId=1>.
El método es GET y el filtro activo `userId=1` limita las tareas al usuario 1.
La respuesta HTTP 200 contiene una lista de objetos con `userId`, `id`, `title`
y `completed`; este último se convierte en `Task.isCompleted`.

```json
{
  "userId": 1,
  "id": 1,
  "title": "delectus aut autem",
  "completed": false
}
```

La API no proporciona descripción ni prioridad. El modelo añade los valores
explícitos de ejemplo `Sin descripción (API)` y `Sin prioridad (API)`.
`fromJson` también conserva la compatibilidad con los seis campos locales:
si existe `isCompleted`, se usa antes que `completed`.

`TaskApiService` conoce la URL HTTPS, el filtro, Dio y los tiempos de espera;
Dio decodifica JSON y `Task.fromJson` convierte cada mapa a un modelo tipado.
`RemoteTaskRepository` obtiene las tareas del Service y conserva una copia en
memoria. `TasksViewModel.loadTasks` espera el Future, gestiona la señal básica de
carga o error y llama a `notifyListeners`; Provider reconstruye lista y detalle.
Las vistas no conocen la URL ni realizan peticiones HTTP.

Marcar una tarea modifica únicamente la copia en memoria, sin POST ni PATCH.
`toggleCompleted` guarda y actualiza el estado visible sin repetir GET.
Al reiniciar o volver a cargar desde la API se recupera el estado remoto.
Las cinco tareas personalizadas siguen intactas en `LocalTaskRepository`, cuyo
`getTasks` ahora devuelve `Future<List<Task>>`. La fuente activa al finalizar es
`RemoteTaskRepository(TaskApiService())`; no hay persistencia ni CRUD remoto.

El usuario elegido para esta entrega es 1. Se comprobó temporalmente userId=2 con HTTP 200 y 20 tareas
(primera tarea id 21); se restauró userId=1 antes de publicar.
La configuración de la sesión 7 sustituye la fuente local activa descrita en
las sesiones anteriores. Para ejecutar y comprobar:

```sh
flutter pub get
flutter run
dart format lib
flutter analyze
flutter test
flutter build web --no-tree-shake-icons --no-wasm-dry-run
```
