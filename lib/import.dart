import 'dart:io';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:vocaner/database.dart';
import 'package:vocaner/model.dart';

class ImportPage extends StatefulWidget {
  @override
  _ImportPageState createState() => new _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
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
                  style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic)),
              Text('CSV format: "name";"transription";"description".'),
              RaisedButton(
                child: Text("GO"),
                color: Colors.lightBlue,
                textColor: Colors.white,
                onPressed: () => _importCSV(),
              ),
            ],
          ),
        )),
      ),
    );
  }

  void _importCSV() async {
    final File file =
        await FilePicker.getFile(type: FileType.CUSTOM, fileExtension: 'csv');
    Stream<List> inputStream = file.openRead();
    List<Word> list = new List();
    inputStream
        .transform(utf8.decoder) // Decode bytes to UTF-8.
        .transform(new LineSplitter()) // Convert stream to individual lines.
        .listen((String line) {
      List row = line.split(';'); // split by comma
      Word word = new Word();
      word.name = row[0];
      word.transcription = row[1];
      word.description = row[2];
      list.add(word);
    }, onDone: () {
      for (Word w in list) {
        DBAdapter.db.createWord(w);
      }
      navigateToClosedDrawerAndDictionary();
    }, onError: (e) {
      print(e.toString());
    });
  }

  void navigateToClosedDrawerAndDictionary() {
    Navigator.pop(context);
    Navigator.pop(context);
  }
}
