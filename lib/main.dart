import 'package:flutter/material.dart';
import 'package:note_intake_app/ui/homescreen.dart';

void main() {
  runApp(const NoteApp());
}

class NoteApp extends StatefulWidget {
  const NoteApp({super.key});

  @override
  State<NoteApp> createState() => _NoteAppState();
}

class _NoteAppState extends State<NoteApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Note App",
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true),
      home: const Homescreen(),
    );
  }
}
