import 'package:equatable/equatable.dart';
import 'package:mv2629/models/taskTodoModel.dart';

abstract class TodoTaskState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TodoTaskInitial extends TodoTaskState {}

class TodoTaskLoading extends TodoTaskState {}

class TodoTaskLoaded extends TodoTaskState {
  final List<TaskTodoModel> tasks;
  final Set<String> taskDateKeys;
  final double completionRate;
  final int page;
  final int pageSize;
  final int totalCount;
  final bool hasNextPage;
  final bool isLoadingMore;
  final DateTime? selectedDate;
  final bool newestFirst;

  TodoTaskLoaded({
    required this.tasks,
    required this.taskDateKeys,
    required this.completionRate,
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.hasNextPage,
    required this.isLoadingMore,
    required this.selectedDate,
    required this.newestFirst,
  });

  TodoTaskLoaded copyWith({
    List<TaskTodoModel>? tasks,
    Set<String>? taskDateKeys,
    double? completionRate,
    int? page,
    int? pageSize,
    int? totalCount,
    bool? hasNextPage,
    bool? isLoadingMore,
    DateTime? selectedDate,
    bool clearSelectedDate = false,
    bool? newestFirst,
  }) {
    return TodoTaskLoaded(
      tasks: tasks ?? this.tasks,
      taskDateKeys: taskDateKeys ?? this.taskDateKeys,
      completionRate: completionRate ?? this.completionRate,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      totalCount: totalCount ?? this.totalCount,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      selectedDate: clearSelectedDate ? null : (selectedDate ?? this.selectedDate),
      newestFirst: newestFirst ?? this.newestFirst,
    );
  }

  @override
  List<Object?> get props => [
        tasks,
        taskDateKeys,
        completionRate,
        page,
        pageSize,
        totalCount,
        hasNextPage,
        isLoadingMore,
        selectedDate,
        newestFirst,
      ];
}

class TodoTaskError extends TodoTaskState {
  final String message;

  TodoTaskError({required this.message});

  @override
  List<Object?> get props => [message];
}
