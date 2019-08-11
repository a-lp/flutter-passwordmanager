/*import 'dart:collection';
import 'dart:convert';

import 'package:password_hash/password_hash.dart';
import 'package:encrypt/encrypt.dart' as Encrypt;
import 'package:pswmanager/utility/PasswordJson.dart';
import 'package:pswmanager/utility/Storage.dart';*/

main() {
  /*DateTime time = new DateTime.now().toUtc();
  String year, month, day, newId;
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
  newId = year +
      month +
      day +
      time.hour.toString() +
      time.minute.toString() +
      time.second.toString();
  print(newId);*/
  /*List<PasswordJson> passwords = [
    new PasswordJson(1, 0, "titolo1", "password1", "icona"),
    new PasswordJson(2, 0, "titolo2", "password2", "icona"),
  ];
  String endoed = jsonEncode(passwords);
  List<dynamic> newPass = jsonDecode(endoed);
  Map<String, String> sale = new HashMap();
  sale["salt"]="salegenerato";
  newPass.add(sale);
  print(sale["salt"]);*/
  /*var generator = new PBKDF2();
  var salt = Salt.generateAsBase64String(24);
  var hash = generator.generateBase64Key("mytopsecretpassword", salt, 1000, 24);
  print(hash);

  var iv = Encrypt.IV.fromLength(16);
  var key = Encrypt.Key.fromUtf8(hash);
  var encrypter = Encrypt.Encrypter(Encrypt.AES(key, iv));
  Encrypt.Encrypted out = encrypter.encrypt("testo super segreto");

  print(encrypter.decrypt(Encrypt.Encrypted.fromBase64(out.base64)));*/
}
