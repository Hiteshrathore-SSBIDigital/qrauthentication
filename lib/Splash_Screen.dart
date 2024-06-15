import 'dart:async';
import 'package:flutter/material.dart';
import 'package:myscan/APIs_Screen.dart';
import 'package:myscan/My_Scan.dart';
import 'package:myscan/Url_Screen.dart';
import 'package:myscan/staticverable';

class Splash_Screen extends StatefulWidget {
  @override
  _Splash_ScreenState createState() => _Splash_ScreenState();
}

class _Splash_ScreenState extends State<Splash_Screen> {
  List<Map<String, dynamic>> _urls = [];
  @override
  void initState() {
    super.initState();
    initializeData();
    _requestPermissions();
  }

  Future<void> initializeData() async {
    Map<String, dynamic>? url = await fetchData();
    if (url != null) {
      setState(() {
        staticverible.temqr = url['url'] ?? '';
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => QRScanner()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UrlScreen()),
      );
    }
  }

  Future<Map<String, dynamic>?> fetchData() async {
    List<Map<String, dynamic>>? urls = await DatabaseHelper.getUrls();
    setState(() {
      _urls = urls ?? [];
    });
    return _urls.isNotEmpty ? _urls.first : null;
  }

  Future<void> _requestPermissions() async {
    bool bluetoothPermissionGranted = await requestStoragePermission();
    if (!bluetoothPermissionGranted) {
      print("Bluetooth permissions not granted");
    }

    bool allPermissionsAccepted = await hasAcceptedPermissions();
    if (!allPermissionsAccepted) {
      print("Some permissions not granted");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height / 2,
          width: MediaQuery.of(context).size.width / 2,
          child: Image.asset("assets/Icon/Company.png"),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
