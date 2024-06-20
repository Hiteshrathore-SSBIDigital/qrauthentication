import 'package:flutter/material.dart';
import 'package:nehhdc_app/Model_Screen/APIs_Screen.dart';
import 'package:nehhdc_app/Setting_Screen/Setting_Screen.dart';
import 'package:nehhdc_app/Setting_Screen/Static_Verible';

class First_Login extends StatefulWidget {
  @override
  _First_LoginState createState() => _First_LoginState();
}

class _First_LoginState extends State<First_Login> {
  final TextEditingController _Newpasscontroller = TextEditingController();
  final TextEditingController _confirmpasscontroller = TextEditingController();
  bool ishidepassword = true;
  String responseMessage = '';
  final LoginAPIs apiservice = LoginAPIs();
  bool _Newpassvalidate = false;
  bool _Confirmpassvalidate = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  String errorMessage = '';
  String confimerrorMessage = '';
  String message = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("Update Password",
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        backgroundColor: Color(ColorVal),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 80,
              decoration: BoxDecoration(
                  color: Color(0xffd3e8ff),
                  border: Border.all(width: 0),
                  borderRadius: BorderRadius.circular(5)),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome to ${staticverible.fistname + ' ' + staticverible.lastname}",
                      style: TextStyle(fontSize: 13),
                    ),
                    Text(
                      "To enhance the security of your account, please take",
                      style: TextStyle(fontSize: 13),
                    ),
                    Text(
                      "a moment to set a new password.",
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              controller: _Newpasscontroller,
              style: TextStyle(fontSize: 12),
              obscureText: _obscureNewPassword,
              onChanged: (value) {
                _validatepassword1();
              },
              decoration: InputDecoration(
                labelText: "New Password",
                labelStyle:
                    TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                errorText: errorMessage.isNotEmpty ? errorMessage : null,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNewPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: _toggleNewPasswordVisibility,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            TextField(
              controller: _confirmpasscontroller,
              style: TextStyle(fontSize: 12),
              obscureText: _obscureConfirmPassword,
              onChanged: (value) {
                _validatepassword();
              },
              decoration: InputDecoration(
                labelText: "Confirm Password",
                labelStyle:
                    TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                errorText:
                    confimerrorMessage.isNotEmpty ? confimerrorMessage : null,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: _toggleConfirmPasswordVisibility,
                ),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Center(
              child: Column(
                children: [
                  InkWell(
                    child: Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width / 2.5,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Color(ColorVal),
                      ),
                      child: Center(
                        child: Text(
                          "Reset Password",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                    onTap: () async {
                      setState(() {
                        _Newpassvalidate = _Newpasscontroller.text.isEmpty;
                        _Confirmpassvalidate =
                            _confirmpasscontroller.text.isEmpty ||
                                _Newpasscontroller.text !=
                                    _confirmpasscontroller.text;
                      });

                      if (_Newpassvalidate || _Confirmpassvalidate) {
                        return;
                      }
                      fetchFirstLogin(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  void _toggleNewPasswordVisibility() {
    setState(() {
      _obscureNewPassword = !_obscureNewPassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  void _validatepassword() {
    setState(() {
      if (_Newpasscontroller.text != _confirmpasscontroller.text) {
        confimerrorMessage = "Passwords do not match";
      } else {
        confimerrorMessage = '';
      }
    });
  }

  void _validatepassword1() {
    setState(() {
      String password = _Newpasscontroller.text;
      bool hasUppercase = password.contains(new RegExp(r'[A-Z]'));
      bool hasLowercase = password.contains(new RegExp(r'[a-z]'));
      bool hasDigits = password.contains(new RegExp(r'[0-9]'));
      bool hasSpecialCharacters =
          password.contains(new RegExp(r'[@_!#$%^&*()<>?/\|}{~:]'));

      if (password.length < 8 ||
          !hasUppercase ||
          !hasLowercase ||
          !hasDigits ||
          !hasSpecialCharacters) {
        errorMessage =
            '''The password should be exactly 8 characters long and contain at least:
- 1 number
- 1 uppercase letter
- 1 lowercase letter
- 1 special character (supporting only '@' and '_').''';
      } else {
        errorMessage = '';
      }
    });
  }

  void fetchFirstLogin(BuildContext context) async {
    try {
      plaesewaitmassage(context);
      ResetPassAPIs resetPasswordAPI = ResetPassAPIs();
      try {
        await resetPasswordAPI.updatePassword(
            context, staticverible.username, _Newpasscontroller.text);
      } catch (e) {
        setState(() {
          Navigator.of(context).pop();
        });
      }
    } catch (e) {
      setState(() {
        message = 'Error: $e';
        Navigator.of(context).pop();
      });
    }
  }
}
