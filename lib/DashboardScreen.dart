import 'package:flutter/material.dart';
import 'package:interest_book/Home/HomePage.dart';
import 'package:interest_book/Profile/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int currentPage = 0;
  List<Widget> pages = [
    HomePage(),
    ProfileScreen(),
  ];

  changeIndex(int index) {
    setState(() {
      currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final isSmallScreen = screenHeight < 700;

    // Responsive dimensions
    final iconSize = isSmallScreen ? 20.0 : 24.0;

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: currentPage,
          children: pages,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        destinations: [
          NavigationDestination(
            icon: Icon(
              Icons.home,
              size: iconSize,
            ),
            label: "Home",
          ),
          NavigationDestination(
            icon: Icon(
              Icons.person,
              size: iconSize,
            ),
            label: "Profile",
          ),
        ],
        onDestinationSelected: (int index) {
          changeIndex(index);
        },
        selectedIndex: currentPage,
        backgroundColor: Colors.white,
        indicatorColor: Colors.blueGrey.withValues(alpha: 0.2),
        height: isSmallScreen ? 60 : 70,
        labelBehavior: isSmallScreen
            ? NavigationDestinationLabelBehavior.onlyShowSelected
            : NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
}
