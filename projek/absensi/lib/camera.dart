import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() =>
      _CameraPageState();
}

class _CameraPageState
    extends State<CameraPage> {

  CameraController? controller;
  List<CameraDescription> cameras = [];
  int selectedCamera = 0;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {

    cameras =
        await availableCameras();

    controller =
        CameraController(
      cameras[selectedCamera],
      ResolutionPreset.high,
    );

    await controller!
        .initialize();

    if (!mounted) return;

    setState(() {});
  }
  Future<void> switchCamera() async {

    selectedCamera =
        selectedCamera == 0 ? 1 : 0;

    controller =
        CameraController(
      cameras[selectedCamera],
      ResolutionPreset.high,
    );

    await controller!
        .initialize();

    if (!mounted) return;

    setState(() {});
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null ||
        !controller!
            .value
            .isInitialized) {
      return const Scaffold(
        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Camera"),
        backgroundColor:
            const Color(0xff0d6efd),
        foregroundColor:
            Colors.white,
      ),

      body: Stack(
        children: [

          CameraPreview(controller!),
          
          Positioned(
            top: 20,
            right: 20,

            child: CircleAvatar(
              backgroundColor:
                  Colors.black54,

              child: IconButton(

                onPressed: () async {

                  await switchCamera();
                },

                icon: const Icon(
                  Icons.cameraswitch,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,

            child: Column(
              children: [

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [

                    // GALLERY
                    CircleAvatar(
                      radius: 28,
                      backgroundColor:
                          Colors.white,

                      child: IconButton(
                        icon: const Icon(
                          Icons.photo,
                          color: Colors.black,
                        ),

                        onPressed:
                            () async {

                          final picker =
                              ImagePicker();

                          final picked =
                              await picker.pickImage(
                            source:
                                ImageSource.gallery,
                          );

                          if (picked != null) {

                            if (!mounted) return;

                            Navigator.pop(
                              context,
                              picked.path,
                            );
                          }
                        },
                      ),
                    ),

                    const SizedBox(width: 30),

                    // CAPTURE
                    GestureDetector(

                      onTap: () async {

                        final image =
                            await controller!
                                .takePicture();

                        if (!mounted) return;

                        Navigator.pop(
                          context,
                          image.path,
                        );
                      },

                      child: Container(
                        width: 80,
                        height: 80,
                        decoration:
                            BoxDecoration(
                          color:
                              Colors.white,
                          shape:
                              BoxShape.circle,
                          border:
                              Border.all(
                            color:
                                Colors.grey,
                            width: 4,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}