import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/constants.dart';
import 'providers/risk_provider.dart';
import 'providers/alert_provider.dart';
import 'screens/home_screen.dart';
import 'screens/alert_list_screen.dart';
import 'screens/education_screen.dart';
import 'screens/settings_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(const AlertVNApp());
}

class AlertVNApp extends StatelessWidget {
  const AlertVNApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RiskProvider()),
        ChangeNotifierProvider(create: (_) => AlertProvider()),
      ],
      child: MaterialApp(
        title: 'AlertVN',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: kPrimaryColor,
            primary: kPrimaryColor,
            secondary: kSecondaryColor,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            titleTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ),
        home: const MainNavigation(),
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final _screens = const [
    HomeScreen(),
    AlertListScreen(),
    EducationScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Consumer<AlertProvider>(
        builder: (_, alertProv, __) => NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          backgroundColor: Colors.white,
          indicatorColor: kPrimaryColor.withOpacity(0.12),
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.map_outlined),
              selectedIcon: Icon(Icons.map, color: kPrimaryColor),
              label: 'Bản đồ',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: alertProv.redCount > 0,
                label: Text('${alertProv.redCount}'),
                child: const Icon(Icons.notifications_outlined),
              ),
              selectedIcon: Badge(
                isLabelVisible: alertProv.redCount > 0,
                label: Text('${alertProv.redCount}'),
                child: const Icon(Icons.notifications, color: kPrimaryColor),
              ),
              label: 'Cảnh báo',
            ),
            const NavigationDestination(
              icon: Icon(Icons.school_outlined),
              selectedIcon: Icon(Icons.school, color: kPrimaryColor),
              label: 'Kiến thức',
            ),
            const NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings, color: kPrimaryColor),
              label: 'Cài đặt',
            ),
          ],
        ),
      ),
    );
  }
}
