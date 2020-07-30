import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';
import 'package:convert/convert.dart';

const request = "https://api.hgbrasil.com/finance?format=json&key=77f15ac6";

void main() async {
  runApp(MaterialApp(
    theme: ThemeData(primaryColor: Colors.white, hintColor: Colors.amberAccent),
    home: Home(),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  void _realChanged(String text) {
    if(text.isEmpty){
      clearAll();
      return;
    }
    double real = double.parse(text);
    dolarController.text = (real/dolar).toStringAsFixed(2);
    euroController.text = (real/euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    if(text.isEmpty){
      clearAll();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar*this.dolar).toStringAsFixed(2);
    euroController.text = ((dolar*this.dolar) / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    if(text.isEmpty){
      clearAll();
      return;
    }
    double euro = double.parse(text);
    realController.text = (euro*this.euro).toStringAsFixed(2);
    dolarController.text = ((euro*this.euro)/dolar).toStringAsFixed(2);
  }

  void clearAll(){
    realController.text="";
    dolarController.text="";
    euroController.text="";
  }

  double dolar;
  double euro;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        title: Text(
          "Conversor de Moedas \$",
        ),
        backgroundColor: Colors.amberAccent,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text(
                  "Carregando dados ...",
                  style: TextStyle(color: Colors.amberAccent, fontSize: 25.0),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Falha ao carregar dados 😕",
                    style: TextStyle(color: Colors.amberAccent, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                return SingleChildScrollView(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(
                        Icons.monetization_on,
                        size: 150,
                        color: Colors.amberAccent,
                      ),
                      buildTextField("Reais", "R\$", realController, _realChanged),
                      Divider(),
                      buildTextField("Dolares", "US\$", dolarController,_dolarChanged),
                      Divider(),
                      buildTextField("Euros", "€\$", euroController,_euroChanged),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(
    String label, String prefix, TextEditingController c, Function f) {
  return TextField(
    controller: c,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.amberAccent),
      border: OutlineInputBorder(),
      prefixText: prefix,
    ),
    style: TextStyle(color: Colors.amberAccent, fontSize: 25),
    onChanged: f,
    keyboardType: TextInputType.number,
  );
}
