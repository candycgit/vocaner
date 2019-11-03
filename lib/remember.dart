import 'package:flutter/material.dart';
import 'package:vocaner/database.dart';
import 'package:vocaner/model.dart';

class RememberPage extends StatefulWidget {
  @override
  _RememberPageState createState() => new _RememberPageState();
}

class _RememberPageState extends State<RememberPage> {
  final _formKey = new GlobalKey<FormState>();
  Future _future;
  final Map<int, String> dragMap = {};

  @override
  void initState() {
    _future = DBAdapter.db.getNewWords(6);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: new Text('Remember')),
      body: FutureBuilder<List<Word>>(
        future: _future,
        builder: _buildTraining,
      ),
    );
  }

  Widget _buildTraining(
      BuildContext context, AsyncSnapshot<List<Word>> snapshot) {
    if (snapshot.hasData) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: _getForm(snapshot.data),
      );
    } else if (snapshot.hasError) {
      return Text("${snapshot.error}");
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }

  Form _getForm(List<Word> words) {
    List<Widget> children = [];
    List<int> ids = [];

    _prepareAgenda(children, words, ids);
    _prepareTranslationTest(children, words, ids);
    _prepareWritingTest(children, words, ids);

    _prepareSubmit(children, words, ids);

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
          child: Column(
        children: children,
      )),
    );
  }

  void _prepareAgenda(List<Widget> children, List<Word> words, List<int> ids) {
    for (Word word in words) {
      ids.add(word.id);
      children.add(Text(word.id.toString() + '  ' + word.name,
          style: TextStyle(fontSize: 20)));
      children.add(Text('[' + word.transcription + ']  ',
          style: TextStyle(fontSize: 18)));
      children.add(Text(word.description, style: TextStyle(fontSize: 18)));
      children.add(Padding(
          padding: EdgeInsets.fromLTRB(0, 16, 0, 16), child: Divider()));
    }
    children.add(Padding(
      padding: EdgeInsets.all(50),
    ));
  }

  void _prepareTranslationTest(
      List<Widget> children, List<Word> words, List<int> ids) {
    words.shuffle();
    List<Widget> sourceColumnChildren = new List();
    for (Word word in words) {
      sourceColumnChildren.add(Draggable(
        child: Container(alignment: Alignment.center, child: Text(word.name)),
        data: word,
        feedback:
            Container(alignment: Alignment.center, child: Text(word.name)),
        childWhenDragging:
            Container(color: Colors.grey, height: 50, width: 100),
      ));
    }
    Column sourceColumn = Column(
      children: sourceColumnChildren,
    );

    words.shuffle();
    List<Widget> targetColumnChildren = new List();
    for (Word word in words) {
      targetColumnChildren.add(
        Container(alignment: Alignment.center, child: Text(word.description)),
      );
      targetColumnChildren.add(DragTarget(
        builder: (BuildContext context, List<Word> candidateData,
            List rejectedData) {
          if (dragMap.containsKey(word.id)) {
            return Container(
                alignment: Alignment.center, child: Text(dragMap[word.id]));
          }
          return Container(color: Colors.grey, height: 50, width: 100);
        },
        onWillAccept: (Word candidate) {
          if (dragMap.containsKey(word.id)) {
            return false;
          }
          return true;
        },
        onAccept: (Word candidate) {
          dragMap[word.id] = candidate.name;
          if (word.id != candidate.id) {
            ids.remove(word.id);
            ids.remove(candidate.id);
          }
        },
      ));
    }
    Column targetColumn = Column(
      children: targetColumnChildren,
    );

    children.add(Padding(
        padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
        child: Row(
          children: [sourceColumn, targetColumn],
        )));
  }

  void _prepareWritingTest(
      List<Widget> children, List<Word> words, List<int> ids) {
    words.shuffle();
    for (Word word in words) {
      children.add(Padding(
          padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
          child: TextFormField(
            decoration: InputDecoration(labelText: word.description),
            keyboardType: TextInputType.text,
            validator: (val) {
              if (val.length == 0) {
                return 'Enter name';
              }
              if (val != word.name) {
                if (ids.contains(word.id)) {
                  ids.remove(word.id);
                }
                return 'Should be ' + word.name;
              }
              return null;
            },
          )));
    }
  }

  void _prepareSubmit(List<Widget> children, List<Word> words, List<int> ids) {
    children.add(Padding(
        padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
        child: RaisedButton(
          child: Text('SUBMIT'),
          color: Colors.lightBlue,
          onPressed: () => _confirm(context, words, ids),
          textColor: Colors.white,
        )));
  }

  Future<void> _confirm(
      BuildContext context, List<Word> words, List<int> ids) async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
    } else {
      return null;
    }
    await _updateWords(words, ids);
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("Learned"),
            content: new Text(ids.toString()),
            actions: <Widget>[
              new FlatButton(
                child: new Text("OK"),
                onPressed: () {
                  navigateToClosedDrawerAndDictionary();
                },
              ),
            ],
          );
        });
  }

  Future<void> _updateWords(List<Word> words, List<int> ids) async {
    for (Word word in words) {
      if (ids.contains(word.id)) {
        word.setStatus();
        await DBAdapter.db.updateWord(word);
      }
    }
  }

  void navigateToClosedDrawerAndDictionary() {
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pop(context);
  }
}
