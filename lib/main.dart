import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:speech_recognition/speech_recognition.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dictionary App',
      theme: ThemeData(
        primarySwatch: Colors.red,
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
  SpeechRecognition _speechRecognition;
  bool _isAvailable = false;
  bool _isListening = false;

  String resultText = "";

  @override
  void initState() {
    super.initState();
     initSpeechRecognizer();
  }

  void initSpeechRecognizer() {
    _speechRecognition = SpeechRecognition();
    _speechRecognition.setAvailabilityHandler(
        (bool result) => setState(() => _isAvailable = result));
    _speechRecognition.setRecognitionStartedHandler(
        () => setState(() => _isListening = true));
    _speechRecognition.setRecognitionResultHandler(
        (String speech) => setState(() =>  resultText = speech));
    _speechRecognition.setRecognitionCompleteHandler(
        () => setState(( ) => {
                              _isListening = false, 
                              word.text=resultText,                            
                              _translate(word.text)
        }) );
    _speechRecognition.activate().then(
          (result) => setState(() => _isAvailable = result));



  }



  String sonuc = "";
  List result = new List();
  ListView listView = ListView();
  FocusNode _focusNode = new FocusNode(); //1 - declare and initialize variable
  final word = new TextEditingController();

  @override
  Widget build(BuildContext context) {
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
                focusNode:
                    _focusNode, //FocusScope.of(context).requestFocus(FocusNode());,
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
                _focusNode.unfocus();
                _translate(word.text);
              },
              child: Text("Çevir / Translate"),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
             
            Expanded(child: listView),
            Row(
               mainAxisAlignment: MainAxisAlignment.center,               
              children:<Widget>[

            FloatingActionButton(
              child: Icon(Icons.cancel),
              mini: true,
              backgroundColor: Colors.amber,
               onPressed: (){if (_isListening)
                      _speechRecognition.cancel().then(
                            (result) => setState(() {
                                  _isListening = result;                                  
                                  resultText = "";
                                
                                }),
                          );},),  
            FloatingActionButton(   
              child: Icon(Icons.mic),           
              backgroundColor: Colors.red,
               onPressed: (){
                 if (_isAvailable && !_isListening)
                      _speechRecognition
                          .listen(locale: "tr_TR" )
                          .then((result) => print('$result'));                          
                          },),
            FloatingActionButton(
              child: Icon(Icons.stop),
              mini: true,
              backgroundColor: Colors.amber,
               onPressed: (){
                 if (_isListening) {
                   _speechRecognition.stop().then(
                            //(result) => setState(() => _isListening = result),
                            (result) => setState(() {
                              _isListening = result;  
                              word.text=resultText;                            
                              _translate(word.text);
                            }
                          ));
                 }},),
           
            
            
          ])],
        ),
      ),
    );
  }

  _translate(String word) async {

if(word.isNotEmpty){

    String url =
        "https://dictionaryapp20190827024422.azurewebsites.net/api/keywords/";
    url = url + word;
    var response = await http.get(Uri.encodeFull(url), headers: {
      "Accept": "application/json",
    });
    print(response);
    setState(() {
      result = json.decode(response.body);
      listView = _myListView(context, result, word);
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

Widget _myListView(BuildContext context, List wordList, String word) {
  if (word != null && wordList.length > 0) {
    return ListView.builder(
      itemCount: wordList.length,
      itemBuilder: (context, index) {
        if (word == wordList[index]["wordEn"]) {
          return ListTile(
              title: Text("EN -> TR     " + wordList[index]["wordTr"],
                  textAlign: TextAlign.center));
        } else {
          return ListTile(
              title: Text("TR -> EN     " + wordList[index]["wordEn"],
                  textAlign: TextAlign.center));
        }
      },
    );
  } else {
    return ListView(children: <Widget>[
      ListTile(
          title: Text("KELİME BULUNAMADI \n NO WORDS FOUND.",
              textAlign: TextAlign.center)),
    ]);
  }
}
