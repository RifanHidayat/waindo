import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

import 'package:siscom_operasional/controller/absen_controller.dart';
import 'package:siscom_operasional/screen/face_detector_pointer.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';

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

      // enableContours: true,
      // enableClassification: true,
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

  bool isBlink1 = false;
  bool isBlink2 = false;

  File? img;
  var isBusyNumber = 0;
  var isCompatible = true;
  var blinkTotal = 1;
  var fileImage = File("").obs;
  var faceCount = 0;

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

  Future<void> processImage(InputImage inputImage) async {
    try {
      if (!_canProcess) return;
      if (_isBusy) return;
      _isBusy = true;
      setState(() {
        _text = '';
      });

      final faces = await _faceDetector.processImage(inputImage);
      if (faces.isEmpty) {
        setState(() {
          faceCount = faceCount + 1;
        });
      } else {
        setState(() {
          faceCount = 0;
        });
      }

      if (inputImage.inputImageData?.size != null &&
          inputImage.inputImageData?.imageRotation != null) {
        for (Face face in faces) {
          // If classification was enabled with FaceDetectorOptions:
          if (face.leftEyeOpenProbability == null ||
              face.rightEyeOpenProbability == null) {
          } else {
            double? rightEye = face.leftEyeOpenProbability ?? 0.0;
            double? leftEye = face.rightEyeOpenProbability ?? 0.0;

            if (rightEye! >= 0.6 && leftEye >= 0.6) {
              setState(() {
                isBlink1 = true;
              });
            } else {
              if (isBlink1 == true) {
                if (rightEye <= 0.3 && leftEye! <= 0.3) {
                  isBlink2 = true;
                } else {
                  isBlink1 = false;
                  isBlink2 = false;
                }
              } else {
                isBlink2 = false;
              }
              //isBlink1 = false;
            }
            if (isBlink1 == true && isBlink2 == true) {
              setState(() {
                blinkTotal = blinkTotal - 1;
                isBlink1 = false;
                isBlink2 = false;
              });
              if (blinkTotal > 0) {
                UtilsAlert.showToast("Kedipan matamu ${blinkTotal}x lagi");
              }
            }
          }
        }
      } else {
        String text = 'Faces found: ${faces.length}\n\n';
        for (final face in faces) {
          text += 'face: ${face.boundingBox}\n\n';
        }
        _text = text;
        // TODO: set _customPaint to draw boundingRect on top of image
        _customPaint = null;
      }
      _isBusy = false;
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      Get.back();
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return img != null
        ? Padding(
            padding: const EdgeInsets.all(20.0),
            child: Image.file(File(img!.path)),
          )
        : CameraView(
            isCompatible: isCompatible,
            percentIndicator: blinkEye,
            blinkTtotal: blinkTotal,
            title: 'Face Detector',
            customPaint: _customPaint,
            status: widget.status,
            faceCount: faceCount,
            text: _text,
            onImage: (inputImage) {
              processImage(inputImage);
              // process(inputImage);
            },
            initialDirection: CameraLensDirection.front,
          );
  }

  Future<void> process(InputImage inputImage) async {
    final List<Face> faces = await _faceDetector.processImage(inputImage);

    for (Face face in faces) {
      final Rect boundingBox = face.boundingBox;
      print("bound ${boundingBox}");

      final double? rotX =
          face.headEulerAngleX; // Head is tilted up and down rotX degrees
      final double? rotY =
          face.headEulerAngleY; // Head is rotated to the right rotY degrees
      final double? rotZ =
          face.headEulerAngleZ; // Head is tilted sideways rotZ degrees

      // If landmark detection was enabled with FaceDetectorOptions (mouth, ears,
      // eyes, cheeks, and nose available):
      final FaceLandmark? leftEar = face.landmarks[FaceLandmarkType.leftEar];
      if (leftEar != null) {
        final Point<int> leftEarPos = leftEar.position;
      }
      final double? leftEye = face.rightEyeOpenProbability;
      print("left eye ${leftEye}");

      // If classification was enabled with FaceDetectorOptions:
      if (face.smilingProbability != null) {
        final double? smileProb = face.smilingProbability;
      }

      // If face tracking was enabled with FaceDetectorOptions:
      if (face.trackingId != null) {
        final int? id = face.trackingId;
      }
    }
  }

  Future<void> takePicture() async {
    final getFoto = await ImagePicker().pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 100,
        maxHeight: 350,
        maxWidth: 350);
    if (getFoto != null) {
      fileImage.value = File(getFoto.path);

      print(getFoto.path);
      process(InputImage.fromFilePath(getFoto.path));
    }

    // Future<void> processImage(InputImage inputImage) async {
    //   print("tts");
    //   if (!_canProcess) {
    //     print("can proses");
    //     return;
    //   }
    //   if (_isBusy) {
    //     return;
    //   }
    //   _isBusy = true;
    //   try {
    //     final List<Face> faces = await _faceDetector.processImage(inputImage);

    //     for (Face face in faces) {
    //       // If classification was enabled with FaceDetectorOptions:
    //       if (face.leftEyeOpenProbability == null ||
    //           face.rightEyeOpenProbability == null) {
    //       } else {
    //         final double? rightEye = face.leftEyeOpenProbability;
    //         final double? leftEye = face.rightEyeOpenProbability;
    //         print(rightEye);

    //         // if (rightEye! <= 0.15 && leftEye! <= 0.15) {
    //         //   if (blinkEye >= 1.0) {
    //         //     setState(() {
    //         //       blinkEye = 1.0;
    //         //     });
    //         //   } else {
    //         //     setState(() {
    //         //       blinkEye += 0.5;
    //         //     });
    //         //   }
    //         // }
    //         // if (blinkEye >= 1.0) {
    //         //   // setImage();
    //         //   _canProcess = false;
    //         //   _faceDetector.close();
    //         // }
    //       }

    //       // If face tracking was enabled with FaceDetectorOptions:
    //       if (face.trackingId != null) {
    //         final int? id = face.trackingId;
    //       }

    //       _isBusy = false;

    //       if (mounted) {}
    //     }
    //   } catch (e) {}
    //   // });
    // }

    // void setImage() async {
    //   if (isSent == false) {
    //     await screenshotController
    //         .capture(delay: const Duration(milliseconds: 1000))
    //         .then((image) async {
    //       if (image != null) {
    //         // Get.back();
    //         final tempDir = await getTemporaryDirectory();
    //         File file = await File('${tempDir.path}/image.jpeg').create();
    //         file.writeAsBytesSync(image);
    //         isSent = true;

    //         setState(() {
    //           img = File(file.path);

    //           Future.delayed(const Duration(milliseconds: 500), () {
    //             // controllerAbsensi.facedDetecxtion(
    //             //     status: "detection",
    //             //     absenStatus: "Absen Masuk",
    //             //     img: File(img!.path),
    //             //     type: "1");
    //           });
    //         });
    //       }
    //     });
    //   }
    // }
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
}
