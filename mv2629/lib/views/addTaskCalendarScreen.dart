// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mv2629/bloc/todos/todosCubit.dart';
import 'package:mv2629/models/taskTodoModel.dart';
import 'package:mv2629/constants/theme.dart';
import 'package:mv2629/utils/id_generator.dart';
import 'package:mv2629/widgets/custom_header.dart';
import 'package:mv2629/widgets/showSnackBar.dart';

class AddTaskCalendar extends StatefulWidget {
  final DateTime selectedDate;

  AddTaskCalendar({super.key, DateTime? selectedDate})
    : selectedDate = selectedDate ?? DateTime.now();

  @override
  State<AddTaskCalendar> createState() => _AddTaskCalendarState();
}

class _AddTaskCalendarState extends State<AddTaskCalendar>
    with SingleTickerProviderStateMixin {
  List<IconData> tabIcons = [Icons.edit_document, Icons.more_time];
  late TabController _tabController;
  late TextEditingController _taskNameController;
  late TextEditingController _hourController;
  late TextEditingController _minuteController;
  late TextEditingController _contentController;
  late DateTime _selectedDate;
  String _period = 'AM';

  Future<void> _handleConfirm() async {
    final taskName = _taskNameController.text.trim();
    final content = _contentController.text.trim();
    final hour = int.tryParse(_hourController.text.trim());
    final minute = int.tryParse(_minuteController.text.trim());

    if (taskName.isEmpty || content.isEmpty) {
      _showMessage(
        'Task name and content are required',
        type: SnackBarType.error,
      );
      return;
    }

    if (hour == null ||
        minute == null ||
        hour < 1 ||
        hour > 12 ||
        minute < 0 ||
        minute > 59) {
      _showMessage('Time is invalid', type: SnackBarType.error);
      return;
    }

    final hour24 = _to24Hour(hour, _period);
    final taskDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      hour24,
      minute,
    );

    final todo = TaskTodoModel(
      id: IdGenerator.generateID(),
      taskName: taskName,
      content: content,
      time: _formatDisplayTime(hour, minute, _period),
      isCompleted: false,
      dateTime: taskDateTime,
    );

    await context.read<TaskTodoCubit>().addTask(todo);
    if (!mounted) {
      return;
    }
    _showMessage('Task created successfully', type: SnackBarType.success);
    Navigator.pop(context);
  }

  int _to24Hour(int hour12, String period) {
    if (period == 'AM') {
      return hour12 == 12 ? 0 : hour12;
    }
    return hour12 == 12 ? 12 : hour12 + 12;
  }

  String _formatDisplayTime(int hour12, int minute, String period) {
    final h = hour12.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m $period';
  }

  void _showMessage(
    String message, {
    SnackBarType type = SnackBarType.success,
  }) {
    ShowSnackBar.show(context, message: message, type: type);
  }

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;

    final hour24 = _selectedDate.hour;
    final minute = _selectedDate.minute;
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;

    _period = hour24 >= 12 ? 'PM' : 'AM';
    _tabController = TabController(length: tabIcons.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging || !_tabController.indexIsChanging) {
        FocusManager.instance.primaryFocus?.unfocus();
      }
    });

    _taskNameController = TextEditingController(text: 'Name Task');
    _hourController = TextEditingController(text: hour12.toString());
    _minuteController = TextEditingController(
      text: minute.toString().padLeft(2, '0'),
    );
    _contentController = TextEditingController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _taskNameController.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: Column(
          children: [
            // Custom Header
            CustomHeader(
              title: 'Add Task',
              rightIconAsset: 'assets/confirm.png',
              onRightIconTap: _handleConfirm,
            ),
            // Body
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                child: Column(
                  children: [
                    // Tab bar
                    _TabBarWidget(
                      tabController: _tabController,
                      tabIcons: tabIcons,
                    ),
                    const SizedBox(height: 16),
                    // Tab contents
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _TaskNameTabWidget(
                            taskNameController: _taskNameController,
                            contentController: _contentController,
                          ),
                          _TimeTabWidget(
                            hourController: _hourController,
                            minuteController: _minuteController,
                            period: _period,
                            onPeriodChanged: (newPeriod) {
                              setState(() {
                                _period = newPeriod;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class _TaskNameTabWidget extends StatelessWidget {
  final TextEditingController taskNameController;
  final TextEditingController contentController;

  const _TaskNameTabWidget({
    required this.taskNameController,
    required this.contentController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          TextField(
            controller: taskNameController,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.greyColor,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * 0.3,
            ),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              controller: contentController,
              maxLines: null,
              style: Theme.of(context).textTheme.bodyMedium,
              decoration: const InputDecoration(
                hintText: 'Start writing here.....',
                hintStyle: TextStyle(color: AppTheme.black54Color),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _TimeTabWidget extends StatelessWidget {
  final TextEditingController hourController;
  final TextEditingController minuteController;
  final String period;
  final ValueChanged<String> onPeriodChanged;

  const _TimeTabWidget({
    required this.hourController,
    required this.minuteController,
    required this.period,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height * 0.15,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Hour
          Container(
            width: 90,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primary30Color, // Light blue background
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: TextField(
              controller: hourController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 48,
                color: AppTheme.primaryColor,
              ),
              decoration: const InputDecoration(border: InputBorder.none),
              onChanged: (val) {
                // handle validation later if needed
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              ':',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
          ),
          // Minute
          Container(
            width: 90,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.dividerSoftColor, // Light grey background
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: TextField(
              controller: minuteController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 48,
                color: AppTheme.black87Color,
              ),
              decoration: const InputDecoration(border: InputBorder.none),
              onChanged: (val) {
                // handle validation later if needed
              },
            ),
          ),
          const SizedBox(width: 16),
          // AM/PM Toggle
          Container(
            height: 80,
            width: 60,
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.grey300Color),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      onPeriodChanged('AM');
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: period == 'AM'
                            ? AppTheme.primary30Color
                            : AppTheme.transparentColor,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'AM',
                        style: TextStyle(
                          color: period == 'AM'
                              ? AppTheme.primaryColor
                              : AppTheme.greyColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Divider(height: 1, color: AppTheme.grey300Color),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      onPeriodChanged('PM');
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: period == 'PM'
                            ? AppTheme.primary30Color
                            : AppTheme.transparentColor,
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(8),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'PM',
                        style: TextStyle(
                          color: period == 'PM'
                              ? AppTheme.primaryColor
                              : AppTheme.greyColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabBarWidget extends StatelessWidget {
  final TabController tabController;
  final List<IconData> tabIcons;

  const _TabBarWidget({
    required this.tabController,
    required this.tabIcons,
  });

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: tabController,
      indicatorColor: AppTheme.transparentColor,
      dividerColor: AppTheme.transparentColor,
      labelColor: AppTheme.primaryColor,
      unselectedLabelColor: AppTheme.blackColor,
      tabs: tabIcons.map((icon) {
        return Tab(icon: Icon(icon, size: 28));
      }).toList(),
    );
  }
}
