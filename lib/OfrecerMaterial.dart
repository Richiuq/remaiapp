import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:remaiapp/GeminiFunction.dart';
import 'package:remaiapp/RemCamara.dart';
import 'package:remaiapp/RemGif.dart';
import 'package:remaiapp/RemHome.dart';
import 'package:remaiapp/prueba.dart';

class OfrecerMaterial extends StatefulWidget {
  final String tipoMaterial;
  final String cantidad;
  final String descripcion;
  final String imagenOferta;

  const OfrecerMaterial(
      {super.key,
      required this.tipoMaterial,
      required this.cantidad,
      required this.descripcion,
      required this.imagenOferta});

  @override
  State<OfrecerMaterial> createState() => _OfrecerMaterialState();
}

class _OfrecerMaterialState extends State<OfrecerMaterial> {
  late TextEditingController _tipoMaterialController = TextEditingController();
  late TextEditingController _cantidadController = TextEditingController();
  late TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();

  final List<String> items = ['0-5', '6-15', '+15']; // Lista de variable
  String? selectedItem;
  final TextEditingController _dropdownController = TextEditingController();

  String? imagenOferta;

  @override
  void initState() {
    super.initState();
    selectedItem = items.first; // Inicializa con el primer elemento de la lista
    _dropdownController.text = selectedItem!;
    _tipoMaterialController = TextEditingController(text: widget.tipoMaterial);
    _cantidadController = TextEditingController(text: widget.cantidad);
    _descripcionController = TextEditingController(text: widget.descripcion);
    imagenOferta = widget.imagenOferta;
  }

  Future<void> registrarOferta() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;

      if (widget.imagenOferta.isNotEmpty) {
        final storageReference = FirebaseStorage.instance
            .ref()
            .child('Ofertas/$userId/${DateTime.now()}.png');
        print('Uploading image to Firebase Storage...');
        await storageReference.putFile(File(widget.imagenOferta));
        print('Image uploaded.');
        final photoUrl = await storageReference.getDownloadURL();
        print('Download URL: $photoUrl');

        CollectionReference users =
            FirebaseFirestore.instance.collection('users');
        print('Adding offer to Firestore...');
        await users.doc(userId).collection('ofertasMateriales').add({
          'imagenOferta': photoUrl,
          'tipoMaterial': _tipoMaterialController.text,
          'cantidad': _cantidadController.text,
          'descripcion': _descripcionController.text,
          'tiempoRetiro': _dropdownController.text,
          'direccion': _direccionController.text,
          'estado': 'Activa',
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Oferta registrada exitosamente.')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RemHome()),
        );
        print('Oferta registrada exitosamente.');
      } else {
        print('No image offer provided.');
      }
    } catch (e) {
      print('Error al registrar la oferta: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Imagen de fondo
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/frame2.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              child: Center(
                child: Column(
                  children: [
                    // Imagen superpuesta
                    Container(
                      margin: EdgeInsets.fromLTRB(70, 70, 0, 10),
                      child: Image.asset(
                        "assets/frame5.png",
                      ),
                    ),
                    if (widget.imagenOferta.isNotEmpty)
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 30),
                        height: 230,
                        width: 230,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          // Ajusta el radio según tus necesidades
                          child: Image.file(
                            File(widget.imagenOferta),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    else
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                'Completa el formulario del material automáticamente con:',
                                style: TextStyle(
                                  fontSize: 16.0,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  //MaterialPageRoute(builder: (context) => GeminiFunction()),
                                  MaterialPageRoute(
                                      builder: (context) => RemCamara()),
                                );
                              },
                              child: Center(
                                child: Container(
                                  margin: EdgeInsets.all(10),
                                  child: Image.asset(
                                    "assets/geminiphoto.png",
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Divider(
                                  color: Colors.black,
                                  thickness: 1.0,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  'O completado manualmente',
                                  style: TextStyle(fontSize: 16.0),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Colors.black,
                                  thickness: 1.0,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 1,
                                  color: Color(0xE56FCA3A),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: TextField(
                              controller: _tipoMaterialController,
                              decoration: InputDecoration.collapsed(
                                hintText: 'Tipo de material',
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 1,
                                  color: Color(0xE56FCA3A),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: TextField(
                              controller: _cantidadController,
                              decoration: InputDecoration.collapsed(
                                hintText: 'Cantidad',
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 1,
                                  color: Color(0xE56FCA3A),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: TextField(
                              controller: _descripcionController,
                              maxLines: null,
                              // Permite que el TextField crezca dinámicamente
                              decoration: InputDecoration.collapsed(
                                hintText: 'Descripción detallada',
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 1,
                                  color: Color(0xE56FCA3A),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: TextField(
                              controller: _direccionController,
                              decoration: InputDecoration.collapsed(
                                hintText: 'Ubicación',
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'Tiempo máximo de retiro',
                              style: TextStyle(
                                color: Color(0xFF1E1E1E),
                                fontSize: 16,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                                letterSpacing: -0.24,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            child: DropdownButtonFormField<String>(
                              value: selectedItem,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedItem = newValue;
                                  _dropdownController.text = newValue!;
                                });
                              },
                              items: items.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                    width: 1,
                                    color: Color(0xE56FCA3A),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: registrarOferta,
                            child: Container(
                              width: double.infinity,
                              height: 56,
                              margin: EdgeInsets.symmetric(horizontal: 20),
                              padding: const EdgeInsets.all(16),
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
                                  'Publicar Oferta',
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
                          ),
                          const SizedBox(height: 20),
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
                debugPrint('Icon tapped');
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
      ),
    );
  }
}
