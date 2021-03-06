import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _toDoController = TextEditingController();
  List _toDoList1 = [];
  List _toDoList2 = [];
  List _toDoList3 = [];

  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPos;

  @override
  void initState() {
    super.initState();

    _readData("1").then((data) {
      setState(() {
        _toDoList1 = json.decode(data);
      });
    });
    _readData("2").then((data) {
      setState(() {
        _toDoList2 = json.decode(data);
      });
    });
    _readData("3").then((data) {
      setState(() {
        _toDoList3 = json.decode(data);
      });
    });
  }

  void _addToDo(List lista) {
    setState(() {
      Map<String, dynamic> newToDo = Map();
      newToDo["title"] = _toDoController.text;
      _toDoController.text = "";

      newToDo["ok"] = false;
      lista.add(newToDo);
      _saveData(lista);
    });
  }

  Future<Null> _refresh(List lista) async {
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      lista.sort((a, b) {
        if (a["ok"] && !b["ok"])
          return 1;
        else if (!a["ok"] && b["ok"])
          return -1;
        else
          return 0;
      });

      _saveData(lista);
    });

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final _kTabPages = <Widget>[
      //Tab 1
      Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _toDoController,
                    decoration: InputDecoration(
                        labelText: "Nova Atividade",
                        labelStyle: TextStyle(color: Colors.blueAccent)),
                  ),
                ),
                RaisedButton(
                  color: Colors.blueAccent,
                  child: Text("ADD"),
                  textColor: Colors.white,
                  onPressed: () => _addToDo(_toDoList1),
                ),
              ],
            ),
          ),
          Expanded(
              child: RefreshIndicator(
            onRefresh: () => _refresh(_toDoList1),
            child: ListView.builder(
                padding: EdgeInsets.only(top: 10.0),
                itemCount: _toDoList1.length,
                itemBuilder: (context, index) =>
                    buildItem(context, index, _toDoList1)),
          ))
        ],
      ),

      //tab2

      Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _toDoController,
                    decoration: InputDecoration(
                        labelText: "Nova Compra",
                        labelStyle: TextStyle(color: Colors.blueAccent)),
                  ),
                ),
                RaisedButton(
                  color: Colors.blueAccent,
                  child: Text("ADD"),
                  textColor: Colors.white,
                  onPressed: () => _addToDo(_toDoList2),
                ),
              ],
            ),
          ),
          Expanded(
              child: RefreshIndicator(
            onRefresh: () => _refresh(_toDoList2),
            child: ListView.builder(
                padding: EdgeInsets.only(top: 10.0),
                itemCount: _toDoList2.length,
                itemBuilder: (context, index) =>
                    buildItem(context, index, _toDoList2)),
          ))
        ],
      ),
      Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _toDoController,
                    decoration: InputDecoration(
                        labelText: "Nova Matéria",
                        labelStyle: TextStyle(color: Colors.blueAccent)),
                  ),
                ),
                RaisedButton(
                  color: Colors.blueAccent,
                  child: Text("ADD"),
                  textColor: Colors.white,
                  onPressed: () => _addToDo(_toDoList3),
                ),
              ],
            ),
          ),
          Expanded(
              child: RefreshIndicator(
            onRefresh: () => _refresh(_toDoList3),
            child: ListView.builder(
                padding: EdgeInsets.only(top: 10.0),
                itemCount: _toDoList3.length,
                itemBuilder: (context, index) =>
                    buildItem(context, index, _toDoList3)),
          ))
        ],
      ),
    ];
    final _kTabs = <Tab>[
      const Tab(icon: Icon(Icons.list_alt), text: 'Atividades'),
      const Tab(icon: Icon(Icons.shopping_cart), text: 'Compras'),
      const Tab(icon: Icon(Icons.book), text: 'Estudos'),
    ];

    return DefaultTabController(
      length: _kTabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Lista de Tarefas"),
          backgroundColor: Colors.blueAccent,
          centerTitle: true,
          bottom: TabBar(
            tabs: _kTabs,
          ),
        ),
        body: TabBarView(
          children: _kTabPages,
        ),
      ),
    );
  }

  //faz a lista
  Widget buildItem(BuildContext context, int index, List lista) {
    return Dismissible(
      key: Key(DateTime.now().microsecondsSinceEpoch.toString()),
      background: Container(
          color: Colors.red,
          child: Align(
            alignment: Alignment(-0.9, 0.0),
            child: Icon(Icons.delete, color: Colors.white),
          )),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(lista[index]["title"]),
        value: lista[index]["ok"],
        secondary: CircleAvatar(
          child: Icon(lista[index]["ok"] ? Icons.check : Icons.error),
        ),
        onChanged: (c) {
          setState(() {
            lista[index]["ok"] = c;
            _saveData(lista);
          });
        },
      ),
      onDismissed: (direction) {
        setState(() {
          _lastRemoved = Map.from(lista[index]);
          _lastRemovedPos = index;
          lista.removeAt(index);

          _saveData(lista);

          final snack = SnackBar(
            content: Text("Tarefa \"${_lastRemoved["title"]}\" removida!"),
            action: SnackBarAction(
              label: "Desfazer",
              onPressed: () {
                setState(() {
                  lista.insert(_lastRemovedPos, _lastRemoved);
                  _saveData(lista);
                });
              },
            ),
            duration: Duration(seconds: 2),
          );
          Scaffold.of(context).removeCurrentSnackBar();
          Scaffold.of(context).showSnackBar(snack);
        });
      },
    );
  }

  Future<File> _getFile(String s) async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data$s.json");
  }

  Future<File> _saveData(List lista) async {
    String data = json.encode(lista);
    String s;
    if (lista == _toDoList1) {
      s = "1";
    } else if (lista == _toDoList2) {
      s = "2";
    } else if (lista == _toDoList3) {
      s = "3";
    }

    final file = await _getFile(s);
    return file.writeAsString(data);
  }

  Future<String> _readData(String s) async {
    try {
      final file = await _getFile(s);
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }
}
