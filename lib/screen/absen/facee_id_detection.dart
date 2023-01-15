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

class FaceDetectorView extends StatefulWidget {
  FaceDetectorView({this.status});
  final status;
  @override
  State<FaceDetectorView> createState() => _FaceDetectorViewState();
}

class _FaceDetectorViewState extends State<FaceDetectorView> {
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
  var isBusyNumber = 0;
  var isCompatible = true;

  @override
  void dispose() {
    _canProcess = false;
    _faceDetector.close();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("status ${widget.status}");
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
              isCompatible: isCompatible,
              percentIndicator: blinkEye,
              title: 'Face Detector',
              customPaint: _customPaint,
              status: widget.status,
              text: _text,
              onImage: (inputImage) {
                processImage(inputImage);
              },
              initialDirection: CameraLensDirection.front,
            ),
          );
  }

  Future<void> processImage(InputImage inputImage) async {
    if (!_canProcess) {
      print("can proses");
      return;
    }

    if (_isBusy) {
      return;
    }

    _isBusy = true;

    try {
      final List<Face> faces = await _faceDetector.processImage(inputImage);
      setState(() {
        isCompatible = false;
      });
      for (Face face in faces) {
        // If classification was enabled with FaceDetectorOptions:
        if (face.leftEyeOpenProbability == null) {
        } else {
          final double? rightEye = face.leftEyeOpenProbability;
          final double? leftEye = face.rightEyeOpenProbability;

          if (rightEye! <= 0.05) {
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
    } catch (e) {
      print("erro ${e}");
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
  // Future<File> takePicture() async{
  //   Directory root=await getTemporaryDirectory();
  //   String direcotryPath="${root.path}/guided_camra";
  //   await Directory(direcotryPath).create(recursive: true);
  //   String filePath="${direcotryPath}/${DateTime.now()}.jpg";

  //   try{
  //     await cont

  //   }catch(e){

  //   }

  // }
}

// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
// import 'package:percent_indicator/circular_percent_indicator.dart';
// import 'package:siscom_operasional/main.dart';
// import 'package:siscom_operasional/utils/constans.dart';

// /// CameraApp is the Main Application.
// class FaceDetectorPage extends StatefulWidget {
//   /// Default Constructor
//   const FaceDetectorPage({Key? key}) : super(key: key);

//   @override
//   State<FaceDetectorPage> createState() => _FaceDetectorPageState();
// }

// class _FaceDetectorPageState extends State<FaceDetectorPage> {
//   late CameraController controller;

//   final FaceDetector _faceDetector = FaceDetector(
//     options: FaceDetectorOptions(
//       enableContours: true,
//       enableClassification: true,
//     ),
//   );
//   bool _canProcess = true;
//   bool _isBusy = false;
//   CustomPaint? _customPaint;
//   String? _text;
//   CameraController? _controller;


//   @override
//   void dispose() {
//     _canProcess = false;
//     _faceDetector.close();
//     controller.dispose();
//     super.dispose();
//   }

//   @override
//   void initState() {
//     super.initState();
//     controller = CameraController(cameras![1], ResolutionPreset.max);
//     controller.initialize().then((_) {
//       if (!mounted) {
//         return;
//       }
//       setState(() {});
//     }).catchError((Object e) {
//       if (e is CameraException) {
//         switch (e.code) {
//           case 'CameraAccessDenied':
//             // Handle access errors here.
//             break;
//           default:
//             // Handle other errors here.
//             break;
//         }
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!controller.value.isInitialized) {
//       return Container();
//     }
//     return Scaffold(
//       backgroundColor: Constanst.colorBlack,
//       body: Container(
//         width: MediaQuery.of(context).size.width,
//         height: MediaQuery.of(context).size.height,
//         child: Center(
//           child: Stack(
//             children: <Widget>[
//               Center(
//                 child: Container(
//                     width: 300,
//                     height: 300,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(200),
//                     ),
//                     child: ClipRRect(
//                         borderRadius: BorderRadius.circular(200),
//                         child: CameraPreview(controller))),
//               ),

//               // Image.asset('assets/fac-recognition.png'),
//               Container(
//                 width: MediaQuery.of(context).size.width,
//                 height: MediaQuery.of(context).size.height,
//                 child: CircularPercentIndicator(
//                   radius: 150.0,
//                   lineWidth: 10.0,
//                   percent: 0,
//                   progressColor: Constanst.colorPrimary,
//                 ),
//               ),

//               // _buildResults(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> processImage(InputImage inputImage) async {
//     if (!_canProcess) return;
//     if (_isBusy) return;
//     _isBusy = true;
//     setState(() {
//       _text = '';
//     });
//     final faces = await _faceDetector.processImage(inputImage);
//     if (inputImage.inputImageData?.size != null &&
//         inputImage.inputImageData?.imageRotation != null) {
//       // final painter = FaceDetectorPainter(
//       //     faces,
//       //     inputImage.inputImageData!.size,
//       // //     inputImage.inputImageData!.imageRotation);
//       // _customPaint = CustomPaint(painter: painter);
//     } else {
//       String text = 'Faces found: ${faces.length}\n\n';
//       for (final face in faces) {
//         text += 'face: ${face.boundingBox}\n\n';
//       }
//       _text = text;
//       // TODO: set _customPaint to draw boundingRect on top of image
//       _customPaint = null;
//     }
//     _isBusy = false;
//     if (mounted) {
//       setState(() {});
//     }
//   }
// }
