import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:remaiapp/BoxWidget.dart';
import 'package:remaiapp/BoxWidgetOferta.dart';
import 'package:remaiapp/BoxWidgetSolic.dart';
import 'Clases.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class RemHistoria extends StatefulWidget {
  const RemHistoria({super.key});

  @override
  State<RemHistoria> createState() => _RemHistoriaState();
}

class _RemHistoriaState extends State<RemHistoria> {
  List<MatchMaterial> matches = [];
  List<OfertasMat> listOfertas = [];
  List<SolicitudesMat> listSolicitudes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMatches();
  }

//HICE ESTO PARA QUE CARGUE LAS LISTAS PRIMERO Y LUEGO QUE LAS SETEE Y LAS MUESTRE
  Future<void> fetchMatches() async {
    try {
      List<MatchMaterial> loadedMatches = await getMatches();
      List<OfertasMat> loadedOfer = await obtenerTodasLasOfertas();
      List<SolicitudesMat> loadedSol = await getSolicitudes();
      setState(() {
        matches = loadedMatches;
        listOfertas = loadedOfer;
        listSolicitudes = loadedSol;
        isLoading = false;
      });
    } catch (e) {
      print('Error al cargar los matches: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

/*  Future<List<SolicitudesMat>> getSolicitudes() async {
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');

    try {
      QuerySnapshot usersSnapshot = await usersCollection.get();

      for (QueryDocumentSnapshot userDoc in usersSnapshot.docs) {
        UserRem user = UserRem.fromDocument(userDoc);
        CollectionReference solicitudesCollection =
            usersCollection.doc(userDoc.id).collection('solicitudesMateriales');
        QuerySnapshot solicitudesSnapshot = await solicitudesCollection.get();

        for (QueryDocumentSnapshot solicitudesDoc in solicitudesSnapshot.docs) {
          var solicitudesData = solicitudesDoc.data() as Map<String, dynamic>;
          SolicitudesMat solicitudes = SolicitudesMat(
            userSolicitante: user.username,
            tipoMaterial: solicitudesData['tipoMaterial'] ?? '',
            notaUser: user.notaUser,
            direccion: solicitudesData['direccion'] ?? '',
            cantidad: solicitudesData['cantidad'] ?? '',
            estado: solicitudesData['estado'] ?? '',
            ideaProyecto: solicitudesData['ideaProyecto'] ?? '',
          );
          listSolicitudes.add(solicitudes);
        }
      }
    } catch (e) {
      print('Error al obtener las solicitudes: $e');
    }
    return listSolicitudes;
  }*/

  Future<List<SolicitudesMat>> getSolicitudes() async {
    User? user = FirebaseAuth.instance.currentUser;
    String userUid = user?.uid ?? '';

    try {
      CollectionReference solicitudesCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(userUid)
          .collection('solicitudesMateriales');

      QuerySnapshot solicitudesSnapshot = await solicitudesCollection.get();

      for (QueryDocumentSnapshot solicitudesDoc in solicitudesSnapshot.docs) {
        var solicitudesData = solicitudesDoc.data() as Map<String, dynamic>;
        SolicitudesMat solicitudes = SolicitudesMat(
          userSolicitante: userUid,
          tipoMaterial: solicitudesData['tipoMaterial'] ?? '',
          notaUser: solicitudesData['notaUser'] ?? '',
          direccion: solicitudesData['direccion'] ?? '',
          cantidad: solicitudesData['cantidad'] ?? '',
          estado: solicitudesData['estado'] ?? '',
          ideaProyecto: solicitudesData['ideaProyecto'] ?? '',
        );
        listSolicitudes.add(solicitudes);
      }
    } catch (e) {
      print('Error al obtener las solicitudes: $e');
    }
    return listSolicitudes;
  }

/*  Future<List<MatchMaterial>> getMatches() async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      QuerySnapshot snapshot = await firestore.collection('matchMaterial').get();

      matches = snapshot.docs.map((doc) {
        return MatchMaterial.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
      print(matches);

      return matches;
    } catch (e) {
      print('Error al obtener los matches: $e');
      return [];
    }
  }*/

  Future<List<MatchMaterial>> getMatches() async {
    User? user = FirebaseAuth.instance.currentUser;
    String userEmail = user?.email ?? '';

    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      QuerySnapshot snapshot = await firestore.collection('matchMaterial')
          .where('mailOfertante', isEqualTo: userEmail)
          .get();

      QuerySnapshot snapshot2 = await firestore.collection('matchMaterial')
          .where('mailSolicitud', isEqualTo: userEmail)
          .get();

      matches = [
        ...snapshot.docs.map((doc) {
          return MatchMaterial.fromMap(doc.data() as Map<String, dynamic>);
        }).toList(),
        ...snapshot2.docs.map((doc) {
          return MatchMaterial.fromMap(doc.data() as Map<String, dynamic>);
        }).toList(),
      ];

      return matches;
    } catch (e) {
      print('Error al obtener los matches: $e');
      return [];
    }
  }

  //OBTENER LISTA DE OFERTAS
  /*Future<List<OfertasMat>> obtenerTodasLasOfertas() async {
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
          OfertasMat oferta = OfertasMat(
            userOferta: user.username,
            imagenOferta: ofertaData['imagenOferta'] ?? '',
            tipoMaterial: ofertaData['tipoMaterial'] ?? '',
            notaUser: user.notaUser,
            direccion: ofertaData['direccion'] ?? '',
            cantidad: ofertaData['cantidad'] ?? '',
            descripcion: ofertaData['descripcion'] ?? '',
            tiempoRetiro: ofertaData['tiempoRetiro'] ?? '',
            estado: ofertaData['estado'] ?? '',
            distance: 0,
          );
          listOfertas.add(oferta);
        }
      }
    } catch (e) {
      print('Error al obtener las ofertas: $e');
    }
    return listOfertas;
  }*/

  Future<List<OfertasMat>> obtenerTodasLasOfertas() async {
    User? user = FirebaseAuth.instance.currentUser;
    String userUid = user?.uid ?? '';

    try {
      CollectionReference ofertasCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(userUid)
          .collection('ofertasMateriales');

      QuerySnapshot ofertasSnapshot = await ofertasCollection.get();

      for (QueryDocumentSnapshot ofertaDoc in ofertasSnapshot.docs) {
        var ofertaData = ofertaDoc.data() as Map<String, dynamic>;
        OfertasMat oferta = OfertasMat(
          userOferta: userUid,
          imagenOferta: ofertaData['imagenOferta'] ?? '',
          tipoMaterial: ofertaData['tipoMaterial'] ?? '',
          notaUser: ofertaData['notaUser'] ?? '',
          direccion: ofertaData['direccion'] ?? '',
          cantidad: ofertaData['cantidad'] ?? '',
          descripcion: ofertaData['descripcion'] ?? '',
          tiempoRetiro: ofertaData['tiempoRetiro'] ?? '',
          estado: ofertaData['estado'] ?? '',
          distance: 0,
        );
        listOfertas.add(oferta);
      }
    } catch (e) {
      print('Error al obtener las ofertas: $e');
    }
    return listOfertas;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Imagen de fondo
                  Container(
                    margin: EdgeInsets.fromLTRB(70, 70, 0, 10),
                    child: Image.asset(
                      "assets/frame5.png",
                    ),
                  ),
                  Text(
                    'Historial de Transacciones',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'MATCH',
                          style: TextStyle(
                            fontSize: 14.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'REALIZADOS',
                          style: TextStyle(
                            fontSize: 14.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: matches.length,
                    itemBuilder: (context, index) {
                      return BoxWidget(matches: matches[index],);
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'OFERTAS',
                          style: TextStyle(
                            fontSize: 14.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'REALIZADOS',
                          style: TextStyle(
                            fontSize: 14.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  // Segunda lista
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    // Evitar que se desplace
                    itemCount: listOfertas.length,
                    itemBuilder: (context, index) {
                      return BoxWidgetOferta(
                        ofertas: listOfertas[index],
                      );
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'SOLICITUDES',
                          style: TextStyle(
                            fontSize: 14.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'REALIZADOS',
                          style: TextStyle(
                            fontSize: 14.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  // Segunda lista
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    // Evitar que se desplace
                    itemCount: listSolicitudes.length,
                    itemBuilder: (context, index) {
                      return BoxWidgetSolic(
                        solicitudes: listSolicitudes[index],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 70,
          ),
        ],
      ),
    );
  }
}
