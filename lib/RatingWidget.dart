import 'package:flutter/material.dart';

class RatingWidget extends StatelessWidget {
  final String imageUrl; // URL de ejemplo para la imagen
  final String rating;

  const RatingWidget({super.key, required this.imageUrl, required this.rating}); // Ejemplo de calificación

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 60,
        width: 50,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.green, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Image.network(
                  imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              left: 12,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.yellow,
                      size: 10,
                    ),
                    SizedBox(width: 1),
                    Text(
                      rating,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 8
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
