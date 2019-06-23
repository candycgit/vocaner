import 'package:flutter/material.dart';
import 'package:vocaner/database.dart';
import 'package:vocaner/model.dart';

class WordFormPage extends StatefulWidget {
  final Word word;
  WordFormPage({Key key, @required this.word}) : super(key: key);

  @override
  _WordFormPageState createState() => new _WordFormPageState(word);
}

class _WordFormPageState extends State<WordFormPage> {
  final Word word;
  _WordFormPageState(this.word);

  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final formKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(''), actions: <Widget>[
        // action button
        IconButton(
          icon: Icon(Icons.done),
          onPressed: () {
            _save();
          },
        )
      ]),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _getForm(),
      ),
      floatingActionButton: _confirmAndDelete(),
      key: scaffoldKey,
    );
  }

  Form _getForm() {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: 'name'),
            initialValue: word.name,
            keyboardType: TextInputType.text,
            onSaved: (val) => word.name = val,
            validator: (val) => val.length == 0 ? "Enter name" : null,
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'transcription'),
            initialValue: word.transcription,
            keyboardType: TextInputType.text,
            onSaved: (val) => word.transcription = val,
            validator: (val) => val.length == 0 ? 'Enter transcription' : null,
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'description'),
            initialValue: word.description,
            keyboardType: TextInputType.text,
            onSaved: (val) => word.description = val,
            validator: (val) => val.length == 0 ? 'Enter description' : null,
          )
        ],
      ),
    );
  }

  void _save() {
    if (this.formKey.currentState.validate()) {
      formKey.currentState.save();
    } else {
      return null;
    }
    if (word.id == null) {
      DBAdapter.db.createWord(word);
    } else {
      DBAdapter.db.updateWord(word);
    }
    navigateToDictionary();
  }

  FloatingActionButton _confirmAndDelete() {
    if (word.id == null) {
      return null;
    }
    return FloatingActionButton(
        child: Icon(Icons.delete),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              // return object of type Dialog
              return AlertDialog(
                title: Text("Word will be deleted"),
                actions: <Widget>[
                  // usually buttons at the bottom of the dialog
                  FlatButton(
                    child: Text("Cancel"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  FlatButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      DBAdapter.db.deleteWord(word.id);
                      navigateToDictionary();
                    },
                  )
                ],
              );
            },
          );
        });
  }

  void navigateToDictionary() {
    Navigator.pop(context);
  }
}
