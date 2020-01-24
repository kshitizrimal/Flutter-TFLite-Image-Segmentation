// Import required packages
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(MyApp());

// setting up a string constant for the name of the model
const String dlv3 = 'DeepLabv3';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TfliteHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TfliteHome extends StatefulWidget {

  @override
  _TfliteHomeState createState() => _TfliteHomeState();
}

// This class is responsible for all the functions of the app
class _TfliteHomeState extends State<TfliteHome> {
  String _model = dlv3;

  File _image;

  double _imageWidth;
  double _imageHeight;
  bool _busy = false;

  var _recognitions;

  // when the widget initiates try to load the model for further actions
  @override
  void initState() {
    super.initState();
    _busy = true;
    loadModel().then((val) {
      setState(() {
        _busy = false;
      });
    });
  }
 // method responsible for loading the model from the assets folder
  loadModel() async {
    Tflite.close();
    try {
      String res;
      if(_model == dlv3) {
        res = await Tflite.loadModel(
          model: 'assets/tflite/deeplabv3_257_mv_gpu.tflite',
          labels: 'assets/tflite/deeplabv3_257_mv_gpu.txt',
        );
      }
    } on PlatformException {
      print("cant load model");
    }
  }
  // method responsible for loading an image from image gallery of the device
  selectFromImagePicker() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery, );
    if(image == null) return;
    setState(() {
      _busy = true;
    });
    predictImage(image);
  }
 // method responsible for loading image from live camera of the device
  selectFromCamera() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    if(image == null) return;
    setState(() {
      _busy = true;
    });
    predictImage(image);
  }

  // method responsible for predicting segmentation for the selected image
  predictImage(File image) async {
    if(image == null) return;
    if(_model == dlv3) {
      await dlv(image);
    }
    // get the width and height of selected image
    FileImage(image).resolve(ImageConfiguration()).addListener((ImageStreamListener((ImageInfo info, bool _){
      setState(() {
        _imageWidth = info.image.width.toDouble();
        _imageHeight = info.image.height.toDouble();
      });
    })));

    setState(() {
      _image = image;
      _busy = false;
    });
  }
  // method responsible for giving actual prediction from the model
  dlv(File image) async {
    var recognitions = await Tflite.runSegmentationOnImage(
      path: image.path,
      imageMean: 0.0,
      imageStd: 255.0,
      outputType: "png",
      asynch: true,
    );

    setState(() {
      _recognitions = recognitions;
    });
  }
  // build method is run each time app needs to re-build the widget
  @override
  Widget build(BuildContext context) {
    // get the width and height of current screen the app is running on
    Size size = MediaQuery.of(context).size;

    // initialize two variables that will represent final width and height of the segmentation
    // and image preview on screen
    double finalW;
    double finalH;

    // when the app is first launch usually image width and height will be null
    // therefore for default value screen width and height is given
    if(_imageWidth == null && _imageHeight == null) {
      finalW = size.width;
      finalH = size.height;
    }else {

      // ratio width and ratio height will given ratio to
      // scale up or down the preview image and segmentation
      double ratioW = size.width / _imageWidth;
      double ratioH = size.height / _imageHeight;

      // final width and height after the ratio scaling is applied
      finalW = _imageWidth * ratioW;
      finalH = _imageHeight * ratioH;
    }

    List<Widget> stackChildren = [];

    // when busy load a circular progress indicator
    if(_busy) {
      stackChildren.add(Positioned(
        top: 0,
        left: 0,
        child: Center(child: CircularProgressIndicator(),),
      ));
    }

    // widget to show image preview, when preview not available default text is shown
    stackChildren.add(Positioned(
      top: 0.0,
      left: 0.0,
      width: finalW,
      height: finalH,
      child: _image == null ? Center(child: Text('Please Select an Image From Camera or Gallery'),): Image.file(_image, fit: BoxFit.fill,),
    ));

    // widget to show segmentation preview, when segmentation not available default blank text is shown
    stackChildren.add(Positioned(
      top: 0,
      left: 0,
      width: finalW,
      height: finalH,
      child: Opacity(
        opacity: 0.7,
        child: _recognitions == null ? Center(child: Text(''),): Image.memory(_recognitions, fit: BoxFit.fill),
      ),
    ));

    return Scaffold(
      appBar: AppBar(
        title: Text('On-Device Image Segmentation'),
        backgroundColor: Colors.redAccent,
      ),
      floatingActionButton: Stack(
        children: <Widget>[
          Padding(padding: EdgeInsets.all(10),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FloatingActionButton(
                child: Icon(Icons.image),
                tooltip: 'Pick Image from Gallery',
                backgroundColor: Colors.purpleAccent,
                onPressed: selectFromImagePicker,
              ),
            ),
          ),
          Padding(padding: EdgeInsets.all(10),
            child: Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                child: Icon(Icons.camera),
                backgroundColor: Colors.redAccent,
                tooltip: 'Pick Image from Camera',
                onPressed: selectFromCamera,
              ),
            ),
          )
        ],
      ),
      body: Stack(
        children: stackChildren,
      ),
    );
  }
}

