import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pswmanager/utility/PasswordJson.dart';
import 'package:pswmanager/old/1.0/Storage.dart';
import 'package:pswmanager/old/1.0/CardItem.dart';
import 'package:pswmanager/utility/esys_flutter_share.dart';

class HomePage extends StatefulWidget {
  final Storage storage;
  final String keyEnc;
  HomePage({Key key, @required this.storage, @required this.keyEnc})
      : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> cards = new List<dynamic>(); //Lista in memoria
  List<Color> colors = [Color.fromARGB(125, 219, 232, 255), Colors.white];
  List<dynamic> passwordList =
      new List<CardItem>(); //Lista memorizzata in locale

  @override
  void initState() {
    super.initState();
    print("init");
    updateList();
  }

  void updateList() {
    try {
      this.cards=[new AddCard()];
      widget.storage.readText().then((String text) {
        if (text != null && text != "") {
          this.passwordList = jsonDecode(text);
          setState(() {
            passwordList.forEach((item) {
              this.cards.add(new CardItem(
                  keyEnc: widget.keyEnc,
                  id: item["id"],
                  title: item["titolo"],
                  icon: item["icon"],
                  type: item["tipo"],
                  password: item["password"]));
            });
          });
        }
      });
    } catch (e) {
      print("Errore main");
    }
  }

  void _rimuoviPassword(int id) {
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
      storage.writeText(jsonEncode(passwords));
      print(passwords);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(actions: [
        PopupMenuButton(
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem(
                child: GestureDetector(
                  onTap: () async {
                    print("Esporta");
                    widget.storage.getDir().then((path) {
                      print(path);
                      _shareText(path);
                    });
                  },
                  child: Text("Esporta"),
                ),
              ),
              PopupMenuItem(
                child: GestureDetector(
                  onTap: () {
                    var _path = FilePicker.getFilePath(type: FileType.ANY);
                    _path.then((onValue) {
                      widget.storage.uploadBackup(onValue).then((file) {
                        updateList();
                      });
                    });
                    print("$_path");
                  },
                  child: Text("Importa"),
                ),
              ),
            ];
          },
        )
      ]),
      body: Column(
        children: [
          Flexible(
              child: ListView.builder(
            itemCount: cards.length,
            itemBuilder: (context, index) {
              print(cards.length);
              final i = (index + 1) % cards.length;
              final item = cards[i];
              if (i == 0) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      cards.add(new CardItem(
                          password: "",
                          //id: cards.length + 1,
                          keyEnc: widget.keyEnc));
                    });
                  },
                  child: item,
                );
              }
              return Dismissible(
                key: Key(item.id.toString()),
                onDismissed: (direction) {
                  _rimuoviPassword(item.id);
                  setState(() {
                    cards.removeAt(i);
                  });
                  print(cards);
                },
                background: Container(color: Colors.grey),
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(vertical: 5.0),
                    color: colors[i % 2],
                    child: cards[i]),
              );
            },
          )),
        ],
      ),
    );
  }

  Future _shareText(String path) async {
    try {
      final ByteData bytes = await rootBundle.load(path);
      Share.file('Esporta password', "password-manager-backup.txt", bytes.buffer.asUint8List(),
          'text/txt');
    } catch (e) {
      print('error: $e');
    }
  }
}

class AddCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      child: Icon(Icons.add_circle, color: Colors.blueAccent, size: 36.0),
    );
  }
}
