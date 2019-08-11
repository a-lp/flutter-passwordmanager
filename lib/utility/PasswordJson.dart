import 'dart:convert';
import 'package:encrypt/encrypt.dart' as Encrypt;
import 'package:json_annotation/json_annotation.dart';

part 'PasswordJson.g.dart';

@JsonSerializable()
class PasswordJson {
  PasswordJson(this.id, this.tipo, this.password);
  String password;
  int tipo, id;

  /// A necessary factory constructor for creating a new User instance
  /// from a map. Pass the map to the generated `_$UserFromJson()` constructor.
  /// The constructor is named after the source class, in this case User.
  factory PasswordJson.fromJson(Map<String, dynamic> json) =>
      _$PasswordJsonFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$PasswordJson`.
  Map<String, dynamic> toJson() => _$PasswordJsonToJson(this);

  String decifraValore(cypherText, key) {
    var iv;
    String decrypted;
    key = Encrypt.Key.fromUtf8(key);
    iv = Encrypt.IV.fromLength(16);
    final encrypter = Encrypt.Encrypter(Encrypt.AES(key, iv));
    decrypted = encrypter.decrypt(Encrypt.Encrypted.fromBase64(cypherText));
    return decrypted;
  }

  String cifraValore(plaintext, key) {
    key = Encrypt.Key.fromUtf8(key);
    var iv = Encrypt.IV.fromLength(16);
    var encrypter = Encrypt.Encrypter(Encrypt.AES(key, iv));
    Encrypt.Encrypted out = encrypter.encrypt(plaintext);
    return out.base64;
  }

  @override
  String toString() {
    return "Id: " +
        this.id.toString() +
        ", Valore: " +
        this.password +
        ", Tipo: " +
        this.tipo.toString();
  }

  bool equals(PasswordJson compare) {
    return this.id==compare.getId();
  }

  String getPassword() {
    return this.password;
  }

  int getId() {
    return this.id;
  }

  int getTipo() {
    return this.tipo;
  }
}

class Boolean {}

void main() {
  String json =
      '[{"title":"Amazon","value":"banana","icon":"assets/fb.png"},{"title":"Amazon1","value":"banana","icon":"assets/fb.png"},{"title":"Amazon2","value":"banana","icon":"assets/fb.png"}]';
  List<dynamic> lista = jsonDecode(json);
  List<PasswordJson> passwords = [];
  lista.forEach((psw) {
    passwords.add(PasswordJson.fromJson(psw));
  });
  passwords.forEach((elemento) {
    print(elemento.toString());
  });
  print(jsonEncode(passwords));
}
