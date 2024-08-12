import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiFunction extends StatefulWidget {
  const GeminiFunction({super.key});

  @override
  State<GeminiFunction> createState() => _GeminiFunctionState();
}

class _GeminiFunctionState extends State<GeminiFunction> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  XFile? _takenImage;
  String? _analysisResult;
  String? tipoMaterial, cantidad, descripcion;

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final firstCamera = cameras.first;

      _controller = CameraController(
        firstCamera,
        ResolutionPreset.high,
      );

      _initializeControllerFuture = _controller?.initialize();
      await _initializeControllerFuture;
      setState(() {});
    } catch (e) {
      print("Error al inicializar la cámara: $e");
    }
  }

  Future<void> _analyzeImageWithGemini(File imageFile) async {
    final model = GenerativeModel(model: 'gemini-1.5-flash-latest', apiKey: 'AIzaSyBBzHy7nTKZEqvPJwcnUcaAzr5IPlZMR-Q');
    final prompt = 'Analiza la imagen adjunta y extrae la siguiente información para completar un formulario de oferta de materiales de construcción: 1. **Tipo de material:** Identifica el tipo de material específico que se muestra en la imagen (ej., vigas de acero, ladrillos, tuberías, etc.). Si es posible, determina el tipo específico de material (ej., acero estructural, ladrillo cerámico, tubería de PVC). 2. **Cantidad:** Estima la cantidad de material presente en la imagen. Si no es posible determinar una cantidad exacta, proporciona un rango aproximado (ej., 10-15 unidades, varios metros, etc.). 3. **Descripción detallada:** Describe el estado del material (nuevo, usado, buen estado, con daños, etc.) y cualquier otra característica relevante visible en la imagen (ej., dimensiones, color, marcas, etc.). 4. **Ubicación:** Si la imagen contiene información sobre la ubicación del material (ej., una dirección o un letrero), extráela. De lo contrario, indica que la ubicación no está disponible en la imagen. **Formato de salida:** Devuelve la información extraída en formato JSON, estructurado de la siguiente manera: { "tipo_material": "", "cantidad": "", "descripcion": "", "direccion": "" }';
    final imageBytes = await imageFile.readAsBytes();
    final content = [
      Content.multi([
        TextPart(prompt),
        DataPart('image/png', imageBytes),
      ])
    ];

    final response = await model.generateContent(content);
    if (response.text != null) {
      setState(() {
        _analysisResult = response.text!;
        final responseData = jsonDecode(_analysisResult!);
        setState(() {
          tipoMaterial = responseData['tipo_material'];
          cantidad = responseData['cantidad'];
          descripcion = responseData['descripcion'];
        });
      });
      //print(response.text);
    }
  }

  void _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller!.takePicture();
      setState(() {
        _takenImage = image;
        _analysisResult = null;
      });
      _controller?.dispose();
      _controller = null;
    } catch (e) {
      print(e);
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _takenImage = XFile(pickedFile.path);
        _analysisResult = null;
      });
      _analyzeImageWithGemini(File(_takenImage!.path));
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gemini Image Analyzer')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_takenImage == null && _controller == null)
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: _initializeCamera,
                      child: Text('Iniciar Cámara'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: Text('Subir Imagen'),
                    ),
                  ],
                )
              else if (_takenImage == null)
                FutureBuilder<void>(
                  future: _initializeControllerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return CameraPreview(_controller!);
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                )
              else
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 400,
                      child: Image.file(File(_takenImage!.path)),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _takenImage = null;
                        });
                        _initializeCamera();
                      },
                      child: Text('Tomar otra foto'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_takenImage != null) {
                          _analyzeImageWithGemini(File(_takenImage!.path));
                        }
                      },
                      child: Text('Enviar para análisis'),
                    ),
                    if (_analysisResult != null)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('Resultado del análisis:\nTipo de Material: $tipoMaterial\nCantidad: $cantidad\nDescripción: $descripcion '),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: _controller == null
          ? null
          : FloatingActionButton(
        onPressed: _takePicture,
        child: Icon(Icons.camera_alt),
      ),
    );
  }
}


/*
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class GeminiFunction extends StatefulWidget {
  const GeminiFunction({super.key});

  @override
  State<GeminiFunction> createState() => _GeminiFunctionState();
}

class _GeminiFunctionState extends State<GeminiFunction> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  XFile? _takenImage;
  String? _analysisResult;

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final firstCamera = cameras.first;

      _controller = CameraController(
        firstCamera,
        ResolutionPreset.high,
      );

      _initializeControllerFuture = _controller?.initialize();
      await _initializeControllerFuture;
      setState(() {});
    } catch (e) {
      print("Error al inicializar la cámara: $e");
    }
  }
  Future<void> _analyzeImageWithGoogleVision(File imageFile) async {
    try {
      final bytes = imageFile.readAsBytesSync();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse(
            //'https://vision.googleapis.com/v1/images:annotate?key=AIzaSyCD0QMk7Dtk8yqzlTmFusRdVivAXqtRcwY'),
            'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=AIzaSyBBzHy7nTKZEqvPJwcnUcaAzr5IPlZMR-Q'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'requests': [
            {
              'image': {
                'content': base64Image,
              },
              'features': [
                {
                  'type': 'OBJECT_LOCALIZATION',
                  'maxResults': 50,
                }
              ],
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        final objects = result['responses'][0]['localizedObjectAnnotations'];

        final Map<String, int> objectCounts = {};

        for (var obj in objects) {
          final name = obj['name'];
          if (objectCounts.containsKey(name)) {
            objectCounts[name] = objectCounts[name]! + 1;
          } else {
            objectCounts[name] = 1;
          }
        }

        final resultString = objectCounts.entries
            .map((entry) => '${entry.key}: ${entry.value}')
            .toList()
            .join(', ');

        setState(() {
          _analysisResult = resultString;
        });
      } else {
        print('Error: ${response.statusCode}');
        print(response.body);
      }
    } catch (e) {
      print('Error al analizar la imagen con Google Vision: $e');
    }
  }

  void _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller!.takePicture();
      setState(() {
        _takenImage = image;
        _analysisResult = null;
      });
      _controller?.dispose();
      _controller = null;
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Vista previa de la cámara')),
      body: Center(
        child: _takenImage == null
            ? _controller == null
            ? ElevatedButton(
          onPressed: _initializeCamera,
          child: Text('Iniciar Cámara'),
        )
            : FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return CameraPreview(_controller!);
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                height: 400,
                child: Image.file(File(_takenImage!.path))),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _takenImage = null;
                });
                _initializeCamera();
              },
              child: Text('Tomar otra foto'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_takenImage != null) {
                  _analyzeImageWithGoogleVision(File(_takenImage!.path));
                }
              },
              child: Text('Enviar para análisis'),
            ),
            if (_analysisResult != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Resultado del análisis: $_analysisResult'),
              ),
          ],
        ),
      ),
      floatingActionButton: _controller == null
          ? null
          : FloatingActionButton(
        onPressed: _takePicture,
        child: Icon(Icons.camera_alt),
      ),
    );
  }
}
*/
