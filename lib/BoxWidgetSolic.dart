import 'package:flutter/material.dart';
import 'package:remaiapp/Clases.dart';


class BoxWidgetSolic extends StatelessWidget {
  const BoxWidgetSolic({super.key, required this.solicitudes});

  final SolicitudesMat solicitudes;

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
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 20,
                      child: Text(
                        solicitudes.tipoMaterial,
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
                      child: Text(solicitudes.ideaProyecto, style: TextStyle(
                        fontSize: 10,
                      ),),
                    ),
                    SizedBox(height: 5),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    solicitudes.cantidad,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Container(
                    decoration: BoxDecoration(
                      color: solicitudes.estado == 'Activa' ? Colors.cyanAccent : Colors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(
                        vertical: 2, horizontal: 8),
                    child: Text(
                      solicitudes.estado,
                      style: TextStyle(color: Colors.white, fontSize: 9),
                    ),
                  ),
                  SizedBox(height: 4),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
