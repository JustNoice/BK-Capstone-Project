import 'package:bk_lapor_book_main/pages/DetailPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:bk_lapor_book_main/firebase_options.dart';
import 'package:bk_lapor_book_main/pages/AddFormPage.dart';
import 'package:bk_lapor_book_main/pages/dashboard/DashboardPage.dart';
import 'package:bk_lapor_book_main/pages/LoginPage.dart';
import 'package:bk_lapor_book_main/pages/RegisterPage.dart';
import 'package:bk_lapor_book_main/pages/SplashPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(
    title: "Aplikasi Lapor Book",
    initialRoute: '/',
    routes: {
      '/': (context) => const SplashPage(),
      '/login': (context) => const LoginPage(),
      '/register': (context) => const RegisterPage(),
      '/dashboard': (context) => const DashboardPage(),
      '/add': (context) => const AddFormPage(),
      '/detail': (context) => const DetailPage(),
    },
  ));
}
