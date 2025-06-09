import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:staffpoint/service/notification_service.dart';
import 'page/login_page.dart';
import 'page/user/user_dashboard.dart';
import 'page/admin/admin_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Hive.initFlutter();
  await Hive.openBox('authBox');
  await initNotification();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Widget getStartPage() {
    final box = Hive.box('authBox');
    final token = box.get('token');
    final role = box.get('role');

    if (token == null || role == null) {
      return LoginPage();
    } else if (role.toString().toLowerCase() == "admin") {
      return const AdminDashboard();
    } else {
      return const UserDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StaffPoint',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.deepPurple[50],
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: getStartPage(),
    );
  }
}
