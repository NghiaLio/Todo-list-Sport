// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mv2629/bloc/todos/todosCubit.dart';
import 'package:mv2629/bloc/todos/todosState.dart';
import 'package:mv2629/constants/theme.dart';
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
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AppBar
              _buildAppBar(),
              // Welcome Box
              _buildTextContent(context),

              SizedBox(height: 32),

              // Sports Card
              _buildSportsCard(_navigateToListSportTask),

              SizedBox(height: 16),

              // To Do List Card
              _buildTodoCard(_navigateToTodoScreen),
            ],
          ),
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

  Widget _buildAppBar() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: IconButton(
        icon: Image.asset('assets/iconDrawer.png', width: 24, height: 24),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      shape: RoundedRectangleBorder(
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
          _buildCustomDrawerItem(
            icon: Icons.home,
            label: 'Home',
            isSelected: true,
            onTap: () => _navigateFromDrawer(null),
          ),
          _buildCustomDrawerItem(
            icon: Icons.tv,
            label: 'TV show',
            isSelected: false,
            onTap: () => _navigateFromDrawer('/tv'),
          ),
          _buildCustomDrawerItem(
            icon: Icons.movie,
            label: 'Movies',
            isSelected: false,
            onTap: () => _navigateFromDrawer('/movie'),
          ),
          _buildCustomDrawerItem(
            icon: Icons.bar_chart,
            label: 'Statistical',
            isSelected: false,
            onTap: () => _navigateFromDrawer('/statistical'),
          ),
          _buildCustomDrawerItem(
            icon: Icons.settings,
            label: 'Setting',
            isSelected: false,
            onTap: () => _navigateFromDrawer('/settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomDrawerItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        Container(
          // margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.whiteColor : AppTheme.transparentColor,
            // borderRadius: BorderRadius.circular(8),
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
            ? Divider(color: AppTheme.white50Color, thickness: 1)
            : SizedBox.shrink(),
      ],
    );
  }

  Widget _buildTextContent(BuildContext context) {
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

  Widget _buildSportsCard(Function()? onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        height: 250,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Rectangle 474.png'),
            fit: BoxFit.contain,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Center(
                child: Image.asset('assets/logo.png', width: 91, height: 91),
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

  Widget _buildTodoCard(Function()? onTap) {
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
              height: 250,
              decoration: BoxDecoration(
                image: DecorationImage(
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'To Do List',
                      style: Theme.of(context).textTheme.displayMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 110,
                                    height: 110,
                                    child: CircularProgressIndicator(
                                      value: completionRate,
                                      strokeWidth: 8,
                                      valueColor: AlwaysStoppedAnimation(
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
                    ),
                    SizedBox.shrink(),
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
