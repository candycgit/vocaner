import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vocaner/database.dart';
import 'package:vocaner/model.dart';

class ExportPage extends StatefulWidget {
  @override
  _ExportPageState createState() => new _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  static final formatter = new DateFormat('yyyyMMddHHmmss');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: new Text('Export')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
            child: Container(
          child: Column(
            children: [
              Text('Click the button to create CSV file in the application directory',
                  style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic)),
              Text(
                  'CSV format: "name";"transription";"description";"date";"status".'),
              RaisedButton(
                child: Text("GO"),
                color: Colors.lightBlue,
                textColor: Colors.white,
                onPressed: () => _export(context),
              ),
            ],
          ),
        )),
      ),
    );
  }

  void _export(context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        });
    Directory directory = await getApplicationDocumentsDirectory();
    String timestamp = formatter.format(DateTime.now()).toString();
    String filePath = directory.path + '/' + timestamp + '.csv';
    File file = new File(filePath);
    print(filePath);
    await _exportCSV(file);
    navigateToClosedDrawerAndDictionary();
  }

  Future<void> _exportCSV(File file) async {
    IOSink sink = file.openWrite();
    List<Word> words = await DBAdapter.db.getAllWords();
    for (Word w in words) {
      try {
        String line = '"' + w.name + '"' + ';';
        line += '"' + w.transcription + '"' + ';';
        line += '"' + w.description + '"' + ';';
        line += w.date + ';';
        line += w.status.toString();
        line += '\n';
        sink.write(line);
      } catch (e) {
        print(e.toString());
      }
    }
    await sink.flush();
    await sink.close();
  }

  void navigateToClosedDrawerAndDictionary() {
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pop(context);
  }
}
