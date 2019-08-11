import 'dart:io';

import 'package:path_provider/path_provider.dart';

class Storage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/password.txt');
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
    String valueBackup = await backup.readAsString();
    final file = await _localFile;
    return file.writeAsString(valueBackup);
  }

  Future<String> getDir() async{
    final path = await _localPath;
    return '$path/password.txt';
  }
  

  Future<File> writeText(String text) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString('$text');
  }
}
