import 'package:flutter/material.dart';
import 'package:textrepresentation/front/frontpage.dart';

void main() {
  runApp(const DocPulse());
}

class DocPulse extends StatelessWidget{
  const DocPulse({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: Frontpage(),
    );
  }

}