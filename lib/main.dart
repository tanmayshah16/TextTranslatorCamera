
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:translator/translator.dart';


main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

var lang = '';
var translation;
String langId;
String langcode;

GoogleTranslator translator = new GoogleTranslator();

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File pickedImage;
  var text = '';



  bool imageLoaded = false;

  Future pickImage() async {
    var awaitImage = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      pickedImage = awaitImage;
      imageLoaded = true;
    });
    FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(pickedImage);
    TextRecognizer textRecognizer = FirebaseVision.instance.textRecognizer();
    VisionText visionText = await textRecognizer.processImage(visionImage);

    for (TextBlock block in visionText.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement word in line.elements) {
          setState(() {
            text = text + word.text + ' ';
          });
        }
        text = text + '\n';
        lang = text;
      }
    }
    textRecognizer.close();
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          SizedBox(height: 100.0),
          imageLoaded
              ? Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(blurRadius: 20),
                  ],
                ),
                margin: EdgeInsets.fromLTRB(0, 0, 0, 8),
                height: 250,
                child: Image.file(
                  pickedImage,
                  fit: BoxFit.cover,
                ),
              ))
              : Container(),
          SizedBox(height: 10.0),
          Center(
            child: FlatButton.icon(
              icon: Icon(
                Icons.camera_alt,
                size: 80,
              ),
              label: Text(''),
              textColor: Theme
                  .of(context)
                  .primaryColor,
              onPressed: () async {
                pickImage();
              },
            ),
          ),
          SizedBox(height: 30.0),
          SizedBox(height: 30.0),

          if (text == '') Text(
              '               Text will display here                   ',style: TextStyle(fontSize: 18 ),) else
            Expanded(

              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(text),
                      RaisedButton(textColor: Colors.deepOrange,
                        color: Colors.cyanAccent,
                        child: Text("Translate"),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => TranslatePage()));
                        },)
                    ],


                  ),

                ),
              ),
            ),


        ],
      ),
    );
  }
}

class TranslatePage  extends StatefulWidget {


  @override
  _TranslatePageState createState() => _TranslatePageState();
}

class _TranslatePageState extends State<TranslatePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Translator"),
        backgroundColor: Colors.black38,

      ),
      body: ListView(
        children: <Widget>[
          SelectLang(),
          HorizontalLine(),

          Container(
              child: Center(
                child: Column(
                  children: <Widget>[
                    Text(lang),



                    RaisedButton(textColor: Colors.white, color: Colors.green, child: Text("Translate"), onPressed: ()  async {

                      translation = await translator.translate(
                          lang, to: langcode);
                      print(translation);
                      Text(translation.toString());
                    },

                    ),

                  ],
                ),
              )
          ),


          HorizontalLine(),
          MainPage(),
        ],
      )

      );
  }
}




class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              RaisedButton(
                textColor: Colors.white,
                color: Colors.black26,
                child: Text("Press to select new image"),
                onPressed: () {
                  Navigator.pop(context);
                },

              )
            ],
          ),
        )
    );
  }
}



class SelectLang extends StatefulWidget {

  @override
  _SelectLangState createState() => new _SelectLangState();
}

class _SelectLangState extends State<SelectLang>{
  String dropdownValue = 'Select a Language';
  String holder = '' ;
    List<String> Langlist = ['Hindi', 'English','French','Gujarati','Bengali','Kannada'];


  Future<void> getDropDownItem() async {

    setState(() {
      langId = dropdownValue ;
    });

    if(langId == 'English')
      {
        langcode = 'en';
      }
    else if(langId == 'French')
    {
      langcode = 'fr';
    }
    else if(langId == 'Gujarati') {
      langcode = 'gu';
    }
    else if(langId == 'Hindi')
      {
        langcode = 'hi';
      }
    else if(langId == 'Bengali')
      {
        langcode = 'bn';
      }
    else if(langId == 'Kannada')
      {
        langcode = 'kn';
      }



  }


  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
          child :
          Column(children: <Widget>[

            DropdownButton<String>(
              value: dropdownValue,
              icon: Icon(Icons.arrow_drop_down_circle),
              iconSize: 26,
              elevation: 16,
              style: TextStyle(color: Colors.black, fontSize: 18),
              underline: Container(
                height: 2,
                color: Colors.cyanAccent,
              ),
              onChanged: (String data) {
                setState(() {
                  dropdownValue = data;
                });
                getDropDownItem();
              },
              items: Langlist.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ]),
        ),
    );

  }


  }




class HorizontalLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      child: Container(
        height: 0.5,
        color: Colors.grey.shade700,
      ),
    );
  }
}



