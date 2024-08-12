import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:remaiapp/RemHome.dart';

class RemMatching extends StatefulWidget {
  const RemMatching({super.key, required this.datos});

  final Map<String, dynamic> datos;

  @override
  State<RemMatching> createState() => _RemMatchingState();
}

class _RemMatchingState extends State<RemMatching> {
  @override
  void initState() {
    super.initState();
    registerMatch();
  }

  Future<void> registerMatch() async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      Map<String, dynamic> matchData = {
        "imagenOferta": widget.datos['imagenOferta'],
        "tipoMaterial": widget.datos['tipoMaterial'],
        "cantidad": widget.datos['cantidad'],
        "descripcion": widget.datos['descripcion'],
        "fotoOfertante": widget.datos['fotoOfertante'],
        "mailOfertante": widget.datos['mailOfertante'],
        "mailSolicitud": widget.datos['mailSolicitud'],
        "idOferta": widget.datos['idOferta'],
        "idSolicitud": widget.datos['idSolicitud'],
        "estadoMatch": 'En proceso',
        "fotoSolicitante": widget.datos['fotoSolicitante'],
        "direccion": widget.datos['direccion'],
        "distancia": widget.datos['distanciaKm'],
        "tiempoRetiro": widget.datos['tiempoRetiro'],
        "notaOfertante": widget.datos['notaOfertante'],
        "notaSolicitante": widget.datos['notaSolicitante'],
      };
      await firestore.collection('matchMaterial').add(matchData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Match registrado exitosamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar el match: $e')),
      );
    }
  }

  Widget buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Expanded(
            flex: 2,
            child: Text(value ?? ''),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RemHome()),
                  );
                },
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue, // Color de fondo del círculo
                      ),
                      child: Center(
                        child: Icon(
                          Icons.close,
                          color: Colors.white, // Color del icono
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: Image.asset(
                  "assets/frameMatch.png",
                  width: 300,
                  height: 300,
                ),
              ),
              SizedBox(height: 20),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "¡${widget.datos['mailSolicitud']} ",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Image.asset(
                      'assets/geminiword.png',
                      width: 80,
                      height: 30,
                    ),
                    SizedBox(height: 4),
                    Text(
                      "encontró un match!",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  "Ponte en contacto con tu REM friend para\ncoordinar la entrega / retiro del material.",
                  style: TextStyle(fontSize: 12),
                ),
              ),
              SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  // Fondo gris claro para el borde circular
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black,
                    width: 1,
                  ),
                ),
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage:
                      NetworkImage('${widget.datos['fotoOfertante']}'),
                  backgroundColor: Colors
                      .transparent, // Para evitar color de fondo si la imagen tiene transparencia
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  '${widget.datos['mailOfertante']}',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 10),
              //BOTON CONTACTAR
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(
                          'Detalles del Contacto',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        content: SingleChildScrollView(
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.green),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        child: Image.network(
                                          '${widget.datos['imagenOferta']}',
                                          // Reemplaza con la URL de tu imagen
                                          width: 90,
                                          height: 90,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              widget.datos['tipoMaterial'],
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Container(
                                              height: 30,
                                              child: Text(
                                                widget.datos['descripcion'],
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.grey[700]),
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Icon(Icons.location_on,
                                                    color: Colors.green),
                                                SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    widget.datos['direccion'],
                                                    style: TextStyle(
                                                        fontSize: 8,
                                                        color:
                                                            Colors.grey[700]),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Text(
                                                  widget.datos['cantidad'],
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 12),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.green),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(50.0),
                                        child: Image.network(
                                          '${widget.datos['fotoOfertante']}',
                                          // Reemplaza con la URL de tu imagen
                                          width: 90,
                                          height: 90,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              widget.datos['mailOfertante'],
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Container(
                                              height: 10,
                                              child: Text(
                                                widget.datos['mailOfertante'],
                                                style: TextStyle(
                                                    fontSize: 8,
                                                    color: Colors.grey[700]),
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end, // Mantiene el contenido alineado al final
                                              children: [
                                                Stack(
                                                  alignment: Alignment.center, // Alinea todos los hijos del Stack al centro
                                                  children: [
                                                    Image.asset(
                                                      "assets/remNota.png",
                                                      width: 60,
                                                      height: 60,
                                                    ),
                                                    Positioned(
                                                      child: Text(
                                                        widget.datos['notaOfertante'],
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight: FontWeight.bold,
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
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),
                              // Texto de sugerencia
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Image.asset(
                                        'assets/geminiword.png',
                                        width: 80,
                                        height: 30,
                                      ),
                                      Text(
                                        '¡Encontró sugerencias',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.green[800],
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'de materiales para tu proyecto!',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.green[800],
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              // Botón de revisión
                              TextButton.icon(
                                onPressed: () {
                                  // Acción del botón de revisión
                                },
                                icon: Icon(Icons.search, color: Colors.green),
                                label: Text(
                                  'Revísalas aquí.',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.indigo),
                                ),
                              ),
                              SizedBox(height: 32),
                              // Botón de volver
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  // Color del botón
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 64, vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: Text(
                                  'Volver',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 56,
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: ShapeDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(0.00, -1.00),
                      end: Alignment(0, 1),
                      colors: [Color(0xFF6FCA3A), Color(0xCC59A52C)],
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Contactar',
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
        ),
      ),
    );
  }
}
