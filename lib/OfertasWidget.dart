import 'package:flutter/material.dart';
import 'package:remaiapp/Clases.dart';

class OfertasWidget extends StatelessWidget {
  final OfertasMat listOfertas;

  const OfertasWidget({super.key, required this.listOfertas});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 15),
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  listOfertas.imagenOferta,
                  width: 90,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listOfertas.tipoMaterial,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        listOfertas.descripcion,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        '${(listOfertas.distance).toStringAsFixed(1).replaceAll('.', ',')} km',
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 5,),
          Row(
            children: [
              SizedBox(width: 30),
              CircleAvatar(
                backgroundImage: NetworkImage(listOfertas.imagenOferta),
                radius: 15,
              ),
              SizedBox(width: 5),
              Row(
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.yellow,
                    size: 16,
                  ),
                  SizedBox(width: 2),
                  Text(
                    listOfertas.notaUser,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
