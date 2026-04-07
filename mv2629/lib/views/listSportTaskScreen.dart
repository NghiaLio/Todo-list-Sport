// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mv2629/bloc/sports/sportsCubit.dart';
import 'package:mv2629/bloc/sports/sportsState.dart';
import 'package:mv2629/data/mock_data.dart';
import 'package:mv2629/models/taskSportCard.dart';
import 'package:mv2629/utils/TimeConvert.dart';
import 'package:mv2629/utils/id_generator.dart';
import 'package:mv2629/widgets/DialogCreatedTask.dart';
import 'package:mv2629/widgets/button_arrow.dart';
import 'package:mv2629/widgets/date_header.dart';
import 'package:mv2629/widgets/task_action_buttons.dart';
import 'package:mv2629/widgets/confirm_reject_dialog.dart';
import 'package:mv2629/widgets/showSnackBar.dart';
import 'package:mv2629/views/skeleton/list_sport_task_skeleton.dart';
import 'package:mv2629/constants/theme.dart';
import 'package:mv2629/widgets/custom_floating_action_button.dart';

class ListSportTaskScreen extends StatefulWidget {
  const ListSportTaskScreen({super.key});

  @override
  State<ListSportTaskScreen> createState() => _ListSportTaskScreenState();
}

class _ListSportTaskScreenState extends State<ListSportTaskScreen> {
  // Track which events are confirmed
  Map<int, bool> confirmedStatus = {};
  Map<int, bool> rejectedStatus = {};

  // Track selected sport filter
  SportType? selectedSport;

  @override
  void initState() {
    super.initState();
    // Initialize with some default values for testing
    // confirmedStatus = {0: false, 1: false, 2: false, 3: false, 4: false};
    // rejectedStatus = {0: false, 1: false, 2: false, 3: false, 4: false};
    selectedSport = SportType.football;
    tasks = List.from(mockTasks);
  }

  List<SportType> get sports => sportsList;
  late List<TaskSportCardModel> tasks;

  void selectSport(SportType sport) {
    setState(() {
      selectedSport = sport;
    });
  }

  Future<void> _deleteTask(BuildContext blocContext, String taskId) async {
    await blocContext.read<SportsCubit>().deleteTask(taskId);
    if (!mounted) {
      return;
    }
    if (blocContext.read<SportsCubit>().state is SportsError) {
      return;
    }
    ShowSnackBar.show(
      blocContext,
      message: 'Task deleted successfully',
      type: SnackBarType.success,
    );
  }

  void createTask(BuildContext blocContext) async {
    final result = await showDialog<Map<String, String>>(
      context: blocContext,
      builder: (context) => const MatchDialog(),
    );

    if (!mounted || result == null) {
      return;
    }

    final isError = result['status'] == 'error';
    final message = result['message'] ?? 'Tao task thanh cong';
    final time = result['time'] ?? '';
    final scored = result['scored'] ?? '';
    final location = result['location'] ?? '';
    final newTask = TaskSportCardModel(
      id: IdGenerator.generateID(),
      sport: selectedSport ?? SportType.football,
      time: time,
      scored: scored,
      location: location,
      isCompleted: false,
      dateTime: DateTime.now(),
    );
    if (isError) {
      ShowSnackBar.show(
        blocContext,
        message: message,
        type: SnackBarType.error,
      );
      return;
    }

    await blocContext.read<SportsCubit>().addTask(newTask);
    if (!mounted) {
      return;
    }
    if (blocContext.read<SportsCubit>().state is SportsError) {
      return;
    }

    ShowSnackBar.show(
      blocContext,
      message: message,
      type: SnackBarType.success,
    );
  }

  void updateTask(BuildContext blocContext, TaskSportCardModel task) async {
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    await blocContext.read<SportsCubit>().updateTask(updatedTask);
    if (!mounted) {
      return;
    }
    if (blocContext.read<SportsCubit>().state is SportsError) {
      return;
    }
    ShowSnackBar.show(
      blocContext,
      message: updatedTask.isCompleted
          ? 'Task marked as completed'
          : 'Task marked as not completed',
      type: SnackBarType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SportsCubit()..loadAllTasks(),
      child: Builder(
        builder: (blocContext) => Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: const _AppBarWidget(),
          body: Column(
            children: [
              // Sports Icons Horizontal List - Fixed
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8),
                height: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: sports.map((sport) {
                    String sportNameLower = sport.name.toLowerCase();
                    String iconPath = 'assets/$sportNameLower.png';
                    bool isSelected = selectedSport == sport;

                    return _SportsCardFilterItemWidget(
                      name: _getSportDisplayName(sport),
                      icon: iconPath,
                      isSelected: isSelected,
                      onTap: () {
                        selectSport(sport);
                      },
                    );
                  }).toList(),
                ),
              ),
              // Scrollable Events List
              Expanded(
                child: _TasksListWidget(
                  selectedSport: selectedSport,
                  rejectedStatus: rejectedStatus,
                  onUpdateTask: updateTask,
                  onDeleteTask: _deleteTask,
                ),
              ),
            ],
          ),
          floatingActionButton: CustomFloatingActionButton(
            onPressed: () => createTask(blocContext),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        ),
      ),
    );
  }

  String _getSportDisplayName(SportType sport) {
    switch (sport) {
      case SportType.football:
        return 'Football';
      case SportType.basketball:
        return 'Basketball';
      case SportType.volleyball:
        return 'Volleyball';
      case SportType.golf:
        return 'Golf';
      case SportType.rugby:
        return 'Rugby';
    }
  }
}

class _TasksListWidget extends StatelessWidget {
  final SportType? selectedSport;
  final Map<int, bool> rejectedStatus;
  final void Function(BuildContext, TaskSportCardModel) onUpdateTask;
  final void Function(BuildContext, String) onDeleteTask;

  const _TasksListWidget({
    required this.selectedSport,
    required this.rejectedStatus,
    required this.onUpdateTask,
    required this.onDeleteTask,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SportsCubit, SportsState>(
      buildWhen: (previous, current) {
        return current is SportsLoading || current is SportsLoaded;
      },
      listener: (context, state) {
        if (state is SportsError) {
          ShowSnackBar.show(
            context,
            message: state.message,
            type: SnackBarType.error,
          );
        }
      },
      builder: (context, state) {
        final mockTasks = context.read<SportsCubit>().state is SportsLoaded ? (context.read<SportsCubit>().state as SportsLoaded).tasks : <TaskSportCardModel>[];
        if (state is SportsLoading && mockTasks.isEmpty) {
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: 4,
            itemBuilder: (context, index) {
              return const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: ListSportTaskSkeleton(),
              );
            },
          );
        }

        final sourceTasks = state is SportsLoaded ? state.tasks : mockTasks;

        // Filter tasks by selected sport
        final filteredTasks = sourceTasks
            .where((task) => task.sport == selectedSport)
            .toList();

        if (filteredTasks.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.sports_score_outlined,
                    size: 56,
                    color: AppTheme.grey400Color,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No tasks yet',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.grey700Color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to create your first task',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.grey600Color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        // Group tasks by date
        final Map<String, List<TaskSportCardModel>> groupedByDate = {};
        for (final task in filteredTasks) {
          final dateKey = task.dateTime != null
              ? '${task.dateTime!.day}/${task.dateTime!.month}/${task.dateTime!.year}'
              : 'No Date';
          groupedByDate.putIfAbsent(dateKey, () => []).add(task);
        }

        // Create a flat list with headers and task items
        final List<dynamic> itemsList = [];
        for (final dateKey in groupedByDate.keys) {
          itemsList.add({'type': 'header', 'date': dateKey});
          for (final task in groupedByDate[dateKey]!) {
            itemsList.add({'type': 'task', 'task': task});
          }
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          itemCount: itemsList.length,
          itemBuilder: (context, index) {
            final item = itemsList[index];

            if (item['type'] == 'header') {
              return Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 12),
                child: DateHeader(date: item['date']),
              );
            } else {
              final task = item['task'] as TaskSportCardModel;
              return _TaskItemWidget(
                task: task,
                index: index,
                rejectedStatus: rejectedStatus,
                onUpdateTask: onUpdateTask,
                onDeleteTask: onDeleteTask,
              );
            }
          },
        );
      },
    );
  }
}

class _TaskItemWidget extends StatelessWidget {
  final TaskSportCardModel task;
  final int index;
  final Map<int, bool> rejectedStatus;
  final void Function(BuildContext, TaskSportCardModel) onUpdateTask;
  final void Function(BuildContext, String) onDeleteTask;

  const _TaskItemWidget({
    required this.task,
    required this.index,
    required this.rejectedStatus,
    required this.onUpdateTask,
    required this.onDeleteTask,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cardBorderColor, width: 1),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Text section - takes 2/3 of space
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time
                Text(
                  'Time: ${TimeConvert.convertStringTimeToStringTime(task.time)}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                // Location
                Text(
                  'Location: ${task.location}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                // Scored
                Text(
                  'Scored: ${task.scored}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          // Action Buttons - takes 1/3 of space
          Expanded(
            flex: 1,
            child: TaskActionButtons(
              isCompleted: task.isCompleted,
              isRejected: rejectedStatus[index] ?? false,
              onConfirm: () {
                onUpdateTask(context, task);
              },
              onReject: () {
                // Show confirmation dialog before setting reject status
                showDialog(
                  context: context,
                  builder: (BuildContext dialogContext) {
                    return ConfirmRejectDialog(
                      onConfirm: () {
                        onDeleteTask(context, task.id);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const _AppBarWidget();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Container(
            alignment: Alignment.center,
            child: ButtonArrow(
              onPressed: () => Navigator.pop(context),
              iconAsset: 'assets/leftArrow.png',
              size: 40,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SportsCardFilterItemWidget extends StatelessWidget {
  final String name;
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SportsCardFilterItemWidget({
    required this.name,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 78,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : AppTheme.whiteColor,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 45,
              height: 45,
              child: Image.asset(icon, fit: BoxFit.contain),
            ),
            Text(
              name,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
