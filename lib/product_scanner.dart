import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:appwrite/appwrite.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

class ProductScannerPage extends StatefulWidget {
  const ProductScannerPage({super.key});

  @override
  _ProductScannerPageState createState() => _ProductScannerPageState();
}

class _ProductScannerPageState extends State<ProductScannerPage> {
  late CameraController _cameraController;
  late Future<void> _initializeCamera;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _initializeCamera = _setupCamera();
  }

  Future<void> _setupCamera() async {
    final cameras = await availableCameras();
    final backCamera =
        cameras.first; // Use the first camera (usually the back camera)
    _cameraController = CameraController(
      backCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await _cameraController.initialize();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: FutureBuilder(
              future: _initializeCamera,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(_cameraController);
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          // Bottom Navigation Button
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () async {
                  var projectId = dotenv.env['PROJECT_ID'];
                  var bucketId = dotenv.env['STORAGE_BUCKET'];

                  final client = Client()
                      .setEndpoint('https://cloud.appwrite.io/v1')
                      .setProject(projectId);

                  final storage = Storage(client);

                  final fileId = ID.unique();
                  _cameraController.takePicture().then((XFile file) async {
                    await storage.createFile(
                      bucketId: bucketId!,
                      fileId: fileId,
                      file: InputFile.fromPath(path: file.path),
                    );

                    return file;
                  }).then((file) async {
                    Gemini.instance.prompt(parts: [
                      Part.text(
                          """Identify what type of meal this is, and tell me its name, calories per 100g, and protein, fat, carbohydrate content. In the following format: 
                          Oatmeal, 68, 1.4, 0.9, 12.3,
                      """),
                      Part.bytes(await file.readAsBytes()),
                    ]).then((result) {
                      final mealData = result?.output!
                          .split(',')
                          .map((e) => e.trim())
                          .toList();
                      final mealMap = {
                        'name': mealData?[0],
                        'calories': mealData?[1],
                        'protein': mealData?[2],
                        'fat': mealData?[3],
                        'carbohydrate': mealData?[4],
                      };

                      return mealMap;
                    }).then((meal) async {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user!.uid)
                          .collection('meals')
                          .doc()
                          .set({
                        'name': meal['name'],
                        'calories': meal['calories'],
                        'protein': meal['protein'],
                        'fat': meal['fat'],
                        'carbohydrate': meal['carbohydrate'],
                        'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
                        'image': fileId,
                      });
                    }).then((value) {
                      SnackBar snackBar = SnackBar(
                        content: Text('Image uploaded successfully'),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    });
                  }).catchError((error) {
                    print(error.toString());
                    SnackBar snackBar = SnackBar(
                      content: Text('Error uploading image'),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  });
                },
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(16),
                ),
                child: const Icon(Icons.camera_alt, color: Colors.white),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
