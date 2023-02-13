import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:screenshot/screenshot.dart';
import 'package:siscom_operasional/controller/absen_controller.dart';

import 'package:siscom_operasional/main.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'dart:math' as math;

enum ScreenMode { liveFeed, gallery }

final AbsenController absenControllre = Get.put(AbsenController());

class CameraViewRegister extends StatefulWidget {
  CameraViewRegister(
      {Key? key,
      required this.title,
      required this.customPaint,
      this.text,
      required this.onImage,
      this.onScreenModeChanged,
      this.status,
      required this.percentIndicator,
      this.isCompatible = true,
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

  @override
  State<CameraViewRegister> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraViewRegister> {
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

  void setImage() async {
    // Take the Picture in a try / catch block. If anything goes wrong,
    // catch the error.
    try {
      // if (isSent == false) {
      //   isSent == true;
      //   try {
      //     await _initializeControllerFuture;
      //     final image = await _controller!.takePicture();

      //     if (!mounted) return;
      //     if (widget.status == "registration") {
      //       Get.back();
      //       controllerAbsensi.facedDetection(
      //           status: "registration",
      //           absenStatus:
      //               widget.status == 'masuk' ? "Absen Masuk" : "Absen Keluar",
      //           img: image.path,
      //           type: "1");
      //     } else {
      //       Get.back();
      //       controllerAbsensi.facedDetection(
      //           status: "registration",
      //           absenStatus:
      //               widget.status == 'masuk' ? "Absen Masuk" : "Absen Keluar",
      //           img: image.path,
      //           type: "1");
      //     }
      //   } catch (e) {
      //     // If an error occurs, log the error to the console.
      //     print(e);
      //   }
      // }
    } catch (e) {
      // If an error occurs, log the error to the console.
      print(e);
    }
  }

  Future takePicture() async {
    if (!_controller!.value.isInitialized) {
      return null;
    }
    if (_controller!.value.isTakingPicture) {
      return null;
    }
    try {
      await _controller!.setFlashMode(FlashMode.off);
      XFile picture = await _controller!.takePicture();

      if (widget.status == "registration") {
        Get.back();
        controllerAbsensi.facedDetection(
            status: "registration",
            absenStatus:
                widget.status == 'masuk' ? "Absen Masuk" : "Absen Keluar",
            img: picture.path,
            type: "1");
      } else {
        Get.back();

        controllerAbsensi.facedDetection(
            status: "detection",
            absenStatus:
                widget.status == 'masuk' ? "Absen Masuk" : "Absen Keluar",
            img: picture.path,
            type: "1");
      }
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
    // calculate scale depending on screen and camera ratios
    // this is actually size.aspectRatio / (1 / camera.aspectRatio)
    // because camera preview size is received as landscape
    // but we're calculating for portrait orientation
    var scale = size.aspectRatio * _controller!.value.aspectRatio;

    // to prevent scaling down, invert the value
    if (scale < 1) scale = 1 / scale;

    return Container(
        color: Constanst.colorBlack,
        child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                Container(
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(200),
                    ),
                    child: FutureBuilder<void>(
                      future: _initializeControllerFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          // If the Future is complete, display the preview.
                          return CameraPreview(_controller!);
                          ;
                        } else {
                          // Otherwise, display a loading indicator.
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                      },
                    )),
                Positioned(
                  bottom: 20,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Align(
                      alignment: Alignment.center,
                      child: InkWell(
                        onTap: () {
                          takePicture();
                        },
                        child: Container(
                          child: Container(
                            width: 75,
                            height: 75,
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(50)),
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(50)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            )));
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

      setState(() {});
    });
  }

  Future _stopLiveFeed() async {
    // await _controller!.stopImageStream();
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

  // Future _processCameraImage(CameraImage image) async {
  //   if (widget.percentIndicator >= 1.0) {
  //     await _controller!.stopImageStream();
  //     setImage();
  //   }
  //   final WriteBuffer allBytes = WriteBuffer();
  //   for (final Plane plane in image.planes) {
  //     allBytes.putUint8List(plane.bytes);
  //   }
  //   final bytes = allBytes.done().buffer.asUint8List();

  //   final Size imageSize =
  //       Size(image.width.toDouble(), image.height.toDouble());

  //   final camera = cameras[_cameraIndex];
  //   final imageRotation =
  //       InputImageRotationValue.fromRawValue(camera.sensorOrientation);
  //   if (imageRotation == null) return;

  //   final inputImageFormat =
  //       InputImageFormatValue.fromRawValue(image.format.raw);
  //   if (inputImageFormat == null) return;

  //   final planeData = image.planes.map(
  //     (Plane plane) {
  //       return InputImagePlaneMetadata(
  //         bytesPerRow: plane.bytesPerRow,
  //         height: plane.height,
  //         width: plane.width,
  //       );
  //     },
  //   ).toList();

  //   final inputImageData = InputImageData(
  //     size: imageSize,
  //     imageRotation: imageRotation,
  //     inputImageFormat: inputImageFormat,
  //     planeData: planeData,
  //   );

  //   final inputImage =
  //       InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

  //   widget.onImage(inputImage);
  // }
}
