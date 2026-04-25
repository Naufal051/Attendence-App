import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    //untuk project ini hardcode, biar kalian ga perlu setup .env (tapi jangan ditiru yaa)
    url: 'https://bskyhxwooecxiuqrrijl.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJza3loeHdvb2VjeGl1cXJyaWpsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUxMDkzMzMsImV4cCI6MjA5MDY4NTMzM30.FVCQxI8yDDP83k7mw13aQFS8u1lcJIKsoo8GxNRfmJ4',
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Attendance App',
      theme: ThemeData.light(),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}
