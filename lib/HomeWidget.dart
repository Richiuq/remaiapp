import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:remaiapp/Clases.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:remaiapp/OfertasWidget.dart';
import 'package:remaiapp/OfrecerMaterial.dart';
import 'package:remaiapp/RatingWidget.dart';
import 'package:remaiapp/SolicitarMaterial.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  final TextEditingController _buscarController = TextEditingController();
  List<OfertasMat> listOfertas = [];

  @override
  void initState() {
    super.initState();
    getCurrentLocationAndOfertas();
  }

  Future<Position> _determinePosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<List<OfertasMat>> obtenerTodasLasOfertas(
      double userLat, double userLng) async {
    List<OfertasMat> listOfertas = [];
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');

    try {
      QuerySnapshot usersSnapshot = await usersCollection.get();
      for (QueryDocumentSnapshot userDoc in usersSnapshot.docs) {
        UserRem user = UserRem.fromDocument(userDoc);

        CollectionReference ofertasCollection =
            usersCollection.doc(userDoc.id).collection('ofertasMateriales');
        QuerySnapshot ofertasSnapshot = await ofertasCollection.get();

        for (QueryDocumentSnapshot ofertaDoc in ofertasSnapshot.docs) {
          var ofertaData = ofertaDoc.data() as Map<String, dynamic>;
          List<Location> locations =
              await locationFromAddress(ofertaData['direccion']);
          double distance = double.infinity;
          if (locations.isNotEmpty) {
            double offerLat = locations.first.latitude;
            double offerLng = locations.first.longitude;
            distance = Geolocator.distanceBetween(
                    userLat, userLng, offerLat, offerLng) /
                1000; // Convertir a km
            print(distance);
            OfertasMat oferta = OfertasMat(
              userOferta: user.username,
              // Obtener el nombre de usuario del documento principal
              imagenOferta: ofertaData['imagenOferta'] ?? '',
              tipoMaterial: ofertaData['tipoMaterial'] ?? '',
              notaUser: user.notaUser,
              // Obtener la nota de usuario del documento principal
              direccion: ofertaData['direccion'] ?? '',
              cantidad: ofertaData['cantidad'] ?? '',
              descripcion: ofertaData['descripcion'] ?? '',
              tiempoRetiro: ofertaData['tiempoRetiro'] ?? '',
              estado: ofertaData['estado'] ?? '',
              distance: distance,
            );
            listOfertas.add(oferta);
          }
        }
      }
    } catch (e) {
      print('Error al obtener las ofertas: $e');
    }
    return listOfertas;
  }

  Future<void> getCurrentLocationAndOfertas() async {
    try {
      Position position = await _determinePosition();
      print("User Position: ${position.latitude}, ${position.longitude}");
      double userLat = position.latitude;
      double userLng = position.longitude;

      listOfertas = await obtenerTodasLasOfertas(
          userLat, userLng); // Esperar a obtener todas las ofertas
      // listOfertas = listOfertas.where((oferta) => oferta.distance < 3).toList();
      listOfertas.sort((a, b) =>
          a.distance.compareTo(b.distance)); // Ordena la lista por distancia

      setState(() {});
    } catch (e) {
      print('Error al obtener la ubicación o las ofertas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fondo blanco
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
        ),
        // Imagen de fondo
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/frame4.png"),
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
        Container(
          margin: EdgeInsets.fromLTRB(0, 130, 0, 0),
          height: 340,
          width: 400,
          child: Stack(
            children: [
              ...listOfertas.map((listOfertas) {
                final random = Random();
                // Ajustar posiciones aleatorias dentro del tamaño del container
                final double left = random.nextDouble() *
                    (250 - 40); // 40 es el tamaño aproximado del pin
                final double top = random.nextDouble() *
                    (250 - 60); // 60 incluye el tamaño del pin y el texto
                return Positioned(
                  left: left,
                  top: top,
                  child: Column(
                    children: [
                      RatingWidget(
                        imageUrl: listOfertas.imagenOferta,
                        rating: listOfertas.notaUser,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: Column(
                children: [
                  SizedBox(
                    height: 140,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1,
                                color: Color(0xE56FCA3A),
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: TextField(
                            controller: _buscarController,
                            decoration: InputDecoration(
                              hintText: 'Buscar',
                              hintStyle: TextStyle(color: Color(0xE56FCA3A)),
                              // Cambiar color del hintText
                              prefixIcon:
                                  Icon(Icons.search, color: Color(0xE56FCA3A)),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10), // Ajustar padding vertical
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 300,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => OfrecerMaterial(
                                            tipoMaterial: '',
                                            cantidad: '',
                                            descripcion: '',
                                            imagenOferta: '',
                                          )),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
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
                                    'Ofrecer Material',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w700,
                                      height: 1.5,
                                      letterSpacing: 0.38,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          SolicitarMaterial()),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
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
                                    'Solicitar Material',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
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
                        SizedBox(height: 20),
                        Container(
                          height: 150,
                          // Altura fija para la lista horizontal
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: listOfertas.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: OfertasWidget(
                                  listOfertas: listOfertas[index],
                                ),
                              );
                            },
                          ),
                        ),
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
    );
  }
}
