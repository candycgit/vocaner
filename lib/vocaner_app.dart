import 'package:flutter/material.dart';
import 'package:vocaner/cleanup.dart';
import 'package:vocaner/database.dart';
import 'package:vocaner/import.dart';
import 'package:vocaner/model.dart';
import 'package:vocaner/word_form.dart';

class VocanerApp extends StatefulWidget {
  @override
  _DictionaryState createState() => _DictionaryState();
}

class _DictionaryState extends State<VocanerApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Vocaner")),
      body: FutureBuilder<List<Word>>(
        future: DBAdapter.db.getAllWords(),
        builder: _buildList,
      ),
      drawer: _buildDrawer(),
      floatingActionButton: _createWord(),
    );
  }

  Widget _buildList(BuildContext context, AsyncSnapshot<List<Word>> snapshot) {
    if (snapshot.hasData) {
      return ListView.builder(
        itemCount: snapshot.data.length,
        itemBuilder: (BuildContext context, int index) {
          Word word = snapshot.data[index];
          return _buildRow(context, index, word);
        },
      );
    } else if (snapshot.hasError) {
      return Text("${snapshot.error}");
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }

  ListTile _buildRow(BuildContext context, int index, Word word) {
    return ListTile(
      title: Text(word.name + '   [' + word.transcription + ']'),
      subtitle: Text(word.description),
      isThreeLine: true,
      leading: Checkbox(
        onChanged: (bool value) {
          if (value) {
            word.setStatus();
          } else {
            word.resetStatus();
          }
          DBAdapter.db.updateWord(word);
          setState(() {});
        },
        value: !word.isNew(),
      ),
      onLongPress: () {
        _navigateToUpdateWord(word);
      },
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
        child: ListView(
      children: <Widget>[
        ListTile(
          title: Text('Remember'),
          onTap: () {},
        ),
        ListTile(
          title: Text('Repeat'),
          onTap: () {},
        ),
        Divider(),
        ListTile(
          title: Text('Import'),
          onTap: () {
            _navigateToImport();
          },
        ),
        ListTile(
          title: Text('Clean up'),
          onTap: () {
            _navigateToCleanUp();
          },
        ),
      ],
    ));
  }

  FloatingActionButton _createWord() {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () async {
        _navigateToCreateWord();
        setState(() {});
      },
    );
  }

  void _navigateToCreateWord() {
    Navigator.push(
      context,
      new MaterialPageRoute(
          builder: (context) => new WordFormPage(
                word: new Word(),
              )),
    );
  }

  void _navigateToUpdateWord(word) {
    Navigator.push(
      context,
      new MaterialPageRoute(
          builder: (context) => WordFormPage(
                word: word,
              )),
    );
  }

  void _navigateToImport() {
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new ImportPage()),
    );
  }

  void _navigateToCleanUp() {
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new CleanUpPage()),
    );
  }
}
