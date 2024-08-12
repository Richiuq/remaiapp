import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ImageAnalyzerWidget extends StatefulWidget {
  @override
  _ImageAnalyzerWidgetState createState() => _ImageAnalyzerWidgetState();
}

class _ImageAnalyzerWidgetState extends State<ImageAnalyzerWidget> {
  File? _image;
  String _analysisResult = 'Press the button to analyze an image';

  String tipo_material = '';
  String cantidad = '';
  String descripcion = '';
  String direccion = '';

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      _analyzeImageWithGemini(_image!);
    }
  }

  Future<void> _analyzeImageWithGemini(File imageFile) async {
    final model = GenerativeModel(model: 'gemini-1.5-flash-latest', apiKey: 'AIzaSyBBzHy7nTKZEqvPJwcnUcaAzr5IPlZMR-Q');
    final prompt = 'Analiza la imagen adjunta y extrae la siguiente información para completar un formulario de oferta de materiales de construcción: 1. **Tipo de material:** Identifica el tipo de material específico que se muestra en la imagen (ej., vigas de acero, ladrillos, tuberías, etc.). Si es posible, determina el tipo específico de material (ej., acero estructural, ladrillo cerámico, tubería de PVC). 2. **Cantidad:** Estima la cantidad de material presente en la imagen. Si no es posible determinar una cantidad exacta, proporciona un rango aproximado (ej., 10-15 unidades, varios metros, etc.). 3. **Descripción detallada:** Describe el estado del material (nuevo, usado, buen estado, con daños, etc.) y cualquier otra característica relevante visible en la imagen (ej., dimensiones, color, marcas, etc.). 4. **Ubicación:** Si la imagen contiene información sobre la ubicación del material (ej., una dirección o un letrero), extráela. De lo contrario, indica que la ubicación no está disponible en la imagen. **Formato de salida:** Devuelve la información extraída en formato JSON, estructurado de la siguiente manera: ```json { "tipo_material": "", "cantidad": "", "descripcion": "", "direccion": "" }';
    final imageBytes = await imageFile.readAsBytes();
    final content = [
      Content.multi([
        TextPart(prompt),
        DataPart('image/png', imageBytes),
      ])
    ];

    final response = await model.generateContent(content);
    if(response.text != null){
      setState(() {
        _analysisResult = response.text!;
      });
      print(response.text);

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gemini Image Analyzer'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _image == null ? Text('No image selected.') : Image.file(_image!),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Pick Image and Analyze'),
              ),
              SizedBox(height: 20),
              Text(_analysisResult),
              SizedBox(height: 20),
              Text('Tipo de material: $tipo_material'),
              Text('Cantidad: $cantidad'),
              Text('Descripción: $descripcion'),
              Text('Direccion: $direccion'),
            ],
          ),
        ),
      ),
    );
  }
}
