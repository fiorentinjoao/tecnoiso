import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'data/equipment_repository.dart';
import 'data/hive_setup.dart';
import 'pages/intro_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHive();
  registerAdapters();
  await openBoxes();
  await EquipmentRepository.instance.seedIfNeeded();
  runApp(const TecnoisoApp());
}

class TecnoisoApp extends StatelessWidget {
  const TecnoisoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tecnoiso',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF09090B),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFDC2626),
          secondary: const Color(0xFF991B1B),
          surface: const Color(0xFF18181B),
        ),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      home: const IntroPage(),
    );
  }
}
