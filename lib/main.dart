import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/note_detail_screen.dart';
import '../screens/note_editor.dart';
import '../screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ink Sync',
      theme: ThemeData(
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          color: Colors.teal,
        ),
        textTheme: const TextTheme(
          bodyText1: TextStyle(color: Colors.black),
          bodyText2: TextStyle(color: Colors.black),
        ),
        colorScheme:
        ColorScheme.fromSwatch().copyWith(secondary: Colors.tealAccent),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/note_editor': (context) => const NoteEditorScreen(),
        '/note_detail': (context) => const NoteDetailScreen(),
        '/note_update': (context) => const NoteEditorScreen(),
      },
    );
  }
}
