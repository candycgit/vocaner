import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:vocaner/database.dart';
import 'package:vocaner/model.dart';

class ExportPage extends StatefulWidget {
  @override
  _ExportPageState createState() => new _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
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
              Text('Click the button to select folder for CSV file',
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
    final File folder =
        await FilePicker.getFile(type: FileType.CUSTOM, fileExtension: 'csv');
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        });
    File file = File(folder.path + DateTime.now().toString() + '.csv');
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
