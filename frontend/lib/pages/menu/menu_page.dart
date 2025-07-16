import 'package:flutter/material.dart';

class MenuPage  extends StatelessWidget{
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:const Text("MENU",style: TextStyle(
          color: Color.fromARGB(255, 168, 222, 170),
          fontSize: 50 ,
          fontWeight: FontWeight.w500
        ),),
        backgroundColor: const Color.fromARGB(255, 191, 191, 191),
      ),
      body: Container(color: Colors.white, child: const Text("body"),),
    );
  }

}