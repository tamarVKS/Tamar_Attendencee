import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../login_screen.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState(){
    super.initState();

    Timer(Duration(seconds:10),(){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          children: [
            Image.asset('assets/Group.png',
              height: 34,
              width: 34,
            ),
            SizedBox(
              height: 34,
            ),

            Text("Loading....",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                fontFamily: "MainFont",
                color: Colors.blue,
              ),),

            SizedBox(
              height: 12,
            ),

            Text("Mark you attendance at",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15,
                fontFamily: "MainFont",
                color: Colors.black26,
              ),),

            Text("Attendity",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: "MainFont",
                color: Colors.black,
              ),),


            SizedBox(
              height: 44,
            ),

            Text("There is no time like the \n PRESENT",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: "MainFont",
                color: Colors.black,
              ),),
          ],
        )

    );
  }
}