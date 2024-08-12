import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:remaiapp/RemHome.dart';
import 'Clases.dart';


class BoxWidget extends StatefulWidget {
  const BoxWidget({
    super.key,
    required this.matches,
  });

  final MatchMaterial matches;

  @override
  State<BoxWidget> createState() => _BoxWidgetState();
}

class _BoxWidgetState extends State<BoxWidget> {
  Future<void> cancelarMatch() async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot querySnapshot = await firestore
          .collection('matchMaterial')
          .where('idOferta', isEqualTo: widget.matches.idOferta)
          .get();
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        await doc.reference.update({'estadoMatch': 'cancelado'});
      }
      print('Match cancelado exitosamente.');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RemHome()),
      );
    } catch (e) {
      print('Error al cancelar el match: $e');
    }
  }

  Future<void> finalizarMatch() async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot querySnapshot = await firestore
          .collection('matchMaterial')
          .where('idOferta', isEqualTo: widget.matches.idOferta)
          .get();
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        await doc.reference.update({'estadoMatch': 'finalizado'});
      }
      print('Match finalizado exitosamente.');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RemHome()),
      );
    } catch (e) {
      print('Error al finzalizar el match: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green, width: 2),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.network(
                  widget.matches.imagenOferta,
                  width: 52,
                  height: 52,
                  fit: BoxFit.fill,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 20,
                      child: Text(
                        widget.matches.tipoMaterial,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                    Container(
                      width: 174,
                      height: 26,
                      child: Text(
                        widget.matches.descripcion,
                        style: TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: Image.network(
                            widget.matches.imagenOferta,
                            width: 20,
                            height: 20,
                            fit: BoxFit.fill,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          widget.matches.mailOfertante,
                          style: TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.matches.cantidad,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Container(
                    decoration: BoxDecoration(
                      color: widget.matches.estadoMatch == 'En proceso'
                          ? Colors.orange
                          : Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                    child: Text(
                      widget.matches.estadoMatch,
                      style: TextStyle(color: Colors.white, fontSize: 9),
                    ),
                  ),
                  SizedBox(height: 4),
                  if (widget.matches.estadoMatch == 'En proceso')
                    Column(
                      children: [
                        Text(
                          'Check in / out',
                          style: TextStyle(fontSize: 8),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: cancelarMatch,
                              child: Container(
                                color: Colors.green,
                                child: Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 15),
                            GestureDetector(
                              onTap: finalizarMatch,
                              child: Container(
                                  color: Colors.green,
                                  child: Icon(
                                    Icons.check,
                                    size: 18,
                                    color: Colors.white,
                                  )),
                            )
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
