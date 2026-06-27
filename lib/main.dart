import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://porednhvtmiussyanobo.supabase.co',
    // Sửa anonKey thành publishableKey ở ngay dòng dưới này:
    publishableKey: 'sb_publishable_Nd6_4rS_CdJfL4wuspVzZQ_y0qiQKDN',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'English App',
      theme: ThemeData(
        fontFamily: 'Roboto',
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}
