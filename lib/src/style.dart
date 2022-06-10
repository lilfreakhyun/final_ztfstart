import 'package:flutter/material.dart';

var theme = ThemeData(

  iconTheme: IconThemeData(color: Colors.white),
  appBarTheme: AppBarTheme(color: Colors.white, elevation: 1, titleTextStyle: TextStyle(color: Colors.black, fontFamily: 'a엄마의편지', fontSize: 25),
    actionsIconTheme: IconThemeData(color: Colors.black),
  ),
  textTheme: TextTheme(
    bodyText2: TextStyle(color: Colors.black, fontFamily: 'a엄마의편지',fontSize: 18,fontWeight: FontWeight.normal),
  ),
  textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
          primary: Colors.black,
          backgroundColor: Colors.yellow,
          textStyle: TextStyle(fontFamily: 'a엄마의편지',)
      )
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
          elevation: 6,
          primary: Colors.yellow,
          //minimumSize: Size(double.infinity, 46),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          textStyle: TextStyle(
              fontFamily: 'a엄마의편지',
              color: Colors.black,
              fontSize: 20,
              wordSpacing: 2,
              letterSpacing: 2)
      )
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Color.fromARGB(214, 255, 241, 164),
    selectedItemColor: Colors.black,
  ),

);
//side: BorderSide(color: Colors.black, width: 2.5)),