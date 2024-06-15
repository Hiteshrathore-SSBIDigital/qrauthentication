import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:myscan/staticverable';
import 'package:quickalert/quickalert.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Temp {
  final String tempurl;

  Temp({required this.tempurl});
}

String getQrValue(String url) {
  Uri uri = Uri.parse(url);
  staticverible.qrval = uri.queryParameters['ID'].toString();
  return staticverible.qrval ?? '';
}

class TempAPIs {
  final String apiUrl = staticverible.temqr + "/qrapi.aspx/GetData";

  Future<List<Temp>> fetchTemp(
      BuildContext context, String url, VoidCallback onDismiss) async {
    String qrval1 = getQrValue(url);

    try {
      final Map<String, dynamic> requestBody = {"qrvalue": qrval1};
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        if (responseData['d'] is String) {
          final Map<String, dynamic> dataMap = json.decode(responseData['d']);
          String message = dataMap['message'];
          if (message != 'Valid QRValue') {
            Temp temp = Temp(tempurl: message);
            showInvalidQrAlert(context, message, onDismiss);
            return [temp];
          } else {
            Temp temp = Temp(tempurl: message);
            showValidQrAlert(context, message, onDismiss);
            return [temp];
          }
        } else {
          throw Exception('Unexpected data format for "d"');
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        print('Response Body: ${response.body}');
        throw Exception('Failed to load QR Scan');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load QR Scan: $e');
    }
  }
}

void showValidQrAlert(
    BuildContext context, String massage, VoidCallback onDismiss) {
  QuickAlert.show(
    context: context,
    type: QuickAlertType.success,
    title: "QR code Valid Succesfully",
    onConfirmBtnTap: () {
      Navigator.of(context).pop();
      onDismiss();
    },
  );
}

void showInvalidQrAlert(
    BuildContext context, String massage, VoidCallback onDismiss) {
  QuickAlert.show(
    context: context,
    type: QuickAlertType.error,
    title: "Invalid QR code",
    text: "Pleace Scan Valid Qr Code",
    onConfirmBtnTap: () {
      Navigator.of(context).pop();

      onDismiss();
    },
  );
}

class DatabaseHelper {
  static Database? _database;
  static const String tableName = 'MST_Baseurl';

  static Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initializeDatabase();
    return _database!;
  }

  static Future<Database> initializeDatabase() async {
    Directory? externalDirectory = await getAndroidMediaDirectory();
    if (externalDirectory == null) {
      throw Exception('External storage directory not found');
    }

    final String folderPath =
        path.join(externalDirectory.path, 'Qr_Verify', 'Database');
    final Directory folder = Directory(folderPath);
    if (!folder.existsSync()) {
      folder.createSync(recursive: true);
    }

    final String dbPath = path.join(folder.path, 'qr.db');

    return await openDatabase(dbPath, version: 1, onCreate: _createDb);
  }

  static void _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY,
        name TEXT,
        url TEXT
      )
    ''');
  }

  static Future<int> insertUrl({required String url}) async {
    final Database db = await database;
    return await db.insert(tableName, {'url': url});
  }

  static Future<int> updateUrl({required int id, required String url}) async {
    final Database db = await database;
    return await db.update(
      tableName,
      {'url': url},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> deleteAll() async {
    final Database db = await database;
    await db.delete(tableName);
  }

  static Future<List<Map<String, dynamic>>?> getUrls() async {
    final Database db = await database;
    List<Map<String, dynamic>>? urls;

    try {
      urls = await db.query(tableName);
    } catch (e) {
      print('Error retrieving data: $e');
    }

    return urls;
  }
}

Future<Directory?> getAndroidMediaDirectory() async {
  if (Platform.isAndroid) {
    Directory? storageDirectory =
        await path_provider.getExternalStorageDirectory();

    if (storageDirectory != null) {
      String androidMediaPath =
          path.join(storageDirectory.path, 'Android', 'media', 'Qr_Verify');
      Directory androidMediaDirectory = Directory(androidMediaPath);

      if (!await androidMediaDirectory.exists()) {
        try {
          await androidMediaDirectory.create(recursive: true);
          print(
              'Android Media directory created at: ${androidMediaDirectory.path}');
        } catch (e) {
          print("Error creating Android Media directory: $e");
          return null;
        }
      }
      return androidMediaDirectory;
    }
  }
  return null;
}

Future<bool> requestStoragePermission() async {
  var status = await Permission.storage.status;
  if (!status.isGranted) {
    await Permission.storage.request();
  }
  return true;
}

Future<bool> hasAcceptedPermissions() async {
  if (Platform.isAndroid) {
    bool storagePermissionGranted = await requestStoragePermission();
    if (!storagePermissionGranted) {
      return false;
    }
  }

  if (Platform.isIOS) {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.photos,
    ].request();

    return statuses[Permission.photos] == PermissionStatus.granted;
  } else {
    return true;
  }
}
// massgae

void showMessageDialog(BuildContext context, dynamic message) {
  String displayMessage = "";

  if (message is List<String>) {
    displayMessage = message.join("\n");
  } else if (message is String) {
    displayMessage = message;
  } else {
    displayMessage = "Unknown response";
  }

  Fluttertoast.showToast(
    msg: displayMessage,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 0,
    backgroundColor: Colors.white,
    textColor: Colors.black,
  );

  Timer(Duration(seconds: 2), () {
    Fluttertoast.cancel();
  });
}
