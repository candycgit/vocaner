import 'dart:io';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:vocaner/database.dart';
import 'package:vocaner/model.dart';

class ImportPage extends StatefulWidget {
  @override
  _ImportPageState createState() => new _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  static final formatter = new DateFormat('yyyyMMdd');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: new Text('Import')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Container(
            child: Column(
              children: [
                Text('Click the button to select CSV file',
                    style:
                        TextStyle(fontSize: 20, fontStyle: FontStyle.italic)),
                Text('CSV format: "name";"transription";"description".'),
                RaisedButton(
                  child: Text("GO"),
                  color: Colors.lightBlue,
                  textColor: Colors.white,
                  onPressed: () => _import(context),
                ),
                Text('Click the button to select CSV file',
                    style:
                        TextStyle(fontSize: 20, fontStyle: FontStyle.italic)),
                Text(
                    'CSV format: "name";"transription";"description";"date";"status".'),
                RaisedButton(
                  child: Text("GO"),
                  color: Colors.lightBlue,
                  textColor: Colors.white,
                  onPressed: () => _importEnhanced(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _import(context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        });
    await _importCSV(await _getFile());
    navigateToClosedDrawerAndDictionary();
  }

  Future<void> _importCSV(File file) async {
    Stream inputStream =
        file.openRead().transform(utf8.decoder).transform(new LineSplitter());
    List<Word> list = new List();
    await for (String line in inputStream) {
      try {
        List<String> row = line.split(';');
        Word word = new Word();
        word.name = _trim(row[0]);
        word.transcription = _trim(row[1]);
        word.description = _trimDescription(row[2]);
        list.add(word);
      } catch (e) {
        print(e.toString());
      }
    }
    for (Word w in list) {
      try {
        await DBAdapter.db.createWord(w);
      } catch (e) {
        print(e.toString());
      }
    }
  }

  void _importEnhanced(context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        });

    await _importCSVEnhanced(await _getFile());
    navigateToClosedDrawerAndDictionary();
  }

  Future<void> _importCSVEnhanced(File file) async {
    Stream inputStream =
        file.openRead().transform(utf8.decoder).transform(new LineSplitter());
    List<Word> list = new List();
    await for (String line in inputStream) {
      try {
        List<String> row = line.split(';');
        Word word = new Word();
        word.name = _trim(row[0]);
        word.transcription = _trim(row[1]);
        word.description = _trimDescription(row[2]);
        word.date = _trim(row[3]);
        word.status = int.parse(_trim(row[4]));
        list.add(word);
      } catch (e) {
        print(e.toString());
      }
    }
    for (Word w in list) {
      try {
        await DBAdapter.db.createFullWord(w);
      } catch (e) {
        print(e.toString());
      }
    }
  }

  Future<File> _getFile() async {
    Directory directory = await getExternalStorageDirectory();
    String timestamp = formatter.format(DateTime.now()).toString();
    String filePath = directory.path + '/' + timestamp + '.csv';
    File file = new File(filePath);
    print(filePath);
    return file;
  }

  String _trim(String row) {
    String result = row;
    result = result.trim();
    if (result.length > 1 && result.startsWith('"') && result.endsWith('"')) {
      result = result.substring(1, result.length - 1);
    }
    return result.replaceAll('"', '\'').toLowerCase();
  }

  String _trimDescription(String row) {
    String result = _trim(row);
    return result.replaceAll('\'', '');
  }

  void navigateToClosedDrawerAndDictionary() {
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pop(context);
  }
}
