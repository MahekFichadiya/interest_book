import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:interest_book/Contact/ContactList.dart';
import 'package:interest_book/Home/CustomerList.dart';
import 'package:interest_book/Utils/app_colors.dart';
import 'package:interest_book/Utils/greeting_helper.dart';
import 'package:interest_book/Widgets/app_logo.dart';
import 'package:interest_book/Screens/logo_showcase.dart';
import 'package:interest_book/Reminders/notifications_page.dart';
import 'package:interest_book/Reminders/reminders_page.dart';
import 'package:interest_book/Provider/notification_provider.dart';
import 'package:interest_book/Services/notification_service.dart';
import 'package:interest_book/Services/realtime_reminder_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  bool _showSearchBar = true;
  String? name;

  final ScrollController _scrollController = ScrollController();

  String _searchQuery = '';

  loadName() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      name = prefs.getString("name") ?? '';
    });
  }

  @override
  void initState() {
    super.initState();
    loadName();

    // Initialize notification service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService().initialize();
      NotificationService().requestPermissions();
      context.read<NotificationProvider>().updateUnreadCount();
      context.read<NotificationProvider>().checkForOverdueNotifications();

      // Ensure real-time reminder service is running
      RealtimeReminderService().startRealtimeChecking();
    });

    // Set status bar color
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: AppColors.primaryDark,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));

    _scrollController.addListener(() {
      if (_scrollController.offset > 50 && _showSearchBar) {
        setState(() => _showSearchBar = false);
      } else if (_scrollController.offset <= 50 && !_showSearchBar) {
        setState(() => _showSearchBar = true);
      }
    });

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;
    final isSmallScreen = screenHeight < 700;
    final isTablet = screenWidth > 600;

    // Responsive dimensions
    final horizontalPadding = isTablet ? 16.0 : 10.0;
    final titleFontSize = isSmallScreen ? 18.0 : 20.0;

    return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        title: Row(
          children: [
            AppLogo(
              size: isSmallScreen ? 40 : 45,
              showShadow: false,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 5, bottom: 0),
                    child: Text(
                      "${GreetingHelper.getTimeBasedGreeting()},",
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14.0 : 16.0,
                        fontWeight: FontWeight.w400,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  Text(
                    name ?? "Mahek Soni",
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              return Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const NotificationsPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.notifications_outlined),
                  ),
                  if (notificationProvider.hasUnreadNotifications)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          notificationProvider.unreadCount > 99
                              ? '99+'
                              : notificationProvider.unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const RemindersPage(),
                ),
              );
            },
            icon: const Icon(Icons.alarm),
            tooltip: 'Reminders',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings_outlined),
            onSelected: (value) {
              switch (value) {
                case 'logo_showcase':
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const LogoShowcase(),
                    ),
                  );
                  break;
                case 'settings':
                  // Add other settings functionality here
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'logo_showcase',
                child: Row(
                  children: [
                    Icon(Icons.palette_outlined),
                    SizedBox(width: 8),
                    Text('Logo Showcase'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
            ],
          ),
        ],
        toolbarHeight: isSmallScreen ? 60 : 70,
      ),
      body: Column(
        children: [
          // Search bar section
          if (_showSearchBar)
            Container(
              color: AppColors.primary,
              padding: EdgeInsets.only(
                left: horizontalPadding,
                right: horizontalPadding,
                bottom: isSmallScreen ? 12 : 16,
              ),
              child: Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(12),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                  decoration: InputDecoration(
                    hintText: "Search customers...",
                    hintStyle: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: Colors.grey[600],
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      size: isSmallScreen ? 20 : 24,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: isSmallScreen ? 12 : 16,
                    ),
                  ),
                ),
              ),
            ),

          // Main content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                top: isSmallScreen ? 8 : 10,
                left: horizontalPadding / 2,
                right: horizontalPadding / 2,
              ),
              child: CustomerList(
                scrollController: _scrollController,
                searchQuery: _searchQuery,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ContactList(title: "Contact"),
            ),
          );
        },
        backgroundColor: Colors.blueGrey,
        child: Icon(
          Icons.phone,
          size: isSmallScreen ? 20 : 24,
          color: Colors.white,
        ),
      ),
    );
  }
}
