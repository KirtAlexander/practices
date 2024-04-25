import 'dart:io';

import 'package:app_test/response.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:palette_generator/palette_generator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera and Image Picker',
      home: const MyHomePage(title: 'App Test'),
    );
  }
}



class _MyHomePageState extends State<MyHomePage> {
  Image? _selectedImage;
  late CameraController _cameraController;
  bool _hasTakenPhoto = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
  try {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _cameraController = CameraController(firstCamera, ResolutionPreset.medium);
    await _cameraController.initialize();
  } catch (e) {
    print('Error al inicializar la cámara: $e');
  }
}


  void _disposeCamera() {
    _cameraController.dispose();
  }

  void _takePicture() async {
    try {
      final XFile photo = await _cameraController.takePicture();
      if (photo != null) {
        setState(() {
          _selectedImage = Image.file(File(photo.path));
          _hasTakenPhoto = true;
        });
      }
    } catch (e) {
      print('Error al tomar la foto: $e');
    }
  }

  void _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = Image.file(File(image.path));
        _hasTakenPhoto = true;
      });
    }
  }

  Future<Color?> _analyzeColor() async {
    if (_selectedImage != null) {
      final PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(_selectedImage!.image);
      final dominantColor = paletteGenerator.dominantColor?.color;
      return dominantColor;
    }
    return null;
  }

  @override
  void dispose() {
    _disposeCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
              child: _hasTakenPhoto
                  ? Column(
                      children: [
                        Container(
                          width: 200,
                          height: 200,
                          child: _selectedImage,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ColorInfoPage(_analyzeColor()),
                                  ),
                                );
                              },
                              child: Text('Confirmar Carga'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Realizar acción de rehacer la foto
                                setState(() {
                                  _hasTakenPhoto = false;
                                  _selectedImage = null;
                                });
                              },
                              child: Text('Rehacer Foto'),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Container(
                      height: 300,
                      width: 300,
                      child: FractionallySizedBox(
                        widthFactor:
                            1,
                            heightFactor: 0.5,
                        child: CameraPreview(
                            _cameraController)
                      ))),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: _hasTakenPhoto ? null : _takePicture,
                child: Text('Tomar Foto'),
              ),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Adjuntar Foto'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
