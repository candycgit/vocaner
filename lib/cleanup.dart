import 'package:flutter/material.dart';
import 'package:vocaner/database.dart';

class CleanUpPage extends StatefulWidget {
  @override
  _CleanUpPageState createState() => new _CleanUpPageState();
}

class _CleanUpPageState extends State<CleanUpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: new Text('Clean Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
            child: Container(
          child: Column(
            children: [
              Text('Would you like to delete all words?',
                  style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic)),
              RaisedButton(
                child: Text("YES"),
                color: Colors.deepOrangeAccent,
                textColor: Colors.white,
                onPressed: () => _cleanUp(),
              ),
            ],
          ),
        )),
      ),
    );
  }

  void _cleanUp() async {
    await DBAdapter.db.deleteAllWords();
    navigateToClosedDrawerAndDictionary();
  }

  void navigateToClosedDrawerAndDictionary() {
    Navigator.pop(context);
    Navigator.pop(context);
  }
}
