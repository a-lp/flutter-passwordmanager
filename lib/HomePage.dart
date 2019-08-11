import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pswmanager/utility/PasswordJson.dart';
import 'package:pswmanager/utility/Storage.dart';
import 'package:pswmanager/CardItem.dart';
import 'package:pswmanager/utility/esys_flutter_share.dart';
import 'package:password_hash/password_hash.dart';

class HomePage extends StatefulWidget {
  final String keyEnc;                                    /* Chiave di cifratura in chiaro */
  final Storage storagePassword = new Storage("password.txt");    /* Gestore del file password.txt contenente le password cifrate */
  final Storage storageSalt = new Storage("salt.txt");    /* Gestore del file salt.txt contenente il sale per la cifratura */
  HomePage({Key key, @required this.keyEnc}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> cards = new List<dynamic>();      /* Card che vengono mostrate */
  List<Color> colors = [Color.fromARGB(125, 219, 232, 255), Colors.white];
  List<dynamic> passwordList = new List();        /* Lista delle password */
  String keySalted;     /* Chiave di cifratura finale (salata) */
  int lastId = 0;       /* lastID viene utilizzato per generare nuovi ID per nuove password */

  @override
  void initState() {
    super.initState();
    updateList();
  }

  /* La funzione updateList() mi permette di gestire le password memorizzate in memoria e quelle memorizzate su file. */
  /* Per gestire la persistenza delle password in memoria, è necessario salvarle su file.                             */
  void updateList() {
    try {
      this.cards = [
        new AddCard()         /* Inserisco il bottone per aggiungere nuove password */
      ]; 
      var generator = new PBKDF2();
      widget.storageSalt.readText().then((sale) {      /* Leggo il sale da file */
        print("Sale: " + sale);
        this.keySalted = generator.generateBase64Key(     /* Effettuo la salatura della chiave di cifratura */
            widget.keyEnc,
            sale,
            1000,
            24);
        widget.storagePassword.readText().then((text) {        /* Leggo il file contenenti le password */
          if (text != null && text.length > 0) {
            print("Password: " + text);
            this.passwordList = jsonDecode(text);
            if (passwordList.length > 0) {
              setState(() {
                this.lastId = passwordList[passwordList.length - 1]["id"];    /* Prendo l'ultimo ID generato */
                passwordList.forEach((item) {
                  this.cards.add(
                    new CardItem(keyEnc: this.keySalted, passwordJson: new PasswordJson.fromJson(item))
                    // new CardItem(
                    //   keyEnc: this.keySalted,
                    //   id: item["id"],
                    //   title: item["titolo"],
                    //   icon: item["icon"],
                    //   type: item["tipo"],
                    //   password: item["password"])
                  );
                });
              });
            }
          }
        });
      });
    } catch (e) {
      print("Errore main");
    }
  }

  /* Funzione per la rimozione delle password da file e memoria. Prende in unput un oggetto PasswordJson, quindi */
  /* controlla che sia presente nella lista delle password in memoria e nel file. Una volta cancellato, aggiorna */
  /* il file in memoria.                                                                                         */
  void _rimuoviPassword(PasswordJson pswRemove) {
    var delete;
    List<dynamic> passwords = new List<PasswordJson>();
    widget.storagePassword.readText().then((result) {         /* Lettura del file password */
      if (result != null && result.length > 0) passwords = jsonDecode(result);
      passwords.forEach((element) {
        PasswordJson pswElement = PasswordJson.fromJson(element);
        if (pswElement.equals(pswRemove)) {
          delete = element;                           /* Ho trovato l'elemento da cancellare */
        }
      });
      passwords.remove(delete);                                 /* Rimuovo dalla memoria l'elemento, quindi */
      widget.storagePassword.writeText(jsonEncode(passwords));  /* aggiorno la lista di password presente nel file*/
      print(passwords);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(actions: [
        /* Barra dei menu' */
        PopupMenuButton(
          itemBuilder: (BuildContext context) {
            return [
              /* Menu' per l'esportazione delle password in formato JSON/txt */
              PopupMenuItem(
                child: GestureDetector(
                  onTap: () async {
                    widget.storagePassword.getDir().then((path) {
                      _shareText(path);
                    });
                  },
                  child: Text("Esporta"),
                ),
              ),
              /* Menu' per l'importazione delle password in formato JSON/txt */
              PopupMenuItem(
                child: GestureDetector(
                  onTap: () {
                    var _path = FilePicker.getFilePath(type: FileType.ANY);
                    _path.then((onValue) {
                      widget.storagePassword.uploadBackup(onValue).then((file) {
                        updateList();
                      });
                    });
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
          /* Lista scrollabile contenente gli oggetti CardItem con le password */
          Flexible(
              child: ListView.builder(
            itemCount: cards.length,
            itemBuilder: (context, index) {
              print(cards.length);
              final i = (index + 1) % cards.length;
              final item = cards[i];
              if (i == 0) {
                /* Bottone per aggiungere una nuova Card per le password */
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      cards.add(
                        new CardItem(keyEnc: keySalted, passwordJson: new PasswordJson(lastId+1,null,""))
                        // new CardItem(
                        //   password: "", id: lastId + 1, keyEnc: keySalted)
                        );
                      this.lastId++;
                    });
                  },
                  child: item,
                );
              }
              /* Rimozione della card */
              return Dismissible(
                key: Key(item.passwordJson.getId().toString()),
                onDismissed: (direction) {
                  _rimuoviPassword(item.passwordJson);
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

  /* Funzione di esportazione delle password. Il file sarà rinominato con ANNOMESEGIORNO-password-manager-backup.txt     */
  /* Il file conterrà la stringa JSON contenente le password, separato dal sale utilizzato per l'hashing della chiave di */
  /* accesso dai caratteri "&&&".                                                                                        */
  Future _shareText(String path) async {
    try {
      DateTime time = new DateTime.now().toUtc();
      String year, month, day;
      year = time.year.toString();
      if (time.month < 10) {
        month = "0" + time.month.toString();
      } else {
        month = time.month.toString();
      }
      if (time.day < 10) {
        day = "0" + time.day.toString();
      } else {
        day = time.day.toString();
      }
      String fileNameExport =
          day + month + year + "password-manager-backup.txt";
      Storage backup = new Storage(fileNameExport);
      String psw = await widget.storagePassword.readText();
      String salt = await new Storage("salt.txt").readText();
      backup.writeText(psw + "&&&" + salt);
      final ByteData bytes = await rootBundle.load(path + "/" + fileNameExport);
      Share.file('Esporta password', fileNameExport, bytes.buffer.asUint8List(),  /* Apertura del menu' per la scelta del canale di condivisione*/
          'text/txt');
    } catch (e) {
      print('error: $e');
    }
  }
}

/* Widget utilizzato per aggiungere nuove password. */
class AddCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      child: Icon(Icons.add_circle, color: Colors.blueAccent, size: 36.0),
    );
  }
}
