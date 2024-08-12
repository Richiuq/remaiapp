import 'package:cloud_firestore/cloud_firestore.dart';

class MatchMaterial {
  final String imagenOferta;
  final String tipoMaterial;
  final String cantidad;
  final String descripcion;
  final String fotoOfertante;
  final String mailOfertante;
  final String mailSolicitud;
  final String idOferta;
  final String idSolicitud;
  final String estadoMatch;
  final String fotoSolicitante;
  final String direccion;
  final String distancia;
  final String tiempoRetiro;
  final String notaOfertante;
  final String notaSolicitante;

  MatchMaterial({
    required this.imagenOferta,
    required this.tipoMaterial,
    required this.cantidad,
    required this.descripcion,
    required this.fotoOfertante,
    required this.mailOfertante,
    required this.mailSolicitud,
    required this.idOferta,
    required this.idSolicitud,
    required this.estadoMatch,
    required this.fotoSolicitante,
    required this.direccion,
    required this.distancia,
    required this.tiempoRetiro,
    required this.notaOfertante,
    required this.notaSolicitante,
  });

  // Método para crear una instancia de MatchMaterial desde un documento de Firestore
  factory MatchMaterial.fromMap(Map<String, dynamic> data) {
    return MatchMaterial(
      imagenOferta: data['imagenOferta'],
      tipoMaterial: data['tipoMaterial'],
      cantidad: data['cantidad'],
      descripcion: data['descripcion'],
      fotoOfertante: data['fotoOfertante'],
      mailOfertante: data['mailOfertante'],
      mailSolicitud: data['mailSolicitud'],
      idOferta: data['idOferta'],
      idSolicitud: data['idSolicitud'],
      estadoMatch: data['estadoMatch'],
      fotoSolicitante: data['fotoSolicitante'],
      direccion: data['direccion'],
      distancia: data['distancia'],
      tiempoRetiro: data['tiempoRetiro'],
      notaOfertante: data['notaOfertante'],
      notaSolicitante: data['notaSolicitante'],
    );
  }
}


class UserRem {
  final String username;
  final String email;
  final String password;
  final String notaUser;
  final String tipouser;
  final String fotoUser;

  UserRem({
    required this.username,
    required this.email,
    required this.password,
    required this.notaUser,
    required this.tipouser,
    required this.fotoUser,
  });

  factory UserRem.fromDocument(DocumentSnapshot doc) {
    return UserRem(
      username: doc['username'],
      email: doc['email'],
      password: doc['password'],
      notaUser: doc['nota'],
      tipouser: doc['userType'],
      fotoUser: doc['fotoUser'],
    );
  }
}

class OfertasMat {
  final String userOferta;
  final String imagenOferta;
  final String tipoMaterial;
  final String cantidad;
  final String descripcion;
  final String notaUser;
  final String direccion;
  final String tiempoRetiro;
  final String estado;
  double distance;

  OfertasMat({
    required this.userOferta,
    required this.imagenOferta,
    required this.tipoMaterial,
    required this.cantidad,
    required this.descripcion,
    required this.notaUser,
    required this.direccion,
    required this.tiempoRetiro,
    required this.estado,
    this.distance = 0.0,
  });
}

class SolicitudesMat {
  final String userSolicitante;
  final String tipoMaterial;
  final String cantidad;
  final String ideaProyecto;
  final String notaUser;
  final String direccion;
  final String estado;

  SolicitudesMat({
    required this.userSolicitante,
    required this.tipoMaterial,
    required this.cantidad,
    required this.ideaProyecto,
    required this.notaUser,
    required this.direccion,
    required this.estado,
  });
}

/*    final apiKey = 'AIzaSyBBzHy7nTKZEqvPJwcnUcaAzr5IPlZMR-Q';
    if (apiKey == null) {
      print('No API key found');
      return;
    }

    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 1,
        topK: 64,
        topP: 0.95,
        maxOutputTokens: 8192,
        responseMimeType: 'application/json',
      ),
    );

    final bytes = imageFile.readAsBytesSync();
    final base64Image = base64Encode(bytes);

    final chat = model.startChat(history: [
      Content.multi([
        TextPart(base64Image),
        TextPart('Analiza la imagen adjunta y extrae la siguiente información para completar un formulario de oferta de materiales de construcción: 1. **Tipo de material:** Identifica el tipo de material específico que se muestra en la imagen (ej., vigas de acero, ladrillos, tuberías, etc.). Si es posible, determina el tipo específico de material (ej., acero estructural, ladrillo cerámico, tubería de PVC). 2. **Cantidad:** Estima la cantidad de material presente en la imagen. Si no es posible determinar una cantidad exacta, proporciona un rango aproximado (ej., 10-15 unidades, varios metros, etc.). 3. **Descripción detallada:** Describe el estado del material (nuevo, usado, buen estado, con daños, etc.) y cualquier otra característica relevante visible en la imagen (ej., dimensiones, color, marcas, etc.). 4. **Ubicación:** Si la imagen contiene información sobre la ubicación del material (ej., una dirección o un letrero), extráela. De lo contrario, indica que la ubicación no está disponible en la imagen. **Formato de salida:** Devuelve la información extraída en formato JSON, estructurado de la siguiente manera: ```json { "tipo_material": "", "cantidad": "", "descripcion": "", "direccion": "" }'),
      ]),
    ]);

    final message = 'Analyze the attached image and extract the information for the construction materials offer form.';
    final content = Content.text(message);

    final response = await chat.sendMessage(content);

    setState(() {
      _analysisResult = response.text!;
    });*/

/*  Future<void> _analyzeImageWithGoogleVision(File imageFile) async {
    try {
      final bytes = imageFile.readAsBytesSync();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse('https://vision.googleapis.com/v1/images:annotate?key=AIzaSyCD0QMk7Dtk8yqzlTmFusRdVivAXqtRcwY'),
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
                  'type': 'LABEL_DETECTION',
                  'maxResults': 10,
                }
              ],
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        final labels = result['responses'][0]['labelAnnotations']
            .map((label) => label['description'])
            .toList()
            .join(', ');
        setState(() {
          _analysisResult = labels;
        });
      } else {
        print('Error: ${response.statusCode}');
        print(response.body);
      }
    } catch (e) {
      print('Error al analizar la imagen con Google Vision: $e');
    }
  }*/