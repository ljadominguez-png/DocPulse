import 'package:flutter/material.dart';
import 'package:textrepresentation/front/frontpage.dart';
import 'package:textrepresentation/theme/theme_controller.dart';

void main() {
  runApp(const DocPulse());
}

class DocPulse extends StatelessWidget{
  const DocPulse({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable:  AppThemeController.mode,
      builder: (context, currentMode, _) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: currentMode,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
            brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.indigo,
            brightness: Brightness.dark,
      ),
      home: Frontpage(),
    );
      }
    );
  }

}