import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:encrypt/encrypt.dart' as Encrypt;
import 'package:flutter/material.dart';
import 'package:pswmanager/utility/PasswordJson.dart';
import 'package:pswmanager/utility/Storage.dart';
import 'dart:core';

class CardItem extends StatefulWidget {
  final PasswordJson passwordJson;
  final String keyEnc;

  CardItem({Key key, @required this.keyEnc, @required this.passwordJson})
      : super(key: key);
  @override
  _CardItemState createState() => _CardItemState();
}

class _CardItemState extends State<CardItem> {
  TextEditingController _pswController = TextEditingController();
  /* Icone e tipi hardcoded */
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
    if (widget.passwordJson.getPassword() != null) {
      try {
        print("Cifrato: "+widget.passwordJson.getPassword() + "\t keyEnc = "+widget.keyEnc);
        if (widget.passwordJson.getPassword() != "") {
          _pswController.text =
              _decifraPassword(widget.passwordJson.getPassword(), widget.keyEnc);
          print(_pswController.text);
        }
        pswCorrect = true;
      } catch (e) {           /* La chiave di cifratura inserita non è corretta */
        print(e);
        _pswController.text = "****************";
      }
    }
    if (widget.passwordJson.getTipo() == null)
      type = 4;
    else
      type = widget.passwordJson.getTipo();
  }

  String _decifraPassword(cypherText, key) {
    var iv;
    String decrypted;
    key = Encrypt.Key.fromUtf8(key);
    iv = Encrypt.IV.fromLength(16);
    final encrypter = Encrypt.Encrypter(Encrypt.AES(key, iv, mode: Encrypt.AESMode.cbc));
    decrypted = encrypter.decrypt(Encrypt.Encrypted.fromBase64(cypherText));
    return decrypted;
  }

  String _cifraPassword(plaintext, key) {
    key = Encrypt.Key.fromUtf8(key);
    var iv = Encrypt.IV.fromLength(16);
    var encrypter = Encrypt.Encrypter(Encrypt.AES(key, iv, mode: Encrypt.AESMode.cbc));
    Encrypt.Encrypted out = encrypter.encrypt(plaintext);
    return out.base64;
  }

  /* Funzione per la memorizzazione delle password. Se queste sono già state inserite, la funzione le aggiornerà */
  /* cancellando la vecchia occorrenza e inserendo quella nuova. */
  Future<bool> _memorizzaLocale(int id, int type, String password) async {
    Storage storage = new Storage("password.txt");
    var delete;
    List<dynamic> passwords = new List<PasswordJson>();
    storage.readText().then((result) {
      if (result != null && result != "") passwords = jsonDecode(result);     /* Cerco se la password da inserire è già nella lista  */
      passwords.forEach((element) {                                           /* delle password. In tal caso, la rimuovo e la reinserisco. */
        PasswordJson pswElement = PasswordJson.fromJson(element);
        if (pswElement.getId() == id) {
          delete = element;
        }
      });
      passwords.remove(delete);
      PasswordJson newPsw =
          new PasswordJson(id, type, _cifraPassword(password, widget.keyEnc)); /* Creo la nuova password, la inserisco nella lista */
      passwords.add(newPsw);                                                   /* e la memorizza su file. */
      storage.writeText(jsonEncode(passwords));
      print(passwords);
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
                        _memorizzaLocale(widget.passwordJson.getId(), type,
                                _pswController.text)
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
