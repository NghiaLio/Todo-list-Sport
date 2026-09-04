// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/todos/todosCubit.dart';
import '../bloc/todos/todosState.dart';
import '../constants/theme.dart';
import '../widgets/button_arrow.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _navigateToListSportTask() {
    Navigator.pushNamed(context, '/listTask');
  }

  void _navigateToTodoScreen() {
    Navigator.pushNamed(context, '/todo');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.grey100Color,
      drawer: _DrawerWidget(onNavigate: _navigateFromDrawer),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // AppBar
                      _AppBarWidget(
                        onOpenDrawer: () =>
                            _scaffoldKey.currentState?.openDrawer(),
                      ),
                      // Welcome Box
                      const _WelcomeTextWidget(),

                      const Spacer(),

                      // Sports Card
                      _SportsCardWidget(onTap: _navigateToListSportTask),

                      const SizedBox(height: 16),

                      // To Do List Card
                      _TodoCardWidget(onTap: _navigateToTodoScreen),

                      const Spacer(flex: 2),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _navigateFromDrawer(String? routeName) {
    Navigator.pop(context); // Close the drawer
    if (routeName != null) {
      Navigator.pushNamed(context, routeName);
    }
  }
}

class _AppBarWidget extends StatelessWidget {
  final VoidCallback onOpenDrawer;

  const _AppBarWidget({required this.onOpenDrawer});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: IconButton(
        icon: Image.asset(
          'assets/iconDrawer.png',
          width: getValueForScreenType<double>(
            context: context,
            mobile: 24,
            tablet: 40,
            desktop: 24,
          ),
          height: getValueForScreenType<double>(
            context: context,
            mobile: 24,
            tablet: 40,
            desktop: 24,
          ),
        ),
        onPressed: onOpenDrawer,
      ),
    );
  }
}

class _DrawerWidget extends StatelessWidget {
  final void Function(String?) onNavigate;

  const _DrawerWidget({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      backgroundColor: AppTheme.primaryColor,
      width: MediaQuery.of(context).size.width * 0.4,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 60, bottom: 20),
            child: Container(
              height: 60,
              color: AppTheme.primaryColor,
              alignment: Alignment.bottomCenter,
              child: Text(
                'Menu',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.whiteColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          _CustomDrawerItem(
            icon: Icons.home,
            label: 'Home',
            isSelected: true,
            onTap: () => onNavigate(null),
          ),
          _CustomDrawerItem(
            icon: Icons.tv,
            label: 'TV show',
            isSelected: false,
            onTap: () => onNavigate('/tv'),
          ),
          _CustomDrawerItem(
            icon: Icons.movie,
            label: 'Movies',
            isSelected: false,
            onTap: () => onNavigate('/movie'),
          ),
          _CustomDrawerItem(
            icon: Icons.bar_chart,
            label: 'Statistical',
            isSelected: false,
            onTap: () => onNavigate('/statistical'),
          ),

          _CustomDrawerItem(
            icon: Icons.sports_esports,
            label: 'Game',
            isSelected: false,
            onTap: () => onNavigate('/game'),
          ),
          _CustomDrawerItem(
            icon: Icons.settings,
            label: 'Setting',
            isSelected: false,
            onTap: () => onNavigate('/settings'),
          ),
        ],
      ),
    );
  }
}

class _CustomDrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CustomDrawerItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.whiteColor : AppTheme.transparentColor,
          ),
          child: ListTile(
            leading: Icon(
              icon,
              color: isSelected ? AppTheme.primaryColor : AppTheme.whiteColor,
            ),
            title: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isSelected ? AppTheme.primaryColor : AppTheme.whiteColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: onTap,
          ),
        ),
        !isSelected
            ? const Divider(color: AppTheme.white50Color, thickness: 1)
            : const SizedBox.shrink(),
      ],
    );
  }
}

class _WelcomeTextWidget extends StatelessWidget {
  const _WelcomeTextWidget();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to To-do \nList',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: AppTheme.blackColor,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.left,
          ),
          Text(
            'where your plans \ncome into focus!',
            textAlign: TextAlign.left,
            style: Theme.of(
              context,
            ).textTheme.displaySmall?.copyWith(color: AppTheme.grey600Color),
          ),
        ],
      ),
    );
  }
}

class _SportsCardWidget extends StatelessWidget {
  final VoidCallback? onTap;

  const _SportsCardWidget({this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        height: getValueForScreenType<double>(
          context: context,
          mobile: 250,
          tablet: MediaQuery.of(context).orientation == Orientation.portrait
              ? 350
              : 250,
          desktop: 300,
        ),
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('assets/Rectangle 474.png'),
            fit: BoxFit.contain,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Center(
                child: Image.asset(
                  'assets/logo.png',
                  width: getValueForScreenType<double>(
                    context: context,
                    mobile: 91,
                    tablet: 120,
                    desktop: 91,
                  ),
                  height: getValueForScreenType<double>(
                    context: context,
                    mobile: 91,
                    tablet: 120,
                    desktop: 91,
                  ),
                ),
              ),
              Text(
                'Sports',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ButtonArrow(
                onPressed: onTap,
                iconAsset: 'assets/rightArrow.png',
                size: 69,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodoCardWidget extends StatelessWidget {
  final VoidCallback? onTap;

  const _TodoCardWidget({this.onTap});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskTodoCubit, TodoTaskState>(
      builder: (context, state) {
        double completionRate = 0;
        int total = 0;
        int completed = 0;

        if (state is TodoTaskLoaded) {
          completionRate = state.completionRate.clamp(0, 1);
          total = state.totalCount;
          completed = (completionRate * total).round();
        }

        return GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              height: getValueForScreenType<double>(
                context: context,
                mobile: 250,
                tablet:
                    MediaQuery.of(context).orientation == Orientation.portrait
                    ? 350
                    : 250,
                desktop: 300,
              ),
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/Rectangle 473.png'),
                  fit: BoxFit.contain,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 32,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      'To Do List',
                      style: Theme.of(context).textTheme.displayMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: getValueForScreenType<double>(
                                    context: context,
                                    mobile: 110,
                                    tablet: 150,
                                    desktop: 130,
                                  ),
                                  height: getValueForScreenType<double>(
                                    context: context,
                                    mobile: 110,
                                    tablet: 150,
                                    desktop: 130,
                                  ),
                                  child: CircularProgressIndicator(
                                    value: completionRate,
                                    strokeWidth: 8,
                                    valueColor: const AlwaysStoppedAnimation(
                                      AppTheme.whiteColor,
                                    ),
                                    backgroundColor: AppTheme.white20Color,
                                  ),
                                ),
                                Text(
                                  '$completed/$total',
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
