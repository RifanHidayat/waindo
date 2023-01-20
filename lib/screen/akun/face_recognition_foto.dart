import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:siscom_operasional/utils/api.dart';
import 'package:siscom_operasional/utils/appbar_widget.dart';

class FaceRecognitionPhotoPage extends StatelessWidget {
  const FaceRecognitionPhotoPage({super.key});

  @override
  Widget build(BuildContext context) {
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
        child: Image.network(
          "${Api.urlFileRecog}${GetStorage().read('file_face')}",
          loadingBuilder: (BuildContext context, Widget child,
              ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
        ),
      ),
    );
  }
}
