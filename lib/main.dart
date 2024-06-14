import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myscan/Splash_Screen.dart';

void main() {
  runApp(MyScan());
}

class MyScan extends StatelessWidget {
  const MyScan({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Splash_Screen(),
    );
  }
}
