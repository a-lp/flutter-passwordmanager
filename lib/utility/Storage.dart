import 'dart:io';

import 'package:path_provider/path_provider.dart';

class Storage {
  String fileName;

  Storage(this.fileName);
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/'+this.fileName);
  }

  Future<String> readText() async {
    try {
      final file = await _localFile;

      // Read the file
      String contents = await file.readAsString();

      return contents;
    } catch (e) {
      // If encountering an error, return 0
      return "";
    }
  }

  Future<File> uploadBackup(String backupPath) async{
    File backup = new File(backupPath);
    String localPath = await _localPath;
    String valueBackup = await backup.readAsString();
    String sale = valueBackup.split("&&&")[1].replaceAll('"',"");
    String psw = valueBackup.split("&&&")[0];
    File filePass = new File(localPath + "/password.txt");
    File filesalt = new File(localPath + "/salt.txt");
    await filePass.writeAsString(psw);
    await filesalt.writeAsString(sale);
    return null;
  }

  Future<String> getDir() async{
    final path = await _localPath;
    return '$path';
  }
  

  Future<File> writeText(String text) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString('$text');
  }
}
