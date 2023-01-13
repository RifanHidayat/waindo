import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

import 'package:siscom_operasional/controller/absen_controller.dart';

import 'camera_view.dart';

import 'package:get/get.dart';

class FaceidRegistration extends StatefulWidget {
  FaceidRegistration({this.status});
  final status;
  @override
  State<FaceidRegistration> createState() => _FaceidRegistrationState();
}

class _FaceidRegistrationState extends State<FaceidRegistration> {
  final controllerAbsensi = Get.put(AbsenController());
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
    ),
  );
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  var blinkEye = 0.0;
  CameraController? _controller;
  XFile? image;
  var isSent = false;
  ScreenshotController screenshotController = ScreenshotController();

  File? img;

  @override
  void dispose() {
    _canProcess = false;
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return img != null
        ? Padding(
            padding: const EdgeInsets.all(20.0),
            child: Image.file(File(img!.path)),
          )
        : Screenshot(
            controller: screenshotController,
            child: CameraView(
              percentIndicator: blinkEye,
              title: 'Face Detector',
              customPaint: _customPaint,
              status: widget.status,
              text: _text,
              onImage: (inputImage) {
                print(inputImage.filePath);
                processImage(inputImage);
              },
              initialDirection: CameraLensDirection.front,
            ),
          );
  }

  Future<void> processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;

    final List<Face> faces = await _faceDetector.processImage(inputImage);
    if (faces.isNotEmpty) {
      _isBusy = false;
    }
    for (Face face in faces) {
      // If classification was enabled with FaceDetectorOptions:
      if (face.leftEyeOpenProbability == null) {
      } else {
        final double? rightEye = face.leftEyeOpenProbability;
        final double? leftEye = face.rightEyeOpenProbability;
        print("left ${leftEye}");
        print("right  ${rightEye}");
        if (rightEye! <= 0.1) {
          if (blinkEye >= 1.0) {
            setState(() {
              blinkEye = 1.0;
            });
          } else {
            setState(() {
              blinkEye += 0.5;
            });
          }
        }
        if (blinkEye >= 1.0) {
          // setImage();

          _canProcess = false;
          _faceDetector.close();
        }
      }

      // If face tracking was enabled with FaceDetectorOptions:
      if (face.trackingId != null) {
        final int? id = face.trackingId;
      }

      _isBusy = false;
      if (mounted) {}
    }
  }

  void setImage() async {
    if (isSent == false) {
      await screenshotController
          .capture(delay: const Duration(milliseconds: 1000))
          .then((image) async {
        if (image != null) {
          // Get.back();
          final tempDir = await getTemporaryDirectory();
          File file = await File('${tempDir.path}/image.jpeg').create();
          file.writeAsBytesSync(image);
          isSent = true;

          setState(() {
            img = File(file.path);

            Future.delayed(const Duration(milliseconds: 500), () {
              // controllerAbsensi.facedDetecxtion(
              //     status: "detection",
              //     absenStatus: "Absen Masuk",
              //     img: File(img!.path),
              //     type: "1");
            });
          });
        }
      });
    }
  }
}
