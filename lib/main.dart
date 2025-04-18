import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/eventos_provider.dart';
import './timeline_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EventosProvider(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: TimelineScreen(),
      ),
    );
  }
}
