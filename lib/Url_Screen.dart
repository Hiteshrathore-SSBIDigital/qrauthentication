import 'package:flutter/material.dart';
import 'package:myscan/APIs_Screen.dart';
import 'package:myscan/My_Scan.dart';

class UrlScreen extends StatefulWidget {
  @override
  _UrlScreenState createState() => _UrlScreenState();
}

class _UrlScreenState extends State<UrlScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  final TextEditingController _OldtextEditingController =
      TextEditingController();
  List<Map<String, dynamic>> _urls = [];
  String urlsname = "";
  bool hidetextfield = true;
  bool hidedeletedata = true;

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    Map<String, dynamic>? url = await fetchData();
    if (url != null) {
      setState(() {
        _textEditingController.text = url['url'] ?? '';
        _OldtextEditingController.text = url['url'] ?? '';
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

  Future<void> _saveUrl() async {
    final String url = _textEditingController.text;
    if (url == null || url.isEmpty) {
      showMessageDialog(context, "Please enter a valid URL");
      return;
    }
    if (_OldtextEditingController.text.isEmpty) {
      await DatabaseHelper.insertUrl(url: url);
      showMessageDialog(context, "The base URL set successfully");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => QRScanner()),
      );
    } else {
      // Update URL
      await DatabaseHelper.updateUrl(id: _urls.first['id'], url: url);
      showMessageDialog(context, "The base URL update successfully");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => QRScanner()),
      );
    }
    await fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            'APIs Server',
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Color(0xff022a72),
          iconTheme: IconThemeData(color: Colors.white)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: TextField(
                controller: _textEditingController,
                decoration: InputDecoration(
                  label: Text(
                    'Enter the url',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xff022a72),
                    ),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    'Example : "https://www.example.com" ',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Column(
              children: [
                Visibility(
                  visible: !hidetextfield,
                  child: Expanded(
                    child: TextField(
                        controller: _OldtextEditingController,
                        decoration: InputDecoration()),
                  ),
                )
              ],
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_OldtextEditingController.text == "") {
                    if (_textEditingController.text != "") {
                      _saveUrl();
                    }
                  } else if (_textEditingController.text !=
                      _OldtextEditingController.text) {
                    _saveUrl();
                  } else {
                    print("Something went Wrong Data  !");
                  }
                },
                child: Text('Set Base Url'),
              ),
            ),
            Column(
              children: [
                Visibility(
                  visible: !hidedeletedata,
                  child: ElevatedButton(
                      onPressed: () {
                        DatabaseHelper.deleteAll();
                      },
                      child: Text("Clear")),
                ),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
