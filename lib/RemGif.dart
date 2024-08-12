import 'package:flutter/material.dart';

class RemGif extends StatelessWidget {
  const RemGif({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image(
              image: AssetImage('assets/remgif.gif'),
            ),
          ),
        ),
      ),
    );
  }
}
