// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mv2629/bloc/todos/todosCubit.dart';
import 'package:mv2629/bloc/todos/todosState.dart';
import 'package:mv2629/models/taskTodoModel.dart';
import 'package:mv2629/widgets/date_header.dart';
import 'package:mv2629/widgets/custom_header.dart';
import 'package:mv2629/widgets/task_content_card.dart';
import 'package:mv2629/views/skeleton/todo_task_skeleton.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  @override
  void initState() {
    super.initState();
    // loadInitial is already called in the global provider in main.dart
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomHeader(
            title: 'To-Do List',
            rightIconAsset: 'assets/calendar.png',
            onRightIconTap: () => Navigator.pushNamed(context, '/calendar'),
          ),
          Expanded(child: const _TaskListWidget()),
        ],
      ),
    );
  }

}

class _TaskListWidget extends StatelessWidget {
  const _TaskListWidget();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskTodoCubit, TodoTaskState>(
      buildWhen: (previous, current) =>
          current is TodoTaskLoaded ||
          current is TodoTaskError ||
          (current is TodoTaskLoading && previous is! TodoTaskLoaded),
      builder: (context, state) {
        if (state is TodoTaskInitial || state is TodoTaskLoading) {
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: 3,
            itemBuilder: (context, _) {
              return const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: TodoTaskSkeleton(),
              );
            },
          );
        }

        if (state is TodoTaskError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<TaskTodoCubit>().refresh(),
                    child: const Text('Try again'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is TodoTaskLoaded) {
          if (state.tasks.isEmpty) {
            return const Center(child: Text('No tasks yet'));
          }

          final grouped = _groupTasksByDate(state.tasks);
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: grouped.length,
            itemBuilder: (context, index) {
              final item = grouped[index];
              if (item.isHeader) {
                return DateHeader(date: item.headerLabel!);
              }
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TaskContentCard(
                  taskName: item.task!.taskName,
                  content: item.task!.content,
                  time: item.task!.time,
                  isCompleted: item.task!.isCompleted,
                  isRejected: false,
                  onConfirm: () => context
                      .read<TaskTodoCubit>()
                      .toggleTaskCompletion(item.task!),
                  onReject: () => context.read<TaskTodoCubit>().deleteTask(
                    item.task!.id,
                  ),
                ),
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  List<_TodoListItem> _groupTasksByDate(List<TaskTodoModel> tasks) {
    final sortedTasks = List<TaskTodoModel>.from(tasks)
      ..sort((a, b) {
        if (a.dateTime == null && b.dateTime == null) return 0;
        if (a.dateTime == null) return 1;
        if (b.dateTime == null) return -1;
        return b.dateTime!.compareTo(a.dateTime!);
      });

    final dateFormat = DateFormat('EEEE, dd MMM yyyy');
    final map = <String, List<TaskTodoModel>>{};

    for (final task in sortedTasks) {
      final date = task.dateTime;
      final key = date == null ? 'No Date' : dateFormat.format(date);
      map.putIfAbsent(key, () => <TaskTodoModel>[]).add(task);
    }

    final items = <_TodoListItem>[];
    for (final entry in map.entries) {
      items.add(_TodoListItem.header(entry.key));
      for (final task in entry.value) {
        items.add(_TodoListItem.task(task));
      }
    }

    return items;
  }
}

class _TodoListItem {
  final String? headerLabel;
  final TaskTodoModel? task;

  const _TodoListItem._({this.headerLabel, this.task});

  factory _TodoListItem.header(String label) {
    return _TodoListItem._(headerLabel: label);
  }

  factory _TodoListItem.task(TaskTodoModel task) {
    return _TodoListItem._(task: task);
  }

  bool get isHeader => headerLabel != null;
}
