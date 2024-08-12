import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:remaiapp/RemInicioSesion.dart';

class RemPerfil extends StatefulWidget {
  const RemPerfil({super.key});

  @override
  State<RemPerfil> createState() => _RemPerfilState();
}

class _RemPerfilState extends State<RemPerfil> {
  // User data fields
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController userTypeController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController nifController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String fotoPerfil = 'https://static.vecteezy.com/system/resources/previews/009/734/564/non_2x/default-avatar-profile-icon-of-social-media-user-vector.jpg';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userProfile = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        setState(() {
          usernameController.text = userProfile['username'] ?? '';
          emailController.text = userProfile['email'] ?? '';
          userTypeController.text = userProfile['userType'] ?? '';
          //nameController.text = userProfile['name'] ?? '';
          //nifController.text = userProfile['nif'] ?? '';
          //addressController.text = userProfile['address'] ?? '';
          //phoneController.text = userProfile['phone'] ?? '';
          passwordController.text = userProfile['password'] ?? '';
          fotoPerfil = userProfile['fotoUser'] ?? '';
          isLoading = false; // Datos cargados, dejar de mostrar el indicador de carga
        });
      }
    } catch (e) {
      print("Error loading user profile: $e");
      setState(() {
        isLoading = false; // Incluso en caso de error, dejar de mostrar el indicador de carga
      });
    }
  }


  Widget _buildTextField(String labelText, TextEditingController controller, {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: TextField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: labelText,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green, width: 1),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordTextField(String labelText, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: TextField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          labelText: labelText,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green, width: 1),
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.edit, color: Colors.green,),
            onPressed: (){},
          ),
        ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RemInicioSesion()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión: $e')),
      );
    }
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
                  Container(
                    margin: EdgeInsets.fromLTRB(70, 70, 0, 10),
                    child: Image.asset(
                      "assets/frame5.png",
                    ),
                  ),
                  Text(
                    'Perfil de usuario',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10,),
                  Stack(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.green,
                            width: 1.0,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(fotoPerfil),
                          backgroundColor: Colors.white,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green,
                          ),
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    usernameController.text.isNotEmpty
                        ? usernameController.text
                        : 'Nombre del Usuario',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10,),
                  _buildTextField("Username", usernameController),
/*                  Divider(
                    color: Colors.green, // Color de la línea
                    thickness: 2.0, // Grosor de la línea
                    indent: 20.0, // Espacio desde el inicio de la línea (opcional)
                    endIndent: 20.0, // Espacio desde el final de la línea (opcional)
                  ),*/
                  _buildTextField("Email", emailController),
                  _buildTextField("Tipo de Usuario", userTypeController),
                  //_buildTextField("Name", nameController),
                  //_buildTextField("NIF", nifController),
                  //_buildTextField("Address", addressController),
                  //_buildTextField("Phone", phoneController),
                  _buildPasswordTextField("Password", passwordController),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _signOut(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Button color
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      'Cerrar Sesión',
                      style: TextStyle(fontSize: 16, color: Colors.white),
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
