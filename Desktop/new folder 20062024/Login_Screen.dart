import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:nehhdc_app/Model_Screen/APIs_Screen.dart';
import 'package:nehhdc_app/Model_Screen/ILogin_Screen.dart';
import 'package:nehhdc_app/Model_Screen/Url_Screen.dart';
import 'package:nehhdc_app/Screen/Bottom_Screen.dart';
import 'package:nehhdc_app/Setting_Screen/Setting_Screen.dart';
import 'package:nehhdc_app/Setting_Screen/Static_Verible';
import 'package:nehhdc_app/Welcome_Screen/NewRegistration.dart';
import 'package:nehhdc_app/Welcome_Screen/Registered_Screen.dart';

class Login_Screen extends StatefulWidget {
  @override
  State<Login_Screen> createState() => _Login_ScreenState();
}

class _Login_ScreenState extends State<Login_Screen> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _tempurlController = TextEditingController();
  final TextEditingController _usercontroller = TextEditingController();
  final TextEditingController _passcontroller = TextEditingController();
  late TextEditingController captchaController;
  bool Captchavalidate = false;
  String captchaText = '';
  bool ishidepassword = true;
  String responseMessage = '';
  bool _uservalidate = false;
  bool _passvalidate = false;
  String errorMessage = '';
  bool rememberPassword = false;

  List<Map<String, dynamic>> _urls = [];

  void dispose() {
    _usercontroller.dispose();
    _passcontroller.dispose();
    super.dispose();
  }

  void initState() {
    super.initState();
    initializeData();
    _generateCaptcha();
    captchaController = TextEditingController();
    responseMessage = '';
  }

  void _generateCaptcha() {
    captchaText = _generateRandomText();
    setState(() {});
  }

  String _generateRandomText() {
    const characters =
        'ABCDEFGHIJKMNPQRSTUVWXYZabcdefghjklmnpqrstuvwxyz123456789';
    Random random = Random();
    String captchaText = '';
    for (int i = 0; i < 6; i++) {
      captchaText += characters[random.nextInt(characters.length)];
    }
    return captchaText;
  }

  Future<void> initializeData() async {
    Map<String, dynamic>? url = await fetchData();
    if (url != null) {
      setState(() {
        _urlController.text = url['url'] ?? '';
        _tempurlController.text = url['url'] ?? '';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: ConstrainedBox(
          constraints: BoxConstraints(),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Stack(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(color: Color(ColorVal)),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50, left: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        IconButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          UrlScreen()));
                            },
                            icon: Icon(
                              Icons.settings,
                              color: Colors.white,
                            ))
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20)),
                      color: Colors.white,
                    ),
                    height: MediaQuery.of(context).size.height / 0.90,
                    width: double.infinity,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 150, left: 20, right: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "User Name",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Calaby',
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: _uservalidate ? 35 : 35,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(width: 0, color: Colors.grey)),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5, bottom: 15),
                          child: TextField(
                            decoration:
                                InputDecoration(border: InputBorder.none),
                            textAlign: TextAlign.left,
                            controller: _usercontroller,
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      if (_uservalidate)
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            'Please enter user name',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Password",
                        style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold,
                          fontFamily: 'Calaby', // Specify the font family here
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: _passvalidate ? 35 : 35,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(width: 0, color: Colors.grey)),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5, bottom: 15),
                          child: TextField(
                            obscureText: ishidepassword,
                            decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    ishidepassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: _togglepasswordview,
                                ),
                                border: InputBorder.none),
                            textAlign: TextAlign.left, // Align text to the left
                            controller: _passcontroller,
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      if (_passvalidate)
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            'Please enter password',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontFamily:
                                  'Calaby', // Specify the font family here
                            ),
                          ),
                        ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Captcha",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                      border: Border.all(width: 0)),
                                  child: CustomPaint(
                                      size: Size(200, 100),
                                      painter: CaptchaPainter(
                                        captchaText,
                                      )),
                                ),
                                InkWell(
                                  child: Container(
                                      height: 50,
                                      width: 50,
                                      child: Icon(Icons.refresh)),
                                  onTap: () {
                                    _generateCaptcha();
                                  },
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Enter Captcha",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            height: Captchavalidate ? 35 : 35,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                border:
                                    Border.all(width: 0, color: Colors.grey)),
                            child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 5, bottom: 15),
                                child: TextField(
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                  textAlign: TextAlign.left,
                                  controller: captchaController,
                                  style: TextStyle(fontSize: 12),
                                  onChanged: (value) {
                                    setState(() {});
                                  },
                                )),
                          ),
                          if (Captchavalidate && captchaController.text.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                'Please enter Captcha',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          if (!Captchavalidate)
                            Padding(
                              padding: const EdgeInsets.only(left: 10, top: 5),
                              child: Visibility(
                                visible: !Captchavalidate,
                                child: Text(
                                  errorMessage,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          Container(
                              child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: rememberPassword,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          rememberPassword = value!;
                                        });
                                      },
                                      activeColor: Color(ColorVal),
                                    ),
                                    Text(
                                      'Remember me',
                                      style: TextStyle(
                                        color: Colors.black45,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            Registered_Screen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Forgot Password ?",
                                    style: TextStyle(fontSize: 14),
                                  ))
                            ],
                          )),
                        ],
                      ),
                      Column(
                        children: [
                          InkWell(
                            child: Container(
                              height: 40,
                              width: MediaQuery.of(context).size.width / 1,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Color(ColorVal)),
                              child: Center(
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                            onTap: () async {
                              setState(() {
                                _uservalidate = _usercontroller.text.isEmpty;
                                _passvalidate = _passcontroller.text.isEmpty;
                                Captchavalidate =
                                    captchaController.text.isEmpty;
                              });

                              if (_uservalidate ||
                                  _passvalidate ||
                                  Captchavalidate) {
                                return;
                              }
                              if (captchaController.text == captchaText) {
                                setState(() {
                                  errorMessage = '';
                                  _generateCaptcha();
                                  print("CAPTCHA verification successful");
                                });
                              } else {
                                setState(() {
                                  errorMessage = 'Invalid Captcha';
                                  captchaController.clear();
                                  print("Invalid Captcha");
                                });
                                return;
                              }

                              if (_urlController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Please set the URL"),
                                    duration: Duration(seconds: 3),
                                    action: SnackBarAction(
                                      label: 'OK',
                                      onPressed: () {},
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              } else if (_urlController.text !=
                                  _tempurlController.text) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Please check URL"),
                                    duration: Duration(seconds: 3),
                                    action: SnackBarAction(
                                      label: 'OK',
                                      onPressed: () {},
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              LoginHandler loginHandler = LoginHandler(
                                  context, _usercontroller, _passcontroller);
                              String message = await loginHandler.login(
                                  false, rememberPassword);
                              setState(() {
                                responseMessage = message;
                              });
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                New_Registration()));
                                  },
                                  child: Text(
                                    "Need an account ? SIGN UP",
                                    style: TextStyle(
                                        fontSize: 14, color: Color(ColorVal)),
                                  )),
                            ],
                          ),
                          Column(
                            children: [
                              Center(
                                  child: Text(
                                responseMessage,
                                style: TextStyle(
                                  color: responseMessage.isNotEmpty
                                      ? Colors.red
                                      : Colors.black,
                                ),
                              )),
                            ],
                          ),
                          TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            Bottom_Screen()));
                              },
                              child: Text("Skip"))
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomSheet: BottomSheetWidget());
  }

  void _togglepasswordview() {
    if (ishidepassword == true) {
      ishidepassword = false;
    } else {
      ishidepassword = true;
    }
    setState(() {});
  }
}

class CaptchaPainter extends CustomPainter {
  final String text;

  CaptchaPainter(this.text);

  @override
  void paint(Canvas canvas, Size size) {
    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: 24,
      fontWeight: FontWeight.bold,
    );
    final textSpan = TextSpan(
      text: text,
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    final xPos = (size.width - textPainter.width) / 2;
    final yPos = (size.height - textPainter.height) / 2;
    textPainter.paint(canvas, Offset(xPos, yPos));

    final random = Random();
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2;

    // Draw random lines to obfuscate text
    for (int i = 0; i < 5; i++) {
      canvas.drawLine(
        Offset(random.nextDouble() * size.width,
            random.nextDouble() * size.height),
        Offset(random.nextDouble() * size.width,
            random.nextDouble() * size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class BottomSheetWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String message1 = "";
    Color textColor = Colors.black;

    if (staticverible.temqr == '' || staticverible.temqr.isEmpty) {
      message1 = "Current server is null";
      textColor = Colors.red;
    } else {
      message1 = "Current server is ${staticverible.temqr}";
      textColor = Color(ColorVal);
    }

    return Container(
      height: 60,
      decoration: BoxDecoration(color: Colors.white),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$version",
            style: TextStyle(color: textColor),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              "$message1",
              style: TextStyle(color: textColor),
            ),
          )
        ],
      ),
    );
  }
}
