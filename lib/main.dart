import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final GlobalKey globalKey = new GlobalKey();
  String headerText='';
  String footerText='';
  File _image;
  File _imageFile;
  bool imageSelected = false;

  Random rng = new Random();

  Future getImage() async {

    try{
      final image = await ImagePicker().getImage(source: ImageSource.gallery);
      print("picked");
      setState(() {
        if(image != null){
          imageSelected = true;
          print("if");
        }
        else{
          print("else");
        }
        _image = File(image.path);
        print("set");
      });

    }
    catch(platformException){
      print('not allowing '+ platformException);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              SizedBox(height: 50,),
              Image.asset('assets/smile.png', height: 80,),
              SizedBox(height: 12,),
              Image.asset('assets/memegenrator.png', height: 70,),
              SizedBox(height: 30,),
              RepaintBoundary(
                key: globalKey,
                child: Stack(
                  children: [
                    _image != null ? Image.file(
                        _image,
                      height: 300,
                      fit: BoxFit.fitHeight,
                    ) : Container(),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 300,
                      // padding: EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              headerText.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 26,
                                shadows: [
                                Shadow(
                                  offset: Offset(2.0,2.0),
                                  blurRadius: 3.0,
                                  color: Colors.black87,
                                ),
                                Shadow(
                                  offset: Offset(2.0,2.0),
                                  blurRadius: 8.0,
                                  color: Colors.black87,
                                ),
                              ],
                            ),),
                          ),
                          Spacer(),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              footerText.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 26,
                                shadows: [
                                  Shadow(
                                    offset: Offset(2.0,2.0),
                                    blurRadius: 3.0,
                                    color: Colors.black87,
                                  ),
                                  Shadow(
                                    offset: Offset(2.0,2.0),
                                    blurRadius: 8.0,
                                    color: Colors.black87,
                                  ),
                                ],
                            ),),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 20,),
              imageSelected ? Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    TextField(
                      onChanged: (val){
                        setState(() {
                          headerText = val;
                        });
                      },
                      decoration: InputDecoration(
                          hintText: 'Header Text'
                      ),
                    ),
                    SizedBox(height: 12,),
                    TextField(
                      onChanged: (val){
                        setState(() {
                          footerText = val;
                        });
                      },
                      decoration: InputDecoration(
                          hintText: 'Footer Text'
                      ),
                    ),
                    SizedBox(height: 20,),
                    RaisedButton(
                      onPressed: () {
                        takeScreenshot();
                      },
                      child: Text('Save'),
                    )
                  ],
                ),
              ) : Container(
                child: Center(
                  child: Text('Select Image to get started'),
                ),
              ),
            _imageFile != null ? Image.file(_imageFile) : Container(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          getImage();
        },
        child: Icon(Icons.add_a_photo),
      ),
    );
  }

  takeScreenshot() async {
    RenderRepaintBoundary boundary =
    globalKey.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage();
    final directory = (await getApplicationDocumentsDirectory()).path;
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();
    print(pngBytes);
    File imgFile = new File('$directory/screenshot${rng.nextInt(200)}.png');
    imgFile.writeAsBytes(pngBytes);
    setState(() {
      _imageFile = imgFile;
    });
    _savefile(_imageFile);

  }

  _savefile(File file) async {
    await _askPermission();
    final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(await file.readAsBytes()));
    print(result);
  }

  _askPermission() async {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();
      print(statuses[Permission.storage]);
  }


}
