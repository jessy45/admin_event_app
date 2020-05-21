import 'dart:io';
import 'package:admin/homepage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

void main() => runApp(MaterialApp(
      home: UploadImage(),
      debugShowCheckedModeBanner: false,
    ));

class UploadImage extends StatefulWidget {
  @override
  _UploadImageState createState() => _UploadImageState();
}

class _UploadImageState extends State<UploadImage> {
  String _myValue;
  final formKey = new GlobalKey<FormState>();
  File sampleImage;
  String url;
  String _location;
  String _title;
  String _subTitle;
  String _content;

  Future getImage() async {
    var tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      sampleImage = tempImage;
    });
  }

  bool valideAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  void uploadStatusImage() async {
    if (valideAndSave()) {
      final StorageReference postImageRef =
          FirebaseStorage.instance.ref().child("Post Images");
      var timeKey = new DateTime.now();
      final StorageUploadTask uploadTask =
          postImageRef.child(timeKey.toString() + ".jpg").putFile(sampleImage);

      var ImageUrl = await (await uploadTask.onComplete).ref.getDownloadURL();

      url = ImageUrl.toString();
      print('Image Url = ' + url);

      goToHomePage();
      saveToDatabe(url);
    }
  }

  void saveToDatabe(url) {
    var dbTimeKey = new DateTime.now();
    var formatDate = new DateFormat('MMM d, yyyy');
    var formatTime = new DateFormat('EEEE, hh:mm aaa');

    String date = formatDate.format(dbTimeKey);
    String time = formatTime.format(dbTimeKey);

    DatabaseReference ref = FirebaseDatabase.instance.reference();

    var data = {
      "image": url,
      "description": _myValue,
      "date": date,
      "time": time,
      "location":_location,
      "title":_title,
      "subtitle":_subTitle,
      "content": _content

    };

    ref.child("Posts").push().set(data);
  }

  void goToHomePage() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return new HomePage();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("Adminitration"),
      ),
      body: Center(
        child: sampleImage == null ? Text("Select an image") : enableUpload(),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Add Image',
        child: Icon(Icons.add_a_photo),
      ),
    );
  }

  Widget enableUpload() {
    return Container(
      height: double.infinity,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 120.0),
        child: Form(
          key: formKey,
          child: Column(
            children: <Widget>[
              Image.file(sampleImage, height: 330.0, width: 660.0),
              SizedBox(
                height: 15.0,
              ),
              TextFormField(
                decoration: new InputDecoration(labelText: 'Description'),
                validator: (value) {
                  return value.isEmpty ? 'Description is required' : null;
                },
                onSaved: (value) {
                  return _myValue = value;
                },
              ),
              SizedBox(
                height: 15.0,
              ),
              TextFormField(
                decoration: new InputDecoration(labelText: 'Location'),
                validator: (value) {
                  return value.isEmpty ? 'Location is required' : null;
                },
                onSaved: (value) {
                  return _location = value;
                },
              ),
              SizedBox(
                height: 15.0,
              ),
              TextFormField(
                decoration: new InputDecoration(labelText: 'Title'),
                validator: (value) {
                  return value.isEmpty ? 'Title is required' : null;
                },
                onSaved: (value) {
                  return _title = value;
                },
              ),
              SizedBox(
                height: 15.0,
              ),
              TextFormField(
                decoration: new InputDecoration(labelText: 'Subtitle'),
                validator: (value) {
                  return value.isEmpty ? 'Subtitle is required is required' : null;
                },
                onSaved: (value) {
                  return _title = value;
                },
              ),
              SizedBox(
                height: 15.0,
              ),
              TextFormField(
                decoration: new InputDecoration(labelText: 'Content'),
                validator: (value) {
                  return value.isEmpty ? 'Content is required' : null;
                },
                onSaved: (value) {
                  return _content = value;
                },
              ),
              RaisedButton(
                onPressed: uploadStatusImage,
                elevation: 10.0,
                child: Text("Add new post"),
                textColor: Colors.white,
                color: Colors.pink,
              )
            ],
          ),
        ),
      ),
    );
  }
}
