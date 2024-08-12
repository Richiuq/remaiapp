import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:remaiapp/RemHome.dart';
import 'package:remaiapp/RemMatching.dart';

class SolicitarMaterial extends StatefulWidget {
  const SolicitarMaterial({super.key});

  @override
  State<SolicitarMaterial> createState() => _SolicitarMaterialState();
}

class _SolicitarMaterialState extends State<SolicitarMaterial> {
  final TextEditingController _tipoMaterialController = TextEditingController();
  final TextEditingController _ideaConstruccionController =
      TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  String? userId,
      usersId,
      notaUsuario,
      emailUser,
      userType, username, fotoUser;

  Future<void> publicarSolicitud() async {
    try {
      userId = FirebaseAuth.instance.currentUser!.uid;

      CollectionReference users =
          FirebaseFirestore.instance.collection('users');
      print('Adding offer to Firestore...');
      await users.doc(userId).collection('solicitudesMateriales').add({
        'ideaProyecto': _ideaConstruccionController.text,
        'tipoMaterial': _tipoMaterialController.text,
        'cantidad': _cantidadController.text,
        'direccion': _direccionController.text,
        'estado': 'Activa'
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Solicitud registrada exitosamente.')),
      );
      print('Solicitud registrada exitosamente.');
      await obtenerMejorMatch();
    } catch (e) {
      print('Error al registrar la solicitud: $e');
    }
  }

  Future<void> obtenerMejorMatch() async {
    final datos = await obtenerDatosDesdeFirebase();

    print(jsonEncode(datos));

    final model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: 'AIzaSyBBzHy7nTKZEqvPJwcnUcaAzr5IPlZMR-Q',
    );

    final prompt = '''Encuentra el mejor match entre oferentes y solicitantes en el siguiente JSON. El mejor match debe cumplir los siguientes criterios: 
    * **Coincidencia de tipo de material:** El tipo de material ofrecido debe ser exactamente el mismo que el tipo de material solicitado.
    * **Distancia mínima:** Prioriza los matches con la menor distancia entre la ubicación de la oferta y la ubicación de la solicitud. 
    * **Mayor calificación combinada:** En caso de empate en distancia, elige el match con la mayor suma de las calificaciones del oferente y del solicitante.
    **Formato de salida (solo esto nada mas):**
    {
    "imagenOferta": "",
    "tipoMaterial": "",
    "cantidad": "",
    "descripcion": "",
    "distanciaKm": ""
    "fotoOfertante": "",
    "mailOfertante": "",
    "mailSolicitud": "", 
    "idOferta": "",
    "idSolicitud": "",
    "fotoSolicitante": "",
    "direccion": "",
    "tiempoRetiro": "",
    "notaOfertante": "",
    "notaSolicitante": "",
    }''';
/*    final prompt = '''
puedes encontrar el mejor match entre oferentes y solicitantes de este json, puedes entregarme solo el mejor match. 
**Formato de salida:** Devuelve la información extraída en formato JSON (no le pongas el json en la primera fila), estructurado de la siguiente manera por ofertante y solicitante: 
{
  "id_oferta": "", 
  "tipo_material": "", 
  "cantidad": "", 
  "direccion": "",
  "imagenOferta": "", 
  "tiempoRetiro": "", 
  "id_oferente": "", 
  "calificacion_oferente": "", 
  "email_oferente": "", 
  "userType_oferente": "", 
  "username_oferente": "", 
  "id_solicitud": "", 
  "tipo_material_solicitud": "", 
  "direccion_solicitud": "",
  "ideaProyecto_solicitud": "", 
  "descripcion_solicitud": "", 
  "id_solicitante": "", 
  "calificacion_solicitante": "", 
  "email_solicitante": "", 
  "userType_solicitante": "" 
  "username_solicitante": "" 
}
''';*/

    final content = [
      Content.multi([
        TextPart(jsonEncode(datos)),
        TextPart(prompt),
      ])
    ];

    final response = await model.generateContent(content);
    print(response.text);
    if (response.text != null) {
      setState(() {

        String jsonString = response.text!.replaceAll('```json', '').replaceAll('```', '').trim();
        final Map<String, dynamic> responseData = jsonDecode(jsonString);
        print(responseData);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RemMatching(datos: responseData)),
        );
        //FALTA HACER FUNCION QUE GUARDE LOS MATCH EN UNA COLLECTION (PADRE) Y ADEMAS HACER LA PESTAÑA DE HISTORIAL Y HACER LA LOGICA DE BOTTOMBUTTONBAR
        //OJO QUE PASRECE QUE NO ESTA GUARDANDO DATOS DEL CONTACTO CUANDO HACE EL AUTH CON GMAIL
      });
    }
  }
/*    if (response.text != null) {
      final resultado = jsonDecode(response.text!);
      print('Mejor Match: $resultado');
      // Aquí puedes procesar el resultado como desees
    } else {
      print('Error al obtener el resultado de Gemini');
    }*/


  Future<Map<String, dynamic>> obtenerDatosDesdeFirebase() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    List<Map<String, dynamic>> ofertas = [];
    List<Map<String, dynamic>> solicitudes = [];

    // Obtén todos los usuarios
    QuerySnapshot usuariosSnapshot = await firestore.collection('users').get();

    for (var userDoc in usuariosSnapshot.docs) {
      usersId = userDoc.id;
      var userData = userDoc.data() as Map<String, dynamic>;

      notaUsuario = userData['nota'];
      emailUser = userData['email'];
      username = userData['username'];
      fotoUser = userData['fotoUser'];

      QuerySnapshot ofertasSnapshot = await firestore
          .collection('users')
          .doc(usersId)
          .collection('ofertasMateriales')
          .get();

      ofertas.addAll(ofertasSnapshot.docs.map((doc) {
        return {
          "imagenOferta": doc['imagenOferta'],
          "tipoMaterial": doc['tipoMaterial'],
          "cantidad": doc['cantidad'],
          "descripcion": doc['descripcion'],
          "fotoOfertante": fotoUser,
          "mailOfertante": emailUser,
          "idOferta": doc.id,
          "direccion": doc['direccion'],
          "tiempoRetiro": doc['tiempoRetiro'],
          "notaOfertante": notaUsuario,
          "idOfertante": userId,
        };
      }).toList());

      // Obtén las solicitudes de material del usuario
      QuerySnapshot solicitudesSnapshot = await firestore
          .collection('users')
          .doc(usersId)
          .collection('solicitudesMateriales')
          .get();

      solicitudes.addAll(solicitudesSnapshot.docs.map((doc) {
        return {
          "idSolicitud": doc.id,
          "tipoMaterial": doc['tipoMaterial'],
          "direccion": doc['direccion'],
          "ideaProyecto": doc['ideaProyecto'],
          "cantidad": doc['cantidad'],
          "id_solicitante": userId,
          "notaSolicitante": notaUsuario,
          "mailSolicitud": emailUser,
          "username": username,
          "fotoSolicitante": fotoUser,
        };
      }).toList());
    }

    Map<String, dynamic> criterios = {
      "distancia_maxima": '10',
      "coincidencia_materiales": 'exacta',
      "prioridad_rem_points": 'alta',
    };

    // Construye el JSON final
    Map<String, dynamic> datosFinales = {
      "ofertas": ofertas,
      "solicitudes": solicitudes,
      "criterios": criterios,
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Match exitoso.')),
    );
    return datosFinales;
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
          SingleChildScrollView(
            child: Container(
              child: Center(
                child: Column(
                  children: [
                    // Imagen superpuesta
                    Container(
                      margin: EdgeInsets.fromLTRB(70, 70, 0, 10),
                      child: Image.asset(
                        "assets/frame5.png",
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              '¿Qué material necesitas?',
                              style: TextStyle(
                                fontSize: 16.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Divider(
                                  color: Colors.black,
                                  thickness: 1.0,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  'Completado el formulario',
                                  style: TextStyle(fontSize: 16.0),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Colors.black,
                                  thickness: 1.0,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 20),
                            decoration: ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 1,
                                  color: Color(0xE56FCA3A),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: TextField(
                              controller: _ideaConstruccionController,
                              maxLines: 2,
                              // Permite que el TextField crezca dinámicamente
                              textAlign: TextAlign.start,
                              // Alinea el texto a la izquierda
                              decoration: InputDecoration.collapsed(
                                hintText:
                                    '¿Cuál es tu proyecto de construcción?',
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 1,
                                  color: Color(0xE56FCA3A),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: TextField(
                              controller: _tipoMaterialController,
                              decoration: InputDecoration.collapsed(
                                hintText: 'Tipo de material',
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 1,
                                  color: Color(0xE56FCA3A),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: TextField(
                              controller: _cantidadController,
                              // Permite que el TextField crezca dinámicamente
                              decoration: InputDecoration.collapsed(
                                hintText: 'Cantidad',
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 1,
                                  color: Color(0xE56FCA3A),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: TextField(
                              controller: _direccionController,
                              decoration: InputDecoration.collapsed(
                                hintText: 'Ubicación',
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: publicarSolicitud,
/*                            onTap: (){
                              Map<String, dynamic> matchData = {
                                "imagenOferta": "https://as1.ftcdn.net/v2/jpg/04/56/58/18/1000_F_456581881_jEAhhJIU8mJgUvIUEgRW3LaESxCH5Y0t.jpg", // URL ficticia de imagen
                                "tipoMaterial": "Ladrillos",
                                "cantidad": "40-50",
                                "descripcion": "Ladrillos de arcilla roja, usados, en buen estado. Algunos presentan manchas blancas por la salitre.",
                                "fotoOfertante": "https://as1.ftcdn.net/v2/jpg/04/56/58/18/1000_F_456581881_jEAhhJIU8mJgUvIUEgRW3LaESxCH5Y0t.jpg", // URL ficticia de foto del ofertante
                                "mailOfertante": "ofertante@example.com",
                                "mailSolicitud": "solicitante@example.com",
                                "idOferta": "oferta12345",
                                "idSolicitud": "solicitud67890",
                                "estadoMatch": "En proceso",
                                "fotoSolicitante": "https://as1.ftcdn.net/v2/jpg/04/56/58/18/1000_F_456581881_jEAhhJIU8mJgUvIUEgRW3LaESxCH5Y0t.jpg", // URL ficticia de foto del solicitante
                                "direccion": "123 Calle Falsa, Ciudad Ejemplo",
                                "distancia": "5.4", // Distancia en kilómetros
                                "tiempoRetiro": "2024-08-20 14:30", // Fecha y hora en formato ficticio
                                "notaOfertante": "4.5", // Nota ficticia
                                "notaSolicitante": "4.8", // Nota ficticia
                              };
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => RemMatching(datos: matchData)),
                              );
                            },*/
                            child: Container(
                              width: double.infinity,
                              height: 56,
                              margin: EdgeInsets.symmetric(horizontal: 20),
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
                                  'Publicar Solicitud',
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
    );
  }
}
