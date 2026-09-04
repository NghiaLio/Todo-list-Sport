// ignore_for_file: deprecated_member_use

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/todos/todosCubit.dart';
import '../bloc/todos/todosState.dart';
import '../constants/theme.dart';
import '../models/taskTodoModel.dart';
import '../views/addTaskCalendarScreen.dart';
import '../views/skeleton/calendar_task_skeleton.dart';
import '../widgets/custom_header.dart';
import '../widgets/task_content_card.dart';
import '../widgets/custom_floating_action_button.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  List<DateTime?> _dialogCalendarPickerValue = [DateTime.now()];
  late DateTime _selectedDate;
  late TaskTodoCubit _todoCubit;
  List<TaskTodoModel>? _dayTasks;
  bool _isLoadingTasks = true;

  @override
  void initState() {
    super.initState();
    _todoCubit = context.read<TaskTodoCubit>();
    _selectedDate = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    _fetchTasksForSelectedDate();
  }

  Future<void> _fetchTasksForSelectedDate() async {
    setState(() {
      _isLoadingTasks = true;
    });
    try {
      final tasks = await _todoCubit.getTasksForDate(_selectedDate);
      if (mounted) {
        setState(() {
          _dayTasks = tasks;
          _isLoadingTasks = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _dayTasks = [];
          _isLoadingTasks = false;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _navigateToAddTask(DateTime selectedDate) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTaskCalendar(selectedDate: selectedDate),
      ),
    );

    if (!mounted) {
      return;
    }
    await _todoCubit.refresh();
  }

  Future<void> _navigateToEditTask(TaskTodoModel task) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AddTaskCalendar(selectedDate: task.dateTime, task: task),
      ),
    );

    if (!mounted) {
      return;
    }
    await _todoCubit.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomHeader(title: 'Calendar'),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    _CalendarWidget(
                      dialogCalendarPickerValue: _dialogCalendarPickerValue,
                      onValueChanged: (dates) {
                        setState(() {
                          _dialogCalendarPickerValue = dates;
                        });

                        if (dates.isNotEmpty) {
                          final picked = dates.first;
                          if (picked != null) {
                            _selectedDate = DateTime(
                              picked.year,
                              picked.month,
                              picked.day,
                            );
                            _fetchTasksForSelectedDate();
                          }
                        }
                      },
                      onDateSelected: (date) {
                        setState(() {
                          _selectedDate = DateTime(
                            date.year,
                            date.month,
                            date.day,
                          );
                          _dialogCalendarPickerValue = [_selectedDate];
                        });
                        _fetchTasksForSelectedDate();
                      },
                    ),
                    _TaskListWidget(
                      isLoadingTasks: _isLoadingTasks,
                      dayTasks: _dayTasks,
                      onRefresh: _fetchTasksForSelectedDate,
                      onEditTask: _navigateToEditTask,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: CustomFloatingActionButton(
        onPressed: () => _navigateToAddTask(_selectedDate),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _CalendarWidget extends StatelessWidget {
  final List<DateTime?> dialogCalendarPickerValue;
  final ValueChanged<List<DateTime?>> onValueChanged;
  final ValueChanged<DateTime> onDateSelected;

  const _CalendarWidget({
    required this.dialogCalendarPickerValue,
    required this.onValueChanged,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final dayCircleSize = (MediaQuery.sizeOf(context).width * 0.1)
        .clamp(36.0, 48.0)
        .toDouble();

    return BlocBuilder<TaskTodoCubit, TodoTaskState>(
      buildWhen: (previous, current) {
        if (previous is TodoTaskLoaded && current is TodoTaskLoaded) {
          return previous.taskDateKeys != current.taskDateKeys;
        }
        return true;
      },
      builder: (context, state) {
        final taskDateKeys = state is TodoTaskLoaded
            ? state.taskDateKeys
            : <String>{};

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: CalendarDatePicker2(
                  config: CalendarDatePicker2Config(
                    calendarType: CalendarDatePicker2Type.single,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    firstDayOfWeek: 1,
                    useAbbrLabelForMonthModePicker: true,
                    lastMonthIcon: const Icon(
                      Icons.chevron_left,
                      color: AppTheme.whiteColor,
                    ),
                    nextMonthIcon: const Icon(
                      Icons.chevron_right,
                      color: AppTheme.whiteColor,
                    ),
                    controlsTextStyle: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(
                          color: AppTheme.whiteColor,
                          fontSize: 15,
                        ),
                    weekdayLabelTextStyle: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                          color: AppTheme.whiteColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                    dayBuilder:
                        ({
                          required date,
                          textStyle,
                          decoration,
                          isSelected,
                          isDisabled,
                          isToday,
                        }) {
                          final isMonday = date.weekday == DateTime.monday;
                          final dayKey = DateFormat(
                            'yyyyMMdd',
                          ).format(DateTime(date.year, date.month, date.day));
                          final hasTask = taskDateKeys.contains(dayKey);

                          Color numberBg;
                          Color numberColor;

                          if (isToday == true) {
                            numberBg = AppTheme.whiteColor;
                            numberColor = AppTheme.primaryColor;
                          } else if (isSelected == true) {
                            numberBg = AppTheme.secondaryColor;
                            numberColor = AppTheme.blackColor;
                          } else if (isDisabled == true) {
                            numberBg = AppTheme.transparentColor;
                            numberColor = AppTheme.white30Color;
                          } else if (hasTask) {
                            numberBg = AppTheme.primary30Color;
                            numberColor = AppTheme.whiteColor;
                          } else {
                            numberBg = isMonday
                                ? AppTheme.primaryColor
                                : AppTheme.transparentColor;
                            numberColor = AppTheme.whiteColor;
                          }

                          return GestureDetector(
                            onTap: isDisabled == true
                                ? null
                                : () => onDateSelected(date),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: dayCircleSize,
                                    height: dayCircleSize,
                                    decoration: BoxDecoration(
                                      color: numberBg,
                                      shape: BoxShape.circle,
                                      border: isSelected == true
                                          ? Border.all(
                                              color: AppTheme.whiteColor,
                                              width: 2,
                                            )
                                          : (!(isSelected == true ||
                                                    isToday == true ||
                                                    isDisabled == true) &&
                                                !isMonday)
                                          ? Border.all(
                                              color: AppTheme.white50Color,
                                              width: 1.2,
                                            )
                                          : null,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${date.day}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: numberColor,
                                            fontSize: dayCircleSize * 0.39,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                  ),
                  value: dialogCalendarPickerValue,
                  onValueChanged: onValueChanged,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TaskListWidget extends StatelessWidget {
  final bool isLoadingTasks;
  final List<TaskTodoModel>? dayTasks;
  final VoidCallback onRefresh;
  final void Function(TaskTodoModel) onEditTask;

  const _TaskListWidget({
    required this.isLoadingTasks,
    this.dayTasks,
    required this.onRefresh,
    required this.onEditTask,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<TaskTodoCubit, TodoTaskState>(
      listenWhen: (previous, current) => current is TodoTaskLoaded,
      listener: (context, state) {
        if (state is TodoTaskLoaded) {
          onRefresh();
        }
      },
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (isLoadingTasks || dayTasks == null) {
      return ListView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        itemBuilder: (context, index) => const CalendarTaskSkeleton(),
      );
    }

    if (dayTasks!.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text('No tasks for selected day'),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: dayTasks!.length,
      itemBuilder: (context, index) {
        final task = dayTasks![index];
        return GestureDetector(
          onTap: () => onEditTask(task),
          child: TaskContentCard(
            taskName: task.taskName,
            content: task.content,
            time: task.time,
            isCompleted: task.isCompleted,
            isRejected: false,
            onConfirm: () =>
                context.read<TaskTodoCubit>().toggleTaskCompletion(task),
            onReject: () => context.read<TaskTodoCubit>().deleteTask(task.id),
          ),
        );
      },
    );
  }
}
