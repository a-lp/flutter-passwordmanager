import 'package:flutter/material.dart';
import 'package:pswmanager/LoginPage.dart';

void main() => runApp(PasswordManager());

class PasswordManager extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Password Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        fontFamily: 'Nunito',
      ),
      home: LoginPage()
    );
  }
}
