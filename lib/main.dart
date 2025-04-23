import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeline/providers/master_key_provider.dart';
import 'package:timeline/providers/vuelo_provider.dart';
import 'package:timeline/screens/timeline/timeline_screen.dart';
import 'screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/empresa_provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EmpresaProvider()),
        ChangeNotifierProvider(create: (_) => VueloProvider()),
        ChangeNotifierProvider(create: (_) => MasterKeyProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Timeline App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const TimelineScreen(),
      ),
    );
  }
}
