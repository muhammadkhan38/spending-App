import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'services/hive_service.dart';
import 'utils/app_theme.dart';
import 'views/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await HiveService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Spending Tracker',
      theme: AppTheme.lightTheme,
      home: const HomeView(),
    );
  }
}
