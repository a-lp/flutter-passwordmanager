import 'package:flutter/material.dart';
import 'package:pswmanager/old/1.0/HomePage.dart';
import 'package:pswmanager/old/1.0/Storage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _pswController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 48.0,
        child: Image.asset('assets/key.png'),
      ),
    );

    final password = TextFormField(
      controller: _pswController,
      autofocus: false,
      obscureText: true,
      decoration: InputDecoration(
        hintText: 'Password',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: () {
          // var generator = new PBKDF2();
          // var salt = Salt.generateAsBase64String(24); 
          // String password = generator.generateBase64Key(
          //     _pswController.text, salt, 1000, 24);
          String password=_pswController.text;
          if (_pswController.text.length < 16) {
            password = password + "0" * (16 - password.length);
          } else if (_pswController.text.length > 16 &&
              _pswController.text.length < 24) {
            password = password + "0" * (24 - password.length);
          } else if (_pswController.text.length > 24 &&
              _pswController.text.length < 32) {
            password = password + "0" * (32 - password.length);
          } else if (_pswController.text.length > 32) {
            password = password.substring(0, 32);
          }
          // showDialog(
          //     context: context,
          //     builder: (BuildContext context) {
          //       return new AlertDialog(
          //         content: new Text("Inserisci 16 caratteri"),
          //       );
          //     });
          // Navigator.of(context).pushNamed(HomePage.tag);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      HomePage(storage: Storage(), keyEnc: password)));
        },
        padding: EdgeInsets.all(12),
        color: Colors.lightBlueAccent,
        child: Text('Log In', style: TextStyle(color: Colors.white)),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            logo,
            SizedBox(height: 48.0),
            password,
            SizedBox(height: 24.0),
            loginButton,
            IconButton(
              icon: Icon(Icons.info_outline),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return new AlertDialog(
                        content: new Text(
                            "1) Inserire una chiave per poter cifrare/decifrare le password\n2) Premere il bottone di accesso\n3) Visualizza, modifica, cancella, esporta o importa le password.\n\nNOTA: Puoi modificare solamente le password di cui conosci la chiave di cifratura!"),
                      );
                    });
              },
            )
          ],
        ),
      ),
    );
  }
}
