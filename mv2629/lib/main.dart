import 'package:flutter/material.dart';
import 'package:mv2629/views/policyScreen.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mv2629/bloc/sports/sportsCubit.dart';
import 'package:mv2629/bloc/todos/todosCubit.dart';
import 'package:mv2629/bloc/movies/movieCubit.dart';
import 'package:mv2629/bloc/tvShows/tvShowCubit.dart';
import 'package:mv2629/models/taskSportCard.dart';
import 'package:mv2629/models/taskTodoModel.dart';
import 'package:mv2629/views/addTaskCalendarScreen.dart';
import 'package:mv2629/views/calendarScreen.dart';
import 'package:mv2629/views/home.dart';
import 'package:mv2629/views/listSportTaskScreen.dart';
import 'package:mv2629/views/movieScreen.dart';
import 'package:mv2629/views/settingScreen.dart';
import 'package:mv2629/views/splashScreen.dart';
import 'package:mv2629/views/statisticalScreen.dart';
import 'package:mv2629/views/todoScreen.dart';
import 'package:mv2629/views/tvScreen.dart';
import 'package:mv2629/views/game/penalty_home_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'constants/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await initializeDateFormatting('ms_MY', null);
  final appDocDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocDir.path);
  Hive.registerAdapter(SportTypeAdapter());
  Hive.registerAdapter(TaskSportCardModelAdapter());
  Hive.registerAdapter(TaskTodoModelAdapter());

  //open a box for task sport cards
  await Hive.openBox<TaskSportCardModel>('taskSportCards');
  await Hive.openBox<TaskTodoModel>('taskTodos');
  await Hive.openBox<String>('taskTodoDateLookup');
  await Hive.openBox<dynamic>('taskTodoDateIndex');
  await Hive.openBox<dynamic>('taskTodoMeta');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TaskTodoCubit>(
          create: (_) => TaskTodoCubit()..loadInitial(),
        ),
        BlocProvider<SportsCubit>(create: (_) => SportsCubit()..loadAllTasks()),
        BlocProvider<TvShowCubit>(create: (_) => TvShowCubit()),
        BlocProvider<MovieCubit>(create: (_) => MovieCubit()),
      ],
      child: MaterialApp(
        title: 'MV2629',
        builder: (context, child) {
          final textScale = getValueForScreenType<double>(
            context: context,
            mobile: 1.0,
            tablet: 1.25,
            desktop: 1.4,
          );

          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(
                MediaQuery.of(context).textScaler.scale(textScale),
              ),
            ),
            child: Theme(
              data: AppTheme.lightTheme.copyWith(
                iconTheme: AppTheme.lightTheme.iconTheme.copyWith(
                  size: getValueForScreenType<double>(
                    context: context,
                    mobile: 24.0,
                    tablet: 30.0,
                    desktop: 34.0,
                  ),
                ),
              ),
              child: child!,
            ),
          );
        },
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.light,
        home: const SplashScreen(),
        routes: {
          '/home': (context) => const Home(),
          '/splash': (context) => const SplashScreen(),
          '/listTask': (context) => const ListSportTaskScreen(),
          '/movie': (context) => const MovieScreen(),
          '/tv': (context) => const Tvscreen(), // Placeholder for TV Screen
          '/statistical': (context) => const Statisticalscreen(),
          '/settings': (context) => Settingscreen(),
          '/game': (context) => const PenaltyHomeScreen(),
          '/todo': (context) =>
              const TodoScreen(), // Placeholder for To Do List Screen
          '/calendar': (context) =>
              const CalendarScreen(), // Placeholder for Calendar Screen
          '/addTask': (context) =>
              AddTaskCalendar(), 
          '/policy': (context) => const PolicyScreenIOS(), // Placeholder for Privacy Policy Screen
        },
      ),
    );
  }
}
