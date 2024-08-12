import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final String rating; // La nota que se utiliza para calcular las estrellas

  const StarRating({Key? key, required this.rating}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int fullStars = double.parse(rating).floor(); // Cantidad de estrellas llenas
    bool hasHalfStar = double.parse(rating) - fullStars >= 0.5; // Si tiene una estrella a medias
    int emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0); // Cantidad de estrellas vacías

    List<Widget> stars = [];

    // Agregar las estrellas llenas
    for (int i = 0; i < fullStars; i++) {
      stars.add(Icon(
        Icons.star,
        color: Colors.amber,
        size: 20,
      ));
    }

    // Agregar la estrella a medias, si es necesario
    if (hasHalfStar) {
      stars.add(Icon(
        Icons.star_half,
        color: Colors.amber,
        size: 20,
      ));
    }

    // Agregar las estrellas vacías
    for (int i = 0; i < emptyStars; i++) {
      stars.add(Icon(
        Icons.star_border,
        color: Colors.amber,
        size: 20,
      ));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: stars,
    );
  }
}
