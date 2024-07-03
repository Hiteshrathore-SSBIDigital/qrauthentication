import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nehhdc_app/Model_Screen/APIs_Screen.dart';
import 'package:nehhdc_app/Model_Screen/ILogin_Screen.dart';
import 'package:nehhdc_app/Setting_Screen/Directory_Screen.dart';
import 'package:nehhdc_app/Setting_Screen/Setting_Screen.dart';
import 'package:nehhdc_app/Setting_Screen/Static_Verible';
import 'package:nehhdc_app/Welcome_Screen/Login_Screen.dart';

class Splash_Screen extends StatefulWidget {
  const Splash_Screen({Key? key}) : super(key: key);

  @override
  State<Splash_Screen> createState() => _Splash_ScreenState();
}

class _Splash_ScreenState extends State<Splash_Screen> {
  TextEditingController userController = TextEditingController();
  TextEditingController passController = TextEditingController();
  List<Map<String, dynamic>> _urls = [];

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    initializeData();
    initializeUrlData();
  }

  Future<void> initializeData() async {
    try {
      final List<Map<String, dynamic>>? userdata =
          await DatabaseHelper.getUrls();
      if (userdata != null && userdata.isNotEmpty) {
        final Map<String, dynamic> data = userdata.first;
        final String? username = data["username"];
        final String? password = data["password"];
        final String urlset = data["url"];
        if (username != null &&
            username.isNotEmpty &&
            password != null &&
            password.isNotEmpty) {
          staticverible.username = username;
          staticverible.password = password;
          staticverible.tempip = urlset;
          staticverible.temqr = urlset;
          userController.text = staticverible.username;
          passController.text = staticverible.password;
          LoginHandler loginHandler =
              LoginHandler(context, userController, passController);
          loginHandler.login(true, true);
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => Login_Screen(),
            ),
          );
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => Login_Screen(),
          ),
        );
      }
    } catch (e) {
      print("Error : $e");
      logError('$e');
    }
  }

  Future<void> initializeUrlData() async {
    Map<String, dynamic>? url = await fetchData();
    if (url != null) {
      setState(() {
        staticverible.temqr = url['url'] ?? '';
        staticverible.tempip = url['url'] ?? '';
      });
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
    bool bluetoothPermissionGranted = await requestBluetoothPermission();
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
          child: Image.asset("assets/Images/logo.png"),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
