import 'dart:convert';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';

import '../data/model/device_model.dart';
class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  late final MobileScannerController controller;
  BarcodeCapture? barcode;
  bool isStarted = true;
  bool dialogOpen = false;
  double zoomFactor = 0;

  final double scanWindowSize = 260.0;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    try {
      final found = await controller.analyzeImage(image.path);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(found != null ? "QR Found" : "No QR Found"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  bool isValidQr(String qrData) {
    return qrData.contains('NIA-45') &&
        ','.allMatches(qrData).length == 4;
  }
  void showAlertDialog(
      String message,
      )
  {
    if (!isValidQr(message)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid QR Code'),
        ),
      );

      controller.start();
      return;
    }
    if (dialogOpen) return;

    dialogOpen = true;

    controller.stop();

    final data =
    message.split(',');

    final device =
    QRDeviceModel(
      deviceId:
      data.length > 0
          ? data[0]
          : '',

      modelId:
      data.length > 1
          ? int.parse(data[1])
          : 45,

      categoryId:
      data.length > 2
          ? int.parse(data[2])
          : 1,

      manufactureDate:
      data.length > 3
          ? data[3]
          : '',
      warrentyMonths: 15,
    );

    showDialog(

      context: context,

      barrierDismissible:
      false,

      builder:
          (_) =>
          AlertDialog(

            title:
            const Text(
              "QR Detected",
            ),

            content:
            Column(

              mainAxisSize:
              MainAxisSize.min,

              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(
                  "Device : ${device.deviceId}",
                ),

                Text(
                  "Model : ${device.modelId}",
                ),

                Text(
                  "Category : ${device.categoryId}",
                ),
              ],
            ),

            actions: [

              TextButton(

                onPressed: () {

                  Navigator.pop(
                    context,
                  );

                  controller.start();

                  dialogOpen =
                  false;
                },

                child:
                const Text(
                  "Scan Again",
                ),
              ),

              TextButton(

                onPressed: () {

                  Navigator.pop(
                    context,
                  );

                  Navigator.pop(
                    context,
                    device,
                  );
                },

                child:
                const Text(
                  "OK",
                ),
              ),
            ],
          ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final scanWindow = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: scanWindowSize,
      height: scanWindowSize,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text("Scan QR Code"),),
      body: Stack(
        children: [
          // 1. Scanner View
          MobileScanner(
            controller: controller,
            fit: BoxFit.cover,
            scanWindow: scanWindow,
            onDetect: (capture) async {
              await AudioPlayer().play(
                AssetSource('sounds/beep.mp3'),
              );
              if (!isStarted || dialogOpen) return;
              barcode = capture;
              final value = capture.barcodes.first.rawValue;

              if (value == null) return;
              showAlertDialog(value);
            },
          ),

          // 2. Blurred Overlay with Clear Window
          Positioned.fill(
            child: ClipPath(
              clipper: ScannerOverlayClipper(scanWindowSize: scanWindowSize),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                ),
              ),
            ),
          ),

          // 3. UI Indicators & Borders
          IgnorePointer(
            child: Stack(
              children: [
                Center(
                  child: Container(
                    width: scanWindowSize,
                    height: scanWindowSize,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green, width: 3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const Positioned(
                  top: 120,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      "Place QR inside scan area",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 4. Bottom Control Panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 160,
              color: Colors.black87,
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Slider(
                    value: zoomFactor,
                    min: 0,
                    max: 1,
                    activeColor: Colors.green,
                    onChanged: (value) {
                      setState(() {
                        zoomFactor = value;
                      });
                      controller.setZoomScale(value);
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        iconSize: 32,
                        color: Colors.white,
                        icon: const Icon(Icons.flash_on),
                        onPressed: () async {
                          await controller.toggleTorch();
                        },
                      ),
                      IconButton(
                        iconSize: 32,
                        color: Colors.white,
                        icon: const Icon(Icons.image),
                        onPressed: pickImage,
                      ),
                      IconButton(
                        iconSize: 32,
                        color: Colors.white,
                        icon: Icon(isStarted ? Icons.stop : Icons.play_arrow),
                        onPressed: () {
                          setState(() {
                            isStarted = !isStarted;
                          });
                          if (isStarted) {
                            controller.start();
                          } else {
                            controller.stop();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScannerOverlayClipper extends CustomClipper<Path> {
  final double scanWindowSize;

  ScannerOverlayClipper({required this.scanWindowSize});

  @override
  Path getClip(Size size) {
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final maskPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(size.width / 2, size.height / 2),
            width: scanWindowSize,
            height: scanWindowSize,
          ),
          const Radius.circular(20),
        ),
      );

    // Subtract the center square from the full-screen rectangle
    return Path.combine(PathOperation.difference, path, maskPath);
  }

  @override
  bool shouldReclip(covariant ScannerOverlayClipper oldClipper) {
    return oldClipper.scanWindowSize != scanWindowSize;
  }
}