import 'package:hive/hive.dart';
import 'package:mv2629/models/taskTodoModel.dart';
import 'package:mv2629/repo/taskTodoRepo.dart';
import 'dart:collection';

class TaskTodoService implements TaskTodoRepo {
  static const String _taskBoxName = 'taskTodos';
  static const String _dateIndexBoxName = 'taskTodoDateIndex';
  static const String _dateLookupBoxName = 'taskTodoDateLookup';
  static const String _metaBoxName = 'taskTodoMeta';

  static const String _allIdsMetaKey = 'all_ids';
  static const String _totalCountMetaKey = 'total_count';
  static const String _completedCountMetaKey = 'completed_count';

  static const int _maxTaskCacheSize = 2000;
  static const int _maxPageCacheSize = 256;

  final LinkedHashMap<String, TaskTodoModel> _taskCache =
      LinkedHashMap<String, TaskTodoModel>();
  final LinkedHashMap<String, List<TaskTodoModel>> _pageCache =
      LinkedHashMap<String, List<TaskTodoModel>>();
  bool _isBootstrapped = false;
  Future<void>? _bootstrapFuture;

  Box<TaskTodoModel> get _taskBox => Hive.box<TaskTodoModel>(_taskBoxName);
  Box<String> get _dateLookupBox => Hive.box<String>(_dateLookupBoxName);
  Box<dynamic> get _dateIndexBox => Hive.box<dynamic>(_dateIndexBoxName);
  Box<dynamic> get _metaBox => Hive.box<dynamic>(_metaBoxName);

  @override
  Future<void> addTask(TaskTodoModel task) async {
    try {
      await _ensureBootstrapped();
      final existingTask = _taskBox.get(task.id);
      if (existingTask != null) {
        await updateTask(task);
        return;
      }

      await _taskBox.put(task.id, task);
      final dateKey = _toDateKey(task.dateTime);

      await _dateLookupBox.put(task.id, dateKey);
      await _appendIdToDateIndex(dateKey, task.id);
      await _appendGlobalId(task.id);
      await _increaseCountersFor(task);

      _cacheTask(task);
      _clearPageCache();
    } catch (e) {
      throw Exception('Failed to add task: $e');
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      await _ensureBootstrapped();
      final task = _taskBox.get(id);
      if (task != null) {
        final dateKey = _dateLookupBox.get(id) ?? _toDateKey(task.dateTime);

        await _taskBox.delete(id);
        await _dateLookupBox.delete(id);
        await _removeIdFromDateIndex(dateKey, id);
        await _removeGlobalId(id);
        await _decreaseCountersFor(task);

        _taskCache.remove(id);
        _clearPageCache();
      }
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  @override
  Future<double> getCompletionRate() async {
    try {
      await _ensureBootstrapped();
      final total = _readMetaInt(_totalCountMetaKey);
      if (total == 0) {
        return 0.0;
      }

      final completed = _readMetaInt(_completedCountMetaKey);
      return completed / total;
    } catch (e) {
      throw Exception('Failed to get completion rate: $e');
    }
  }

  @override
  Future<List<TaskTodoModel>> getTasks() async {
    try {
      await _ensureBootstrapped();
      final ids = _readMetaStringList(_allIdsMetaKey);
      final tasks = <TaskTodoModel>[];
      for (final id in ids) {
        final task = _getTask(id);
        if (task != null) {
          tasks.add(task);
        }
      }
      return tasks;
    } catch (e) {
      throw Exception('Failed to get tasks: $e');
    }
  }

  @override
  Future<Set<String>> getTaskDateKeys() async {
    try {
      await _ensureBootstrapped();
      return _dateIndexBox.keys.whereType<String>().toSet();
    } catch (e) {
      throw Exception('Failed to get task date keys: $e');
    }
  }

  @override
  Future<TaskTodoPage> getTasksPaged({
    int page = 0,
    int pageSize = 50,
    bool newestFirst = true,
  }) async {
    try {
      await _ensureBootstrapped();
      final ids = _readMetaStringList(_allIdsMetaKey);
      final items = _readPageByOrder(
        ids: ids,
        page: page,
        pageSize: pageSize,
        newestFirst: newestFirst,
        cacheKey: 'all|$page|$pageSize|$newestFirst',
      );

      return TaskTodoPage(
        items: items,
        totalCount: ids.length,
        page: page,
        pageSize: pageSize,
      );
    } catch (e) {
      throw Exception('Failed to get paged tasks: $e');
    }
  }

  @override
  Future<TaskTodoPage> getTasksByDatePaged(
    DateTime date, {
    int page = 0,
    int pageSize = 50,
    bool newestFirst = true,
  }) async {
    try {
      await _ensureBootstrapped();
      final dateKey = _toDateKey(date);
      final ids = _readDateIndex(dateKey);
      final items = _readPageByOrder(
        ids: ids,
        page: page,
        pageSize: pageSize,
        newestFirst: newestFirst,
        cacheKey: 'date:$dateKey|$page|$pageSize|$newestFirst',
      );

      return TaskTodoPage(
        items: items,
        totalCount: ids.length,
        page: page,
        pageSize: pageSize,
      );
    } catch (e) {
      throw Exception('Failed to get tasks by date: $e');
    }
  }

  @override
  Future<void> updateTask(TaskTodoModel task) async {
    try {
      await _ensureBootstrapped();
      final oldTask = _taskBox.get(task.id);
      if (oldTask == null) {
        await addTask(task);
        return;
      }

      final oldDateKey =
          _dateLookupBox.get(task.id) ?? _toDateKey(oldTask.dateTime);
      final newDateKey = _toDateKey(task.dateTime);

      await _taskBox.put(task.id, task);
      if (oldDateKey != newDateKey) {
        await _removeIdFromDateIndex(oldDateKey, task.id);
        await _appendIdToDateIndex(newDateKey, task.id);
        await _dateLookupBox.put(task.id, newDateKey);
      }

      await _syncCompletionCounters(oldTask, task);

      _cacheTask(task);
      _clearPageCache();
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  Future<void> _ensureBootstrapped() async {
    if (_isBootstrapped) {
      return;
    }

    _bootstrapFuture ??= _bootstrapIndexes();
    await _bootstrapFuture;
    _isBootstrapped = true;
  }

  Future<void> _bootstrapIndexes() async {
    final ids = _readMetaStringList(_allIdsMetaKey);
    final total = _readMetaInt(_totalCountMetaKey);
    final needsBootstrap =
        ids.length != total || (ids.isEmpty && _taskBox.isNotEmpty);

    if (!needsBootstrap) {
      return;
    }

    await _dateIndexBox.clear();
    await _dateLookupBox.clear();

    final seenIds = <String>{};
    final rebuiltIds = <String>[];
    var rebuiltCompleted = 0;

    final originalKeys = _taskBox.keys.toList(growable: false);
    for (final key in originalKeys) {
      final task = _taskBox.get(key);
      if (task == null) {
        continue;
      }

      if (key != task.id) {
        await _taskBox.put(task.id, task);
        await _taskBox.delete(key);
      }

      if (!seenIds.add(task.id)) {
        continue;
      }

      rebuiltIds.add(task.id);
      if (task.isCompleted) {
        rebuiltCompleted++;
      }

      final dateKey = _toDateKey(task.dateTime);
      await _dateLookupBox.put(task.id, dateKey);

      final dateIds = _readDateIndex(dateKey);
      dateIds.add(task.id);
      await _dateIndexBox.put(dateKey, dateIds);
      _cacheTask(task);
    }

    await _metaBox.put(_allIdsMetaKey, rebuiltIds);
    await _metaBox.put(_totalCountMetaKey, rebuiltIds.length);
    await _metaBox.put(_completedCountMetaKey, rebuiltCompleted);
    _clearPageCache();
  }

  List<TaskTodoModel> _readPageByOrder({
    required List<String> ids,
    required int page,
    required int pageSize,
    required bool newestFirst,
    required String cacheKey,
  }) {
    final normalizedPage = page < 0 ? 0 : page;
    final normalizedPageSize = pageSize <= 0 ? 20 : pageSize;
    final normalizedCacheKey = '$cacheKey|$normalizedPage|$normalizedPageSize';

    final cached = _readPageCache(normalizedCacheKey);
    if (cached != null) {
      return cached;
    }

    final offset = normalizedPage * normalizedPageSize;
    if (offset >= ids.length) {
      return const <TaskTodoModel>[];
    }

    final items = <TaskTodoModel>[];
    if (newestFirst) {
      final startFromTail = ids.length - 1 - offset;
      final endFromTail = (startFromTail - normalizedPageSize + 1).clamp(
        0,
        ids.length,
      );
      for (var i = startFromTail; i >= endFromTail; i--) {
        final task = _getTask(ids[i]);
        if (task != null) {
          items.add(task);
        }
      }
    } else {
      final end = (offset + normalizedPageSize).clamp(0, ids.length);
      for (var i = offset; i < end; i++) {
        final task = _getTask(ids[i]);
        if (task != null) {
          items.add(task);
        }
      }
    }

    _writePageCache(normalizedCacheKey, items);
    return items;
  }

  TaskTodoModel? _getTask(String id) {
    final cached = _taskCache[id];
    if (cached != null) {
      _taskCache.remove(id);
      _taskCache[id] = cached;
      return cached;
    }

    final task = _taskBox.get(id);
    if (task != null) {
      _cacheTask(task);
    }
    return task;
  }

  void _cacheTask(TaskTodoModel task) {
    _taskCache.remove(task.id);
    _taskCache[task.id] = task;
    if (_taskCache.length > _maxTaskCacheSize) {
      _taskCache.remove(_taskCache.keys.first);
    }
  }

  List<TaskTodoModel>? _readPageCache(String cacheKey) {
    final cached = _pageCache[cacheKey];
    if (cached == null) {
      return null;
    }

    _pageCache.remove(cacheKey);
    _pageCache[cacheKey] = cached;
    return List<TaskTodoModel>.from(cached);
  }

  void _writePageCache(String cacheKey, List<TaskTodoModel> pageItems) {
    _pageCache.remove(cacheKey);
    _pageCache[cacheKey] = List<TaskTodoModel>.from(pageItems);
    if (_pageCache.length > _maxPageCacheSize) {
      _pageCache.remove(_pageCache.keys.first);
    }
  }

  void _clearPageCache() {
    _pageCache.clear();
  }

  Future<void> _appendIdToDateIndex(String dateKey, String taskId) async {
    final ids = _readDateIndex(dateKey);
    if (!ids.contains(taskId)) {
      ids.add(taskId);
      await _dateIndexBox.put(dateKey, ids);
    }
  }

  Future<void> _removeIdFromDateIndex(String dateKey, String taskId) async {
    final ids = _readDateIndex(dateKey);
    final removed = ids.remove(taskId);
    if (!removed) {
      return;
    }

    if (ids.isEmpty) {
      await _dateIndexBox.delete(dateKey);
    } else {
      await _dateIndexBox.put(dateKey, ids);
    }
  }

  List<String> _readDateIndex(String dateKey) {
    final raw = _dateIndexBox.get(dateKey);
    return _toStringList(raw);
  }

  Future<void> _appendGlobalId(String taskId) async {
    final ids = _readMetaStringList(_allIdsMetaKey);
    if (!ids.contains(taskId)) {
      ids.add(taskId);
      await _metaBox.put(_allIdsMetaKey, ids);
    }
  }

  Future<void> _removeGlobalId(String taskId) async {
    final ids = _readMetaStringList(_allIdsMetaKey);
    if (ids.remove(taskId)) {
      await _metaBox.put(_allIdsMetaKey, ids);
    }
  }

  int _readMetaInt(String key) {
    final value = _metaBox.get(key);
    if (value is int) {
      return value;
    }
    return 0;
  }

  List<String> _readMetaStringList(String key) {
    final raw = _metaBox.get(key);
    return _toStringList(raw);
  }

  List<String> _toStringList(dynamic raw) {
    if (raw is List) {
      return raw.whereType<String>().toList(growable: true);
    }
    return <String>[];
  }

  Future<void> _increaseCountersFor(TaskTodoModel task) async {
    final total = _readMetaInt(_totalCountMetaKey);
    await _metaBox.put(_totalCountMetaKey, total + 1);

    if (task.isCompleted) {
      final completed = _readMetaInt(_completedCountMetaKey);
      await _metaBox.put(_completedCountMetaKey, completed + 1);
    }
  }

  Future<void> _decreaseCountersFor(TaskTodoModel task) async {
    final total = _readMetaInt(_totalCountMetaKey);
    final nextTotal = total <= 0 ? 0 : total - 1;
    await _metaBox.put(_totalCountMetaKey, nextTotal);

    if (task.isCompleted) {
      final completed = _readMetaInt(_completedCountMetaKey);
      final nextCompleted = completed <= 0 ? 0 : completed - 1;
      await _metaBox.put(_completedCountMetaKey, nextCompleted);
    }
  }

  Future<void> _syncCompletionCounters(
    TaskTodoModel oldTask,
    TaskTodoModel newTask,
  ) async {
    if (oldTask.isCompleted == newTask.isCompleted) {
      return;
    }

    final completed = _readMetaInt(_completedCountMetaKey);
    if (newTask.isCompleted) {
      await _metaBox.put(_completedCountMetaKey, completed + 1);
    } else {
      await _metaBox.put(
        _completedCountMetaKey,
        completed <= 0 ? 0 : completed - 1,
      );
    }
  }

  String _toDateKey(DateTime? dateTime) {
    if (dateTime == null) {
      return '00000000';
    }

    final local = dateTime.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    return '$y$m$d';
  }
}
