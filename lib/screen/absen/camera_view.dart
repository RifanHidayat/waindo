import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:screenshot/screenshot.dart';
import 'package:siscom_operasional/controller/absen_controller.dart';

import 'package:siscom_operasional/main.dart';
import 'package:siscom_operasional/screen/absen/loading_absen.dart';
import 'package:siscom_operasional/utils/constans.dart';
import "package:get/get.dart";
import 'package:siscom_operasional/utils/widget_utils.dart';

enum ScreenMode { liveFeed, gallery }

final AbsenController absenControllre = Get.put(AbsenController());

class CameraView extends StatefulWidget {
  CameraView(
      {Key? key,
      required this.title,
      required this.customPaint,
      this.text,
      required this.onImage,
      this.onScreenModeChanged,
      this.status,
      required this.percentIndicator,
      this.isCompatible = true,
      this.blinkTtotal = 3,
      this.faceCount = 0,
      this.initialDirection = CameraLensDirection.back})
      : super(key: key);

  final String title;
  final double percentIndicator;
  final CustomPaint? customPaint;
  final String? text;
  final Function(InputImage inputImage) onImage;
  final Function(ScreenMode mode)? onScreenModeChanged;
  final CameraLensDirection initialDirection;
  late Future<void> _initializeControllerFuture;
  var status;
  var isCompatible;
  final blinkTtotal;
  var faceCount;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  ScreenMode _mode = ScreenMode.liveFeed;
  CameraController? _controller;
  File? _image;
  String? _path;
  ImagePicker? _imagePicker;
  int _cameraIndex = 0;
  double zoomLevel = 0.0, minZoomLevel = 0.0, maxZoomLevel = 0.0;
  final bool _allowPicker = true;
  bool _changingCameraLens = false;
  final controllerAbsensi = Get.put(AbsenController());
  ScreenshotController screenshotController = ScreenshotController();
  File? imageFile;
  bool isSent = false;
  Future<void>? _initializeControllerFuture;

  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,

      // enableContours: true,
      // enableClassification: true,
    ),
  );

  @override
  void initState() {
    super.initState();

    _imagePicker = ImagePicker();

    if (cameras.any(
      (element) =>
          element.lensDirection == widget.initialDirection &&
          element.sensorOrientation == 90,
    )) {
      _cameraIndex = cameras.indexOf(
        cameras.firstWhere((element) =>
            element.lensDirection == widget.initialDirection &&
            element.sensorOrientation == 90),
      );
    } else {
      for (var i = 0; i < cameras.length; i++) {
        if (cameras[i].lensDirection == widget.initialDirection) {
          _cameraIndex = i;
          break;
        }
      }
    }

    // _initializeControllerFuture = _controller.initialize();
    if (_cameraIndex != -1) {
      try {
        _startLiveFeed();
      } catch (e) {
        print("error " + e.toString());
      }
    } else {
      _mode = ScreenMode.gallery;
    }
  }

  Future takePicture() async {
    await _controller!.stopImageStream();
    if (!_controller!.value.isInitialized) {
      return null;
    }
    if (_controller!.value.isTakingPicture) {
      return null;
    }
    try {
      // await _controller!.setFlashMode(FlashMode.off);
      XFile picture = await _controller!.takePicture();
      Get.back();
      Get.to(LoadingAbsen(
        file: picture.path,
        status: "detection",
        statusAbsen: widget.status,
      ));

      // if (widget.status == "registration") {
      //   Get.back();
      //   controllerAbsensi.facedDetection(
      //       status: "registration",
      //       absenStatus:
      //           widget.status == 'masuk' ? "Absen Masuk" : "Absen Keluar",
      //       img: picture.path,
      //       type: "1");
      // } else {
      //   Get.off(LoadingAbsen(
      //     file: picture.path,
      //   ));
      //   controllerAbsensi.facedDetection(
      //       status: "detection",
      //       absenStatus:
      //           widget.status == 'masuk' ? "Absen Masuk" : "Absen Keluar",
      //       img: picture.path,
      //       type: "1");

      // }
      // Get.back();

      // Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //         builder: (context) => PreviewPage(
      //               picture: picture,
      //             )));
    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return null;
    }
  }

  Future takePicture1() async {
    await _controller!.stopImageStream();
    if (!_controller!.value.isInitialized) {
      return null;
    }
    if (_controller!.value.isTakingPicture) {
      return null;
    }
    try {
      // await _controller!.setFlashMode(FlashMode.off);
      XFile picture1 = await _controller!.takePicture();

      Future.delayed(const Duration(milliseconds: 500), () {});

      XFile picture2 = await _controller!.takePicture();
      final faces1 = await _faceDetector
          .processImage(InputImage.fromFilePath(picture1.path));

      final faces2 = await _faceDetector
          .processImage(InputImage.fromFilePath(picture2.path));
      if (faces1.isEmpty || faces2.isEmpty) {
        UtilsAlert.showToast("Wajah tidak ke deteksi");
        return Get.back();
      } else {
        if (faces1[0].leftEyeOpenProbability == null &&
            faces1[0].rightEyeOpenProbability == null &&
            faces2[0].leftEyeOpenProbability == null &&
            faces2[0].rightEyeOpenProbability == null) {
          Get.back();
        } else {
          double? leftEye1 = faces1[0].leftEyeOpenProbability ?? 0.0;

          double? rightEy1 = faces1[0].rightEyeOpenProbability ?? 0.0;

          double? leftEye2 = faces2[0].leftEyeOpenProbability ?? 0.0;
          double? rightEy2 = faces2[0].rightEyeOpenProbability ?? 0.0;
          print("left eeye 1 ${leftEye1}");
          print("right eye 1 ${rightEy1}");

          print("left eeye 2 ${leftEye2}");
          print("right eye 2 ${rightEy2}");

          num value1 = double.parse(leftEye1.toString()) -
              double.parse(leftEye2.toString()).abs();
          num value2 = double.parse(rightEy1.toString()) -
              (double.parse(leftEye2.toString())).abs();
          print(value1);
          print(value2);
          if (value1.abs() > 0.1 || value2.abs() > 0.1) {
            Get.back();
            print("masuk ini");
            Get.to(LoadingAbsen(
              file: picture1.path,
              status: "detection",
              statusAbsen: widget.status,
            ));
          } else {
            print("masuk sini");
            Get.back();
          }
        }
      }

      // if (widget.status == "registration") {
      //   Get.back();
      //   controllerAbsensi.facedDetection(
      //       status: "registration",
      //       absenStatus:
      //           widget.status == 'masuk' ? "Absen Masuk" : "Absen Keluar",
      //       img: picture.path,
      //       type: "1");
      // } else {
      //   Get.off(LoadingAbsen(
      //     file: picture.path,
      //   ));
      //   controllerAbsensi.facedDetection(
      //       status: "detection",
      //       absenStatus:
      //           widget.status == 'masuk' ? "Absen Masuk" : "Absen Keluar",
      //       img: picture.path,
      //       type: "1");

      // }
      // Get.back();

      // Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //         builder: (context) => PreviewPage(
      //               picture: picture,
      //             )));
    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _stopLiveFeed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _liveFeedBody(),
    );
  }

  Widget _body() {
    Widget body;
    if (_mode == ScreenMode.liveFeed) {
      body = _liveFeedBody();
    } else {
      body = _galleryBody();
    }
    return body;
  }

  Widget _liveFeedBody() {
    if (_controller?.value.isInitialized == false) {
      return Container();
    }

    final size = MediaQuery.of(context).size;

    return Container(
        color: Constanst.colorBlack,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Container(
          alignment: Alignment.center,
          child: Stack(
            children: [
              Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: FutureBuilder<void>(
                    future: _initializeControllerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        // If the Future is complete, display the preview.
                        return CameraPreview(_controller!);
                      } else {
                        // Otherwise, display a loading indicator.
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  )),
              // Positioned(
              //   bottom: 20,
              //   child: Container(
              //     width: MediaQuery.of(context).size.width,
              //     child: Align(
              //       alignment: Alignment.center,
              //       child: InkWell(
              //         onTap: () {
              //           // print("tes");
              //           takePicture();
              //         },
              //         child: Container(
              //           child: Container(
              //             width: 75,
              //             height: 75,
              //             decoration: BoxDecoration(
              //                 color: Colors.white.withOpacity(0.5),
              //                 borderRadius: BorderRadius.circular(50)),
              //             child: Padding(
              //               padding: EdgeInsets.all(5),
              //               child: Container(
              //                 width: 70,
              //                 height: 70,
              //                 decoration: BoxDecoration(
              //                     color: Colors.white,
              //                     borderRadius: BorderRadius.circular(50)),
              //               ),
              //             ),
              //           ),
              //         ),
              //       ),
              //     ),
              //   ),
              // )
            ],
          ),
        ));
  }

  Widget _galleryBody() {
    return ListView(shrinkWrap: true, children: [
      _image != null
          ? SizedBox(
              height: 400,
              width: 400,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Image.file(_image!),
                  if (widget.customPaint != null) widget.customPaint!,
                ],
              ),
            )
          : Icon(
              Icons.image,
              size: 200,
            ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton(
          child: Text('From Gallery'),
          onPressed: () => _getImage(ImageSource.gallery),
        ),
      ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton(
          child: Text('Take a picture'),
          onPressed: () => _getImage(ImageSource.camera),
        ),
      ),
      if (_image != null)
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
              '${_path == null ? '' : 'Image path: $_path'}\n\n${widget.text ?? ''}'),
        ),
    ]);
  }

  Future _getImage(ImageSource source) async {
    setState(() {
      _image = null;
      _path = null;
    });
    final pickedFile = await _imagePicker?.pickImage(source: source);
    if (pickedFile != null) {
      _processPickedFile(pickedFile);
    }
    setState(() {});
  }

  void _switchScreenMode() {
    _image = null;
    if (_mode == ScreenMode.liveFeed) {
      _mode = ScreenMode.gallery;
      _stopLiveFeed();
    } else {
      _mode = ScreenMode.liveFeed;
      _startLiveFeed();
    }
    if (widget.onScreenModeChanged != null) {
      widget.onScreenModeChanged!(_mode);
    }
    setState(() {});
  }

  Future _startLiveFeed() async {
    final camera = cameras[1];
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    _initializeControllerFuture = _controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _controller?.getMinZoomLevel().then((value) {
        zoomLevel = value;
        minZoomLevel = value;
      });
      _controller?.getMaxZoomLevel().then((value) {
        maxZoomLevel = value;
      });
      _controller?.startImageStream(_processCameraImage);

      setState(() {});
    });
  }

  Future _stopLiveFeed() async {
    //  await _controller!.stopImageStream();
    await _controller!.dispose();
  }

  Future _switchLiveCamera() async {
    setState(() => _changingCameraLens = true);
    _cameraIndex = (_cameraIndex + 1) % cameras.length;

    await _stopLiveFeed();
    await _startLiveFeed();
    setState(() => _changingCameraLens = false);
  }

  Future _processPickedFile(XFile? pickedFile) async {
    final path = pickedFile?.path;
    if (path == null) {
      return;
    }
    setState(() {
      _image = File(path);
    });

    _path = path;
    final inputImage = InputImage.fromFilePath(path);
    widget.onImage(inputImage);
  }

  Future _processCameraImage(CameraImage image) async {
    if (int.parse(widget.blinkTtotal.toString()) == 0) {
      takePicture();
    }
    if (widget.faceCount > 5) {
      takePicture1();
    }
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
        Size(image.width.toDouble(), image.height.toDouble());

    final camera = cameras[_cameraIndex];
    final imageRotation =
        InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    if (imageRotation == null) return;

    final inputImageFormat =
        InputImageFormatValue.fromRawValue(image.format.raw);
    if (inputImageFormat == null) return;

    final planeData = image.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    final inputImage =
        InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

    widget.onImage(inputImage);
  }
}





// import 'dart:io';

// import 'package:camera/camera.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:google_mlkit_commons/google_mlkit_commons.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:siscom_operasional/main.dart';



// enum ScreenMode { liveFeed, gallery }

// class CameraView extends StatefulWidget {
//   CameraView(
//       {Key? key,
//       required this.title,
//       required this.customPaint,
//       this.text,
//       required this.onImage,
//       this.onScreenModeChanged,
//       this.initialDirection = CameraLensDirection.back})
//       : super(key: key);

//   final String title;
//   final CustomPaint? customPaint;
//   final String? text;
//   final Function(InputImage inputImage) onImage;
//   final Function(ScreenMode mode)? onScreenModeChanged;
//   final CameraLensDirection initialDirection;

//   @override
//   State<CameraView> createState() => _CameraViewState();
// }

// class _CameraViewState extends State<CameraView> {
//   ScreenMode _mode = ScreenMode.liveFeed;
//   CameraController? _controller;
//   File? _image;
//   String? _path;
//   ImagePicker? _imagePicker;
//   int _cameraIndex = -1;
//   double zoomLevel = 0.0, minZoomLevel = 0.0, maxZoomLevel = 0.0;
//   final bool _allowPicker = true;
//   bool _changingCameraLens = false;

//   @override
//   void initState() {
//     super.initState();

//     _imagePicker = ImagePicker();

//     if (cameras.any(
//       (element) =>
//           element.lensDirection == widget.initialDirection &&
//           element.sensorOrientation == 90,
//     )) {
//       _cameraIndex = cameras.indexOf(
//         cameras.firstWhere((element) =>
//             element.lensDirection == widget.initialDirection &&
//             element.sensorOrientation == 90),
//       );
//     } else {
//       for (var i = 0; i < cameras.length; i++) {
//         if (cameras[i].lensDirection == widget.initialDirection) {
//           _cameraIndex = i;
//           break;
//         }
//       }
//     }

//     if (_cameraIndex != -1) {
//       _startLiveFeed();
//     } else {
//       _mode = ScreenMode.gallery;
//     }
//   }

//   @override
//   void dispose() {
//     _stopLiveFeed();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//         actions: [
//           if (_allowPicker)
//             Padding(
//               padding: EdgeInsets.only(right: 20.0),
//               child: GestureDetector(
//                 onTap: _switchScreenMode,
//                 child: Icon(
//                   _mode == ScreenMode.liveFeed
//                       ? Icons.photo_library_outlined
//                       : (Platform.isIOS
//                           ? Icons.camera_alt_outlined
//                           : Icons.camera),
//                 ),
//               ),
//             ),
//         ],
//       ),
//       body: _body(),
//       floatingActionButton: _floatingActionButton(),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//     );
//   }

//   Widget? _floatingActionButton() {
//     if (_mode == ScreenMode.gallery) return null;
//     if (cameras.length == 1) return null;
//     return SizedBox(
//         height: 70.0,
//         width: 70.0,
//         child: FloatingActionButton(
//           onPressed: _switchLiveCamera,
//           child: Icon(
//             Platform.isIOS
//                 ? Icons.flip_camera_ios_outlined
//                 : Icons.flip_camera_android_outlined,
//             size: 40,
//           ),
//         ));
//   }

//   Widget _body() {
//     Widget body;
//     if (_mode == ScreenMode.liveFeed) {
//       body = _liveFeedBody();
//     } else {
//       body = _galleryBody();
//     }
//     return body;
//   }

//   Widget _liveFeedBody() {
//     if (_controller?.value.isInitialized == false) {
//       return Container();
//     }

//     final size = MediaQuery.of(context).size;
//     // calculate scale depending on screen and camera ratios
//     // this is actually size.aspectRatio / (1 / camera.aspectRatio)
//     // because camera preview size is received as landscape
//     // but we're calculating for portrait orientation
//     var scale = size.aspectRatio * _controller!.value.aspectRatio;

//     // to prevent scaling down, invert the value
//     if (scale < 1) scale = 1 / scale;

//     return Container(
//       color: Colors.black,
//       child: Stack(
//         fit: StackFit.expand,
//         children: <Widget>[
//           Transform.scale(
//             scale: scale,
//             child: Center(
//               child: _changingCameraLens
//                   ? Center(
//                       child: const Text('Changing camera lens'),
//                     )
//                   : CameraPreview(_controller!),
//             ),
//           ),
//           if (widget.customPaint != null) widget.customPaint!,
//           Positioned(
//             bottom: 100,
//             left: 50,
//             right: 50,
//             child: Slider(
//               value: zoomLevel,
//               min: minZoomLevel,
//               max: maxZoomLevel,
//               onChanged: (newSliderValue) {
//                 setState(() {
//                   zoomLevel = newSliderValue;
//                   _controller!.setZoomLevel(zoomLevel);
//                 });
//               },
//               divisions: (maxZoomLevel - 1).toInt() < 1
//                   ? null
//                   : (maxZoomLevel - 1).toInt(),
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   Widget _galleryBody() {
//     return ListView(shrinkWrap: true, children: [
//       _image != null
//           ? SizedBox(
//               height: 400,
//               width: 400,
//               child: Stack(
//                 fit: StackFit.expand,
//                 children: <Widget>[
//                   Image.file(_image!),
//                   if (widget.customPaint != null) widget.customPaint!,
//                 ],
//               ),
//             )
//           : Icon(
//               Icons.image,
//               size: 200,
//             ),
//       Padding(
//         padding: EdgeInsets.symmetric(horizontal: 16),
//         child: ElevatedButton(
//           child: Text('From Gallery'),
//           onPressed: () => _getImage(ImageSource.gallery),
//         ),
//       ),
//       Padding(
//         padding: EdgeInsets.symmetric(horizontal: 16),
//         child: ElevatedButton(
//           child: Text('Take a picture'),
//           onPressed: () => _getImage(ImageSource.camera),
//         ),
//       ),
//       if (_image != null)
//         Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Text(
//               '${_path == null ? '' : 'Image path: $_path'}\n\n${widget.text ?? ''}'),
//         ),
//     ]);
//   }

//   Future _getImage(ImageSource source) async {
//     setState(() {
//       _image = null;
//       _path = null;
//     });
//     final pickedFile = await _imagePicker?.pickImage(source: source);
//     if (pickedFile != null) {
//       _processPickedFile(pickedFile);
//     }
//     setState(() {});
//   }

//   void _switchScreenMode() {
//     _image = null;
//     if (_mode == ScreenMode.liveFeed) {
//       _mode = ScreenMode.gallery;
//       _stopLiveFeed();
//     } else {
//       _mode = ScreenMode.liveFeed;
//       _startLiveFeed();
//     }
//     if (widget.onScreenModeChanged != null) {
//       widget.onScreenModeChanged!(_mode);
//     }
//     setState(() {});
//   }

//   Future _startLiveFeed() async {
//     final camera = cameras[_cameraIndex];
//     _controller = CameraController(
//       camera,
//       ResolutionPreset.high,
//       enableAudio: false,
//     );
//     _controller?.initialize().then((_) {
//       if (!mounted) {
//         return;
//       }
//       _controller?.getMinZoomLevel().then((value) {
//         zoomLevel = value;
//         minZoomLevel = value;
//       });
//       _controller?.getMaxZoomLevel().then((value) {
//         maxZoomLevel = value;
//       });
//       _controller?.startImageStream(_processCameraImage);
//       setState(() {});
//     });
//   }

//   Future _stopLiveFeed() async {
//     await _controller?.stopImageStream();
//     await _controller?.dispose();
//     _controller = null;
//   }

//   Future _switchLiveCamera() async {
//     setState(() => _changingCameraLens = true);
//     _cameraIndex = (_cameraIndex + 1) % cameras.length;

//     await _stopLiveFeed();
//     await _startLiveFeed();
//     setState(() => _changingCameraLens = false);
//   }

//   Future _processPickedFile(XFile? pickedFile) async {
//     final path = pickedFile?.path;
//     if (path == null) {
//       return;
//     }
//     setState(() {
//       _image = File(path);
//     });
//     _path = path;
//     final inputImage = InputImage.fromFilePath(path);
//     widget.onImage(inputImage);
//   }

//   Future _processCameraImage(CameraImage image) async {
//     final WriteBuffer allBytes = WriteBuffer();
//     for (final Plane plane in image.planes) {
//       allBytes.putUint8List(plane.bytes);
//     }
//     final bytes = allBytes.done().buffer.asUint8List();

//     final Size imageSize =
//         Size(image.width.toDouble(), image.height.toDouble());

//     final camera = cameras[_cameraIndex];
//     final imageRotation =
//         InputImageRotationValue.fromRawValue(camera.sensorOrientation);
//     if (imageRotation == null) return;

//     final inputImageFormat =
//         InputImageFormatValue.fromRawValue(image.format.raw);
//     if (inputImageFormat == null) return;

//     final planeData = image.planes.map(
//       (Plane plane) {
//         return InputImagePlaneMetadata(
//           bytesPerRow: plane.bytesPerRow,
//           height: plane.height,
//           width: plane.width,
//         );
//       },
//     ).toList();

//     final inputImageData = InputImageData(
//       size: imageSize,
//       imageRotation: imageRotation,
//       inputImageFormat: inputImageFormat,
//       planeData: planeData,
//     );

//     final inputImage =
//         InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

//     widget.onImage(inputImage);
//   }
// }
