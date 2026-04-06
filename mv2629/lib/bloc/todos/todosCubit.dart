import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mv2629/models/taskTodoModel.dart';
import 'package:mv2629/repo/implement/taskTodoImp.dart';
import 'package:mv2629/repo/taskTodoRepo.dart';
import 'package:mv2629/bloc/todos/todosState.dart';

class TaskTodoCubit extends Cubit<TodoTaskState> {
  TaskTodoCubit({TaskTodoRepo? repo})
    : _repo = repo ?? TaskTodoService(),
      super(TodoTaskInitial());

  final TaskTodoRepo _repo;

  final List<TaskTodoModel> _tasks = <TaskTodoModel>[];
  List<TaskTodoModel> get tasks => List<TaskTodoModel>.unmodifiable(_tasks);

  DateTime? _selectedDate;
  bool _newestFirst = true;
  int _page = 0;
  int _pageSize = 20;
  bool _hasNextPage = true;
  int _totalCount = 0;
  bool _isLoadingMore = false;
  Set<String> _taskDateKeys = <String>{};

  Future<void> loadInitial({
    DateTime? selectedDate,
    int pageSize = 20,
    bool newestFirst = true,
  }) async {
    _selectedDate = selectedDate;
    _pageSize = pageSize > 0 ? pageSize : 20;
    _newestFirst = newestFirst;

    emit(TodoTaskLoading());
    await _loadPage(reset: true);
  }

  Future<void> refresh() async {
    await _loadPage(reset: true);
  }

  Future<void> setDateFilter(DateTime? date) async {
    _selectedDate = date;
    await _loadPage(reset: true);
  }

  Future<List<TaskTodoModel>> getTasksForDate(DateTime date) async {
    final pageData = await _repo.getTasksByDatePaged(
      date,
      page: 0,
      pageSize: 1000,
      newestFirst: _newestFirst,
    );
    return pageData.items;
  }

  Future<void> setSortOrder({required bool newestFirst}) async {
    if (_newestFirst == newestFirst) {
      return;
    }

    _newestFirst = newestFirst;
    await _loadPage(reset: true);
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasNextPage) {
      return;
    }

    _isLoadingMore = true;
    final current = state;
    if (current is TodoTaskLoaded) {
      emit(current.copyWith(isLoadingMore: true));
    }

    await _loadPage(reset: false);
    _isLoadingMore = false;
  }

  Future<void> addTask(TaskTodoModel task, {bool reload = true}) async {
    try {
      await _repo.addTask(task);
      if (reload) {
        await _loadPage(reset: true);
      }
    } catch (e) {
      emit(TodoTaskError(message: 'Failed to add task: $e'));
    }
  }

  Future<void> updateTask(TaskTodoModel task, {bool reload = true}) async {
    try {
      await _repo.updateTask(task);
      if (reload) {
        await _loadPage(reset: true);
      }
    } catch (e) {
      emit(TodoTaskError(message: 'Failed to update task: $e'));
    }
  }

  Future<void> toggleTaskCompletion(TaskTodoModel task) async {
    final updated = task.copyWith(isCompleted: !task.isCompleted);
    await updateTask(updated);
  }

  Future<void> deleteTask(String id, {bool reload = true}) async {
    try {
      await _repo.deleteTask(id);
      if (reload) {
        await _loadPage(reset: true);
      }
    } catch (e) {
      emit(TodoTaskError(message: 'Failed to delete task: $e'));
    }
  }

  Future<void> _loadPage({required bool reset}) async {
    try {
      if (reset) {
        _page = 0;
        _tasks.clear();
      }

      final pageData = _selectedDate == null
          ? await _repo.getTasksPaged(
              page: _page,
              pageSize: _pageSize,
              newestFirst: _newestFirst,
            )
          : await _repo.getTasksByDatePaged(
              _selectedDate!,
              page: _page,
              pageSize: _pageSize,
              newestFirst: _newestFirst,
            );

      if (reset) {
        _tasks
          ..clear()
          ..addAll(pageData.items);
      } else {
        _tasks.addAll(pageData.items);
      }

      _hasNextPage = pageData.hasNextPage;
      _totalCount = pageData.totalCount;
      _page = reset ? 1 : _page + 1;

      final completionRate = await _repo.getCompletionRate();
      _taskDateKeys = await _repo.getTaskDateKeys();

      emit(
        TodoTaskLoaded(
          tasks: List<TaskTodoModel>.from(_tasks),
          taskDateKeys: Set<String>.from(_taskDateKeys),
          completionRate: completionRate,
          page: _page,
          pageSize: _pageSize,
          totalCount: _totalCount,
          hasNextPage: _hasNextPage,
          isLoadingMore: false,
          selectedDate: _selectedDate,
          newestFirst: _newestFirst,
        ),
      );
    } catch (e) {
      emit(TodoTaskError(message: 'Failed to load tasks: $e'));
    }
  }
}
