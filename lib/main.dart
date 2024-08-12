import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:remaiapp/RemGif.dart';
import 'package:remaiapp/RemInicioSesion.dart';
import 'package:remaiapp/RemRegistroUser.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: 'AIzaSyBWh8MnWWeYbtRYH-XwqIFbKl2D3wNJfPQ',
        appId: '1:434597723467:android:59f1dfd0ea8eb5ebfbfcce',
        messagingSenderId: '434597723467',
        projectId: 'remapp-b5711',
        storageBucket: 'remapp-b5711.appspot.com',
      ));
  //runApp(MyApp());
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/frame0.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: RemPresentacion(),
        ),
      ),
    );
  }
}

class RemPresentacion extends StatelessWidget {

  Future<void> showLoadingScreen(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return RemGif();
      },
    );
    await Future.delayed(Duration(seconds: 3));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(
            height: 600,
          ),
          GestureDetector(
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RemRegistroUser()),
              );
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 50),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 56,
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
                        'Registrate',
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
                  SizedBox(height: 20,),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: '¿Ya tienes cuenta? ',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.black),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Inicia sesión',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                await showLoadingScreen(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => RemInicioSesion()),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}