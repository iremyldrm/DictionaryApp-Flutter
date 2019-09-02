import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dictionary App',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: MyHomePage(title: 'Dictionary App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String sonuc = "";

  @override
  Widget build(BuildContext context) {
    final word = new TextEditingController();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            LogoImageWidget(),
            Padding(
              padding: EdgeInsets.fromLTRB(40, 5, 40, 5),
              child: TextField(
                controller: word,
                decoration: InputDecoration(
                  hintText: "Kelime Giriniz / Enter Word",
                  contentPadding: EdgeInsets.fromLTRB(20, 5, 20, 20),
                  enabledBorder: const OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.pink)),
                ),
              ),
            ),
            RaisedButton(
              onPressed: () {
                _translate(word.text);
              },
              child: Text("Çevir / Translate"),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            Text('$sonuc',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.0,
                  decoration: TextDecoration.underline,
                )),
          ],
        ),
      ),
    );
  }

  _translate(String word) async {
    String kelime = "";
    String url =
        "https://dictionaryapp20190827024422.azurewebsites.net/api/keywords/";
    url = url + word;
    var response = await http.get(Uri.encodeFull(url), headers: {
      "Accept": "application/json",
    });
    print(response);
    List result = json.decode(response.body);
    if (result != null && result.length > 0) {
      if (word == result[0]["wordEn"]) {
        print(result[0]["wordTr"]);
        for (int i = 0; i < result.length; i++) {
          print(result[i]["wordTr"]);
          kelime = kelime + " " + result[i]["wordTr"] + " , ";
        }
        setState(() {
          sonuc = kelime;
        });
      } else {
        print(result[0]["wordEn"]);
        for (int i = 0; i < result.length; i++) {
          print(result[i]["wordEn"]);
          kelime = kelime + " " + result[i]["wordEn"] + " , ";
        }
        setState(() {
          sonuc = kelime;
        });
      }
    } else {
      print("Kelime Bulunamadı");

      setState(() {
        sonuc = "KELİME BULUNAMADI \n NO WORDS FOUND.";
      });
    }
  }
}

class LogoImageWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AssetImage logoAsset = AssetImage("images/logo.png");
    Image image = Image(
      image: logoAsset,
      width: 350.0,
      height: 100.0,
    );

    return Container(child: image);
  }
}
