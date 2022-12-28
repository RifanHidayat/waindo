import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image/image.dart' as imglib;
import 'package:camera/camera.dart';
import 'package:siscom_operasional/controller/absen_controller.dart';
import 'package:siscom_operasional/model/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quiver/collection.dart';
import 'package:siscom_operasional/screen/absen/absen_masuk_keluar.dart';
import 'package:siscom_operasional/screen/init_screen.dart';
import 'package:siscom_operasional/utils/api.dart';
import 'package:siscom_operasional/utils/app_data.dart';
import 'package:siscom_operasional/utils/constans.dart';
import 'package:siscom_operasional/utils/widget_utils.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:siscom_operasional/model/detector.dart';
import 'package:siscom_operasional/model/utils.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:http/http.dart' as http;

class faceDetectionPage extends StatefulWidget {
  faceDetectionPage({Key? key, required this.status}) : super(key: key);
  var status;

  @override
  State<faceDetectionPage> createState() => _faceDetectionPageState();
}

class _faceDetectionPageState extends State<faceDetectionPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    _start();
  }

  void _start() async {
    interpreter = await loadModel();
    initialCamera();
  }

  @override
  void dispose() async {
    WidgetsBinding.instance!.removeObserver(this);
    if (_camera != null) {
      await _camera!.stopImageStream();
      await Future.delayed(const Duration(milliseconds: 200));
      await _camera!.dispose();
      _camera = null;
    }
    super.dispose();
  }

  var interpreter;
  CameraController? _camera;
  dynamic data = {};
  bool _isDetecting = false;
  double threshold = 1.0;
  dynamic _scanResults;
  String _predRes = '';
  bool isStream = true;
  CameraImage? _cameraimage;
  Directory? tempDir;
  bool _faceFound = false;
  bool _verify = false;
  List? e1;
  bool loading = true;
  var timer = 0;
  var succes = 0.0;
  var failed = 0.0;
  final TextEditingController _name = TextEditingController(text: '');
  var description = 'Pastikan wajah kamu tidak tertutup dan terlihat jelas';

  final AbsenController controller = Get.put(AbsenController());

  void initialCamera() async {
    CameraDescription description =
        await getCamera(CameraLensDirection.front); //camera depan;

    _camera = CameraController(
      description,
      ResolutionPreset.low,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    await _camera!.initialize();
    await Future.delayed(const Duration(milliseconds: 500));
    loading = false;

    var dataUser = AppData.informasiUser;
    var getEmpId = dataUser![0].em_id;
    Map<String, dynamic> body = {"em_id": getEmpId};
    Map<String, String> headers = {
      'Authorization': Api.basicAuth,
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };
    try {
      var response = await http.post(
          Uri.parse('http://kantor.membersis.com:2627/get_face'),
          body: jsonEncode(body),
          headers: headers);

      final d = jsonDecode(response.body);
      data = d['data'];
      print("data" + d.toString());
    } catch (e) {
      print("eeror get data  ${e}");
    }

    await Future.delayed(const Duration(milliseconds: 500));

    _camera!.startImageStream((CameraImage image) async {
      if (_camera != null) {
        if (_isDetecting) return;
        _isDetecting = true;
        dynamic finalResult = Multimap<String, Face>();

        detect(image, getDetectionMethod()).then((dynamic result) async {
          print(_isDetecting.toString());
          if (result.length == 0 || result == null) {
            _faceFound = false;

            _predRes = '';
          } else {
            _faceFound = true;
          }

          String res;
          Face _face;

          imglib.Image convertedImage =
              convertCameraImage(image, CameraLensDirection.front);

          for (_face in result) {
            double x, y, w, h;
            x = (_face.boundingBox.left - 10);
            y = (_face.boundingBox.top - 10);
            w = (_face.boundingBox.width + 10);
            h = (_face.boundingBox.height + 10);
            imglib.Image croppedImage = imglib.copyCrop(
                convertedImage, x.round(), y.round(), w.round(), h.round());
            croppedImage = imglib.copyResizeCropSquare(croppedImage, 112);
            res = recog(croppedImage);

            finalResult.add(res, _face);
          }
          print("facee testing");

          _scanResults = finalResult;
          _isDetecting = false;
          setState(() {});
        }).catchError(
          (_) async {
            _isDetecting = false;
            if (_camera != null) {
              await _camera!.stopImageStream();
              await Future.delayed(const Duration(milliseconds: 400));
              await _camera!.dispose();
              await Future.delayed(const Duration(milliseconds: 400));
              _camera = null;
            }
            Navigator.pop(context);
          },
        );
      }
    });
  }

  String recog(imglib.Image img) {
    List input = imageToByteListFloat32(img, 112, 128, 128);
    input = input.reshape([1, 112, 112, 3]);
    List output = List.filled(1 * 192, null, growable: false).reshape([1, 192]);
    interpreter.run(input, output);
    output = output.reshape([192]);
    e1 = List.from(output);
    return compare(e1!);
  }

  String compare(List currEmb) {
    double minDist = 999;
    double currDist = 0.0;
    _predRes = "Tidak Di kenali";

    for (String label in data.keys) {
      print("data label ${data[label]}");

      var emb = data[label].toString().split(',');

      currDist = euclideanDistance(emb, currEmb);
      if (currDist <= threshold && currDist < minDist) {
        minDist = currDist;
        _predRes = label;
        if (_verify == false) {
          _verify = true;
        }
      }
    }
    if (_predRes.toString().trim().toUpperCase() ==
        "Tidak Di Kenali".toString().trim().toUpperCase()) {
      failed = failed + 0.25;
      succes = 0.0;
    } else {
      if (succes < 1.0) {
        succes = succes + 0.25;
      }
    }
    return _predRes;
  }

  @override
  Widget build(BuildContext context) {
    print(_faceFound);
    if (_faceFound) {
      timer = timer + 1;
      description = 'Sedang memindai wajah kamu... sabar ya';
      if (timer >= 5) {
        movePage();
      }
    } else {
      timer = 0;
      description = 'Fokuskan kemera ke wajah kamu';
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: Builder(builder: (context) {
        if ((_camera == null || !_camera!.value.isInitialized) || loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return Container(
          color: Colors.black,
          child: _camera == null
              ? const Center(child: SizedBox())
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Text(
                        description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w700),
                      ),
                    ),

                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: Center(
                        child: Stack(
                          children: <Widget>[
                            Center(
                              child: Container(
                                  width: 300,
                                  height: 300,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(200),
                                  ),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(200),
                                      child: CameraPreview(_camera!))),
                            ),

                            // Image.asset('assets/fac-recognition.png'),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * 0.8,
                              child: CircularPercentIndicator(
                                radius: 150.0,
                                lineWidth: 10.0,
                                percent: succes,
                                progressColor: Constanst.colorPrimary,
                              ),
                            ),

                            // _buildResults(),
                          ],
                        ),
                      ),
                    ),
                    // Container(
                    //   decoration: BoxDecoration(
                    //       color: HexColor('#E9F5FE'),
                    //       borderRadius: BorderRadius.circular(8),
                    //       border: Border.all(
                    //         width: 1,
                    //         color: HexColor('#2F80ED'),
                    //       )),
                    //   padding: EdgeInsets.only(
                    //       top: 5, bottom: 5, left: 10, right: 10),
                    //   child: Row(
                    //     children: [
                    //       Expanded(
                    //         flex: 5,
                    //         child: Icon(
                    //           Icons.info_outline,
                    //           color: HexColor('#2F80ED'),
                    //         ),
                    //       ),
                    //       SizedBox(
                    //         width: 15,
                    //       ),
                    //       Expanded(
                    //         flex: 60,
                    //         child: Text(
                    //           description,
                    //           textAlign: TextAlign.left,
                    //           style: TextStyle(fontSize: 12),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
        );
      }),
    );
  }

  Widget _buildResults() {
    Center noResultsText = const Center(
        child: Text('Mohon Tunggu ..',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: Colors.white)));
    if (_scanResults == null ||
        _camera == null ||
        !_camera!.value.isInitialized) {
      return noResultsText;
    }
    CustomPainter painter;

    final Size imageSize = Size(
      _camera!.value.previewSize!.height,
      _camera!.value.previewSize!.width,
    );
    painter = FaceDetectorPainter(imageSize, _scanResults);
    return CustomPaint(
      painter: painter,
    );
  }

  void movePage() async {
    print("Move Page sucess $succes");

    if (_camera != null) {
      if (succes >= 0.80) {
        await _camera!.stopImageStream();

        await Future.delayed(const Duration(milliseconds: 400));
        UtilsAlert.showLoadingIndicator(Get.context!);
        await Future.delayed(const Duration(milliseconds: 1000));
        if (widget.status == "masuk") {
          Get.offAll(AbsenMasukKeluar(
            type: 1,
            status: "Absen Masuk",
          ));
        } else {
          Get.offAll(AbsenMasukKeluar(
            type: 2,
            status: "Absen Keluar",
          ));
        }
      }
    }
  }
}
