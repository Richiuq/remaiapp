import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:remaiapp/OfrecerMaterial.dart';

class RemCamara extends StatefulWidget {
  const RemCamara({super.key});

  @override
  State<RemCamara> createState() => _RemCamaraState();
}

class _RemCamaraState extends State<RemCamara> {
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
      _analyzeImageWithGemini(File(_takenImage!.path));
    } catch (e) {
      print(e);
    }
  }

  Future<void> _analyzeImageWithGemini(File imageFile) async {
    final model = GenerativeModel(
        model: 'gemini-1.5-flash-latest',
        apiKey: 'AIzaSyBBzHy7nTKZEqvPJwcnUcaAzr5IPlZMR-Q');
    final prompt =
        'Analiza la imagen adjunta y extrae la siguiente información para completar un formulario de oferta de materiales de construcción: 1. **Tipo de material:** Identifica el tipo de material específico que se muestra en la imagen (ej., vigas de acero, ladrillos, tuberías, etc.). Si es posible, determina el tipo específico de material (ej., acero estructural, ladrillo cerámico, tubería de PVC). 2. **Cantidad:** Estima la cantidad de material presente en la imagen. Si no es posible determinar una cantidad exacta, proporciona un rango aproximado (ej., 10-15, varios metros, etc.). 3. **Descripción detallada:** Describe el estado del material (nuevo, usado, buen estado, con daños, etc.) y cualquier otra característica relevante visible en la imagen (ej., dimensiones, color, marcas, etc.). **Formato de salida:** Devuelve la información extraída en formato JSON, estructurado de la siguiente manera: { "tipoMaterial": "", "cantidad": "", "descripcion": "",}';
    final imageBytes = await imageFile.readAsBytes();
    final content = [
      Content.multi([
        TextPart(prompt),
        DataPart('image/png', imageBytes),
      ])
    ];

    final response = await model.generateContent(content);
    print(response.text);
    if (response.text != null) {
      setState(() {
        _analysisResult = response.text!
            .replaceAll('```json', '') // Eliminar "```json"
            .replaceAll('```', '')     // Eliminar "```"
            .trim();
        final responseData = jsonDecode(_analysisResult!);
        setState(() {
          tipoMaterial = responseData['tipoMaterial'];
          cantidad = responseData['cantidad'];
          descripcion = responseData['descripcion'];
        });
      });
      //print(response.text);
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

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
      body: Stack(
        children: [
          // Imagen de fondo
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/frame2.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Imagen superpuesta
          Positioned(
            top: 70.0,
            left: 50.0,
            child: Image.asset(
              "assets/frame5.png",
            ),
          ),
          SingleChildScrollView(
            child: Container(
              child: Center(
                child: Column(
                  children: [
                    if (_takenImage == null && _controller == null)
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              height: 120,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                'Enfoca tus materiales para análisis.',
                                style: TextStyle(
                                  fontSize: 16.0,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Divider(
                                    color: Colors.green,
                                    thickness: 1.0,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30.0),
                                  child: Text(
                                    'Carga tus fotos',
                                    style: TextStyle(fontSize: 16.0),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: Colors.green,
                                    thickness: 1.0,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.green,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(
                                    15.0), // Esquinas redondeadas
                              ),
                              child: Column(
                                children: [
                                  const SizedBox(height: 80),
                                  GestureDetector(
                                    onTap: _initializeCamera,
                                    child: Center(
                                      child: Container(
                                        width: 200, // Tamaño del círculo
                                        height: 200,
                                        child: CustomPaint(
                                          painter:
                                              CircleWithDashedLinesPainter(),
                                          child: Center(
                                            child: Icon(
                                              Icons.camera_alt,
                                              size: 50,
                                              color: Colors
                                                  .green, // Color del ícono
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 80),
                                  GestureDetector(
                                    onTap: _pickImage,
                                    child: Container(
                                      width: double.infinity,
                                      height: 56,
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 30),
                                      padding: const EdgeInsets.all(16),
                                      decoration: ShapeDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment(0.00, -1.00),
                                          end: Alignment(0, 1),
                                          colors: [
                                            Color(0xFF6FCA3A),
                                            Color(0xCC59A52C)
                                          ],
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(13),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Agrega tu Foto',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w700,
                                            height: 1.5,
                                            letterSpacing: 0.38,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (_takenImage == null)
                      FutureBuilder<void>(
                        future: _initializeControllerFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return CameraPreview(_controller!);
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else {
                            return Center(child: CircularProgressIndicator());
                          }
                        },
                      )
                    else
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 130,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              'Enfoca tus materiales para análisis.',
                              style: TextStyle(
                                fontSize: 16.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: 20),
                          Container(
                            height: 230,
                            width: 230,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20.0),
                              // Ajusta el radio según tus necesidades
                              child: Image.file(File(_takenImage!.path),
                                  fit: BoxFit.cover),
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _takenImage = null;
                                  });
                                  _initializeCamera();
                                },
                                child: Text('Tomar otra foto'),
                              ),
                              ElevatedButton(
                                onPressed: _pickImage,
                                child: Text('Subir otra foto'),
                              ),
                            ],
                          ),
/*                          SizedBox(height: 5),
                          ElevatedButton(
                            onPressed: () {
                              if (_takenImage != null) {
                                _analyzeImageWithGemini(File(_takenImage!.path));
                              }
                            },
                            child: Text('Enviar para análisis'),
                          ),*/
                          SizedBox(height: 10),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Divider(
                                  color: Colors.green,
                                  thickness: 1.0,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30.0),
                                child: Text(
                                  'Resultados de análisis',
                                  style: TextStyle(fontSize: 16.0),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Colors.green,
                                  thickness: 1.0,
                                ),
                              ),
                            ],
                          ),
                          if (_analysisResult != null)
                            Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                                  padding: const EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.green,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        15.0), // Esquinas redondeadas
                                  ),
                                  child: Text(
                                      'Tipo de Material: $tipoMaterial\nCantidad: $cantidad\nDescripción: $descripcion '),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => OfrecerMaterial(
                                          tipoMaterial:
                                              json.decode(_analysisResult!)[
                                                  'tipoMaterial'],
                                          cantidad: json.decode(
                                              _analysisResult!)['cantidad'],
                                          descripcion: json.decode(
                                              _analysisResult!)['descripcion'],
                                          imagenOferta:
                                              File(_takenImage!.path).path,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    height: 56,
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 60),
                                    padding: const EdgeInsets.all(16),
                                    decoration: ShapeDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment(0.00, -1.00),
                                        end: Alignment(0, 1),
                                        colors: [
                                          Color(0xFF6FCA3A),
                                          Color(0xCC59A52C)
                                        ],
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(13),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Importar',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w700,
                                          height: 1.5,
                                          letterSpacing: 0.38,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 70,
            left: 30,
            child: InkWell(
              onTap: () {
                debugPrint('Icon tapped');
                Navigator.of(context).pop();
              },
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: Color(0xE56FCA3A),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: Color(0xE56FCA3A),
                  ),
                ),
              ),
            ),
          ),
        ],
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

class CircleWithDashedLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Paint paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final Path circlePath = Path()
      ..addOval(
          Rect.fromCircle(center: Offset(radius, radius), radius: radius));
    final Path dashPath = Path();

    final double dashWidth = 8;
    final double dashSpace = 7;
    double distance = 0;

    for (PathMetric pathMetric in circlePath.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(pathMetric.extractPath(distance, distance + dashWidth),
            Offset.zero);
        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
