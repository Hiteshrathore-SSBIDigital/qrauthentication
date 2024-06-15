import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:myscan/APIs_Screen.dart';
import 'package:myscan/Url_Screen.dart';
import 'package:myscan/staticverable';
import 'package:qr_scanner_overlay/qr_scanner_overlay.dart';

class QRScanner extends StatefulWidget {
  const QRScanner({Key? key}) : super(key: key);

  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  bool isFlashOn = false;
  bool isFrontCamera = false;
  bool isScanCompleted = false;
  MobileScannerController cameraController = MobileScannerController();
  String responseMessage = '';
  final TempAPIs apiService = TempAPIs();

  void closeScreen() {
    setState(() {
      isScanCompleted = false;
    });
  }

  void clearMethod() {
    setState(() {
      staticverible.qrval = '';
      responseMessage = '';
    });
  }

  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff022a72),
        leading: IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => UrlScreen()));
          },
          color: Colors.white,
        ),
        centerTitle: true,
        title: Text(
          "QR Scanner",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isFlashOn = !isFlashOn;
              });
              cameraController.toggleTorch();
            },
            icon: Icon(
              isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                isFrontCamera = !isFrontCamera;
              });
              cameraController.switchCamera();
            },
            icon: Icon(
              isFrontCamera ? Icons.camera_front : Icons.camera_rear,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () {
              clearMethod();
            },
            icon: Icon(
              Icons.clear,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Stack(
                children: [
                  MobileScanner(
                    controller: cameraController,
                    onDetect: (barcodeCapture) async {
                      if (!isScanCompleted) {
                        setState(() {
                          isScanCompleted = true;
                        });
                        final List<Barcode> barcodes = barcodeCapture.barcodes;
                        final String code = barcodes.isNotEmpty
                            ? barcodes.first.rawValue ?? '---'
                            : '---';

                        try {
                          final tempData = await apiService.fetchTemp(
                              context, code, closeScreen);
                          setState(() {
                            responseMessage = tempData.isNotEmpty
                                ? tempData[0].tempurl
                                : "No data found";
                          });
                        } catch (e) {
                          print("Error fetching data: $e");
                          setState(() {
                            print(e);
                          });
                        }
                      }
                    },
                  ),
                  QRScannerOverlay(
                    overlayColor: Colors.black26,
                    borderColor: Colors.white,
                    borderRadius: 20,
                    borderStrokeWidth: 10,
                    scanAreaWidth: 250,
                    scanAreaHeight: 250,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "|Scan properly to see results|",
                  style: TextStyle(
                    color: Color(0xff022a72),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  responseMessage,
                  style: TextStyle(
                    color: responseMessage == 'Invalid QRValue'
                        ? Colors.red
                        : Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
