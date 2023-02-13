import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:siscom_operasional/utils/api.dart';
import 'package:siscom_operasional/utils/appbar_widget.dart';
import 'dart:math' as math;

class FaceRecognitionPhotoPage extends StatelessWidget {
  const FaceRecognitionPhotoPage({super.key});

  final double mirror = math.pi;

  @override
  Widget build(BuildContext context) {
    _deleteImageFromCache();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 2,
        flexibleSpace: AppbarMenu1(
          title: "Foto Data Wajah",
          icon: 1,
          colorTitle: Colors.black,
          onTap: () {
            Get.back();
          },
        ),
      ),
      body: Center(
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(mirror),
          child: CachedNetworkImage(
            imageUrl: "${Api.urlFileRecog}${GetStorage().read('file_face')}",
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                Container(
              alignment: Alignment.center,
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.width,
              child:
                  CircularProgressIndicator(value: downloadProgress.progress),
            ),
            errorWidget: (context, url, error) => Image.asset(
              'assets/avatar_default.png',
              width: 40,
              height: 40,
            ),
            fit: BoxFit.cover,
          ),
        ),
        // child: Image.network(
        //   "${Api.urlFileRecog}${GetStorage().read('file_face')}",
        //   loadingBuilder: (BuildContext context, Widget child,
        //       ImageChunkEvent? loadingProgress) {
        //     print("load data");
        //     if (loadingProgress == null) return child;
        //     return Center(
        //       child: CircularProgressIndicator(
        //         value: loadingProgress.expectedTotalBytes != null
        //             ? loadingProgress.cumulativeBytesLoaded /
        //                 loadingProgress.expectedTotalBytes!
        //             : null,
        //       ),
        //     );
        //   },
        // ),
      ),
    );
  }

  Future _deleteImageFromCache() async {
    String url = "${Api.urlFileRecog}${GetStorage().read('file_face')}";
    await CachedNetworkImage.evictFromCache(url);
  }
}
