// ignore_for_file: file_names

import 'package:hive/hive.dart';
import 'package:mv2629/models/taskSportCard.dart';
import 'package:mv2629/repo/taskSportRepo.dart';

class TaskSportService implements TaskSportRepo {
  static const String _boxName = 'taskSportCards';

  bool _isBootstrapped = false;
  Future<void>? _bootstrapFuture;

  Box<TaskSportCardModel> get _box => Hive.box<TaskSportCardModel>(_boxName);

  @override
  Future<TaskSportCardModel?> createTaskSportCard(
    TaskSportCardModel task,
  ) async {
    try {
      await _ensureBootstrapped();
      await _box.put(task.id, task);
      return task;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> deleteTaskSportCard(String id) async {
    try {
      await _ensureBootstrapped();
      await _box.delete(id);
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  @override
  Future<List<TaskSportCardModel>> getAllTaskSportCards() async {
    try {
      await _ensureBootstrapped();
      return _box.values.toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> updateTaskSportCard(TaskSportCardModel task) async {
    try {
      await _ensureBootstrapped();
      await _box.put(task.id, task);
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  Future<void> _ensureBootstrapped() async {
    if (_isBootstrapped) {
      return;
    }

    _bootstrapFuture ??= _bootstrapLegacyKeys();
    await _bootstrapFuture;
    _isBootstrapped = true;
  }

  Future<void> _bootstrapLegacyKeys() async {
    final keys = _box.keys.toList(growable: false);
    final seenIds = <String>{};

    for (final key in keys) {
      final task = _box.get(key);
      if (task == null) {
        continue;
      }

      final shouldMove = key is! String || key != task.id;
      final duplicateId = !seenIds.add(task.id);

      if (shouldMove) {
        await _box.put(task.id, task);
        await _box.delete(key);
      }

      if (duplicateId && key is String && key == task.id) {
        await _box.delete(key);
      }
    }
  }
}
