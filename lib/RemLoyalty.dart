import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:remaiapp/StarRating.dart';


class RemLoyalty extends StatefulWidget {
  const RemLoyalty({super.key});

  @override
  State<RemLoyalty> createState() => _RemloyaltyState();
}

class _RemloyaltyState extends State<RemLoyalty> {
  String notaUser = '0';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    obtenerNotaDelUsuario();
  }

  Future<void> obtenerNotaDelUsuario() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user != null) {
      final String uid = user.uid;
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot userDoc = await firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        setState(() {
          notaUser = userDoc['nota'] ?? '0'; // Asigna la nota o '0' si es null
          isLoading = false; // Deja de mostrar el indicador de carga
        });
      } else {
        print('Documento del usuario no existe.');
        setState(() {
          isLoading = false;
        });
      }
    } else {
      print('No hay usuario autenticado.');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(70, 70, 0, 10),
                    child: Image.asset(
                      "assets/frame5.png",
                    ),
                  ),
                  Text(
                    'Nivel de fidelidad',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Stack(
                    children: [
                      Center(
                        child: Container(
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: Image.asset(
                            "assets/remNota.png",
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          margin: EdgeInsets.fromLTRB(0, 45, 0, 0),
                          child: Text(
                            notaUser,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  StarRating(rating: notaUser),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Acumula puntos con cada Match y\ncanjéalos por premios exclusivos.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    child: Image.asset(
                      "assets/currentpoints.png",
                    ),
                  ),
                  Container(
                    child: Image.asset(
                      "assets/currentpoints2.png",
                    ),
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
