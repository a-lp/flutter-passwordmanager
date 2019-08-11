import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:encrypt/encrypt.dart' as Encrypt;
import 'package:flutter/material.dart';
import 'package:pswmanager/utility/PasswordJson.dart';
import 'package:pswmanager/old/1.0/Storage.dart';
import 'dart:core';

class CardItem extends StatefulWidget {
  final String password;
  final String title;
  final String icon;
  final String keyEnc;
  final int type;
  final int id;

  CardItem(
      {Key key,
      this.id,
      this.password,
      this.title,
      this.icon,
      this.type,
      @required this.keyEnc})
      : super(key: key);
  @override
  _CardItemState createState() => _CardItemState();
}

class _CardItemState extends State<CardItem> {
  TextEditingController _pswController = TextEditingController();
  List<String> iconPath = [
    "fb.png",
    "amazon.png",
    "email.png",
    "gmail.png",
    "key.png",
    "microsoft.png"
  ];
  List<String> titles = [
    "Facebook",
    "Amazon",
    "E-Mail",
    "Gmail",
    "Password Generica",
    "Account Microsoft"
  ];
  int type;
  bool pswCorrect = false;
  String value;

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    _pswController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.password != null) {
      try {
        if (widget.password != "") {
          _pswController.text =
              _decifraPassword(widget.password, widget.keyEnc);
        }
        pswCorrect = true;
      } catch (e) {
        print("Chiave errata");
        _pswController.text = "****************";
      }
    }
    if (widget.type == null)
      type = 4;
    else
      type = widget.type;
  }

  String _decifraPassword(cypherText, key) {
    var iv;
    String decrypted;
    key = Encrypt.Key.fromUtf8(key);
    iv = Encrypt.IV.fromLength(16);
    final encrypter = Encrypt.Encrypter(Encrypt.AES(key, iv));
    decrypted = encrypter.decrypt(Encrypt.Encrypted.fromBase64(cypherText));
    return decrypted;
  }

  String _cifraPassword(plaintext, key) {
    key = Encrypt.Key.fromUtf8(key);
    var iv = Encrypt.IV.fromLength(16);
    var encrypter = Encrypt.Encrypter(Encrypt.AES(key, iv));
    Encrypt.Encrypted out = encrypter.encrypt(plaintext);
    return out.base64;
  }

  Future<bool> _memorizzaLocale(int id, int type, String password) async {
    Storage storage = new Storage();
    var delete;
    List<dynamic> passwords = new List<PasswordJson>();
    storage.readText().then((result) {
      if (result != null && result != "") passwords = jsonDecode(result);
      passwords.forEach((element) {
        print(element["id"].toString() + " " + id.toString());
        if (element["id"] == id) {
          delete = element;
        }
      });
      passwords.remove(delete);
      //int id = passwords.length + 1;
      PasswordJson newPsw =
          new PasswordJson(id, type, _cifraPassword(password, widget.keyEnc));
      passwords.add(newPsw);
      storage.writeText(jsonEncode(passwords));
      return true;
    }).catchError((e) {
      print(e);
      return false;
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 9 / 10,
      height: 100,
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          new Expanded(
              child: IconButton(
                  onPressed: () {
                    setState(() {
                      type = (type + 1) % iconPath.length;
                    });
                  },
                  icon: Image.asset("assets/" + iconPath[type])),
              flex: 2),
          new Expanded(
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(titles[type]),
                  TextField(
                    enabled: pswCorrect,
                    maxLines: 2,
                    controller: _pswController,
                  )
                ],
              ),
              flex: 5),
          new Expanded(
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    onPressed: () {
                      if (pswCorrect) {
                        _memorizzaLocale(widget.id, type, _pswController.text)
                            .then((result) {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return new AlertDialog(
                                    content: Text(result
                                        ? "Salvataggio Effettuato"
                                        : "Errore nel salvataggio"));
                              });
                        });
                      }
                    },
                    child: const Text('Salva'),
                  ),
                ],
              ),
              flex: 2),
        ],
      ),
    );
  }
}
