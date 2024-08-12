import 'package:flutter/material.dart';
import 'package:remaiapp/HomeWidget.dart';
import 'package:remaiapp/RemHistorial.dart';
import 'package:remaiapp/RemLoyalty.dart';
import 'package:remaiapp/RemPerfil.dart';


class RemHome extends StatefulWidget {
  static int _selectedIndex = 0;

  const RemHome({super.key});

  @override
  State<RemHome> createState() => _RemHomeState();
}

class _RemHomeState extends State<RemHome> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeWidget(),
    RemLoyalty(),
    RemHistoria(),
    RemPerfil(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        extendBody: true,
        bottomNavigationBar: BottomNavigationBar(
            elevation: 0,
            // to get rid of the shadow
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.green,
            unselectedItemColor: Colors.grey,
            onTap: _onItemTapped,
            backgroundColor: Color(0x00ffffff),
            // transparent, you could use 0x44aaaaff to make it slightly less transparent with a blue hue.
            type: BottomNavigationBarType.fixed,
            //ESTE LO HACE TRANSPARENTE
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.heart_broken_sharp),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.message_outlined),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: '',
              ),
            ]),
      ),
    );
  }
}

