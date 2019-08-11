import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pswmanager/HomePage.dart';
import 'package:pswmanager/utility/Storage.dart';
import 'package:password_hash/password_hash.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _pswController = new TextEditingController();
  Storage storage = new Storage("salt.txt");
  String salt;
  

  @override
  void initState() {
    super.initState();
    /* Lettura del sale da file */
    storage.readText().then((saltSaved) {
      if (saltSaved != null && saltSaved.length > 0) {
            setState(() {
              this.salt = saltSaved;
            });
      }
      /* Se non è stato ancora generato sale, lo si genera e si memorizza in un file */
      else {
        setState(() {
          this.salt = Salt.generateAsBase64String(24);
        });
        storage.writeText(jsonEncode(this.salt));
      }
      print("Sale generato: "+this.salt);
    });
  }

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
        /* Effettua la salatura della paswword utilizzando il sale letto da file */
        onPressed: () {
          if (_pswController.text.length > 0) {     /* Se la password inserita non è vuota, passo alla pagina HomePage */
            Navigator.push(                         /* passando come parametro, la password inserita in chiaro.*/
                context,
                MaterialPageRoute(
                    builder: (context) => HomePage(
                        keyEnc: _pswController.text)));
          } else {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return new AlertDialog(
                    content: new Text(
                        "Non hai inserito nessuna password."),
                  );
                });
          }
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
            /* Sezione informativa */
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
            ),
            SizedBox(height: 24.0),
            Center(child: Text(this.salt==null?"":this.salt),)
          ],
        ),
      ),
    );
  }
}
