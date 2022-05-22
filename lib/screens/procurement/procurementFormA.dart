import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:achilleserp/models/forms.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:achilleserp/screens/forms/fullScreenImage.dart';
import 'package:achilleserp/models/user.dart';
import 'package:achilleserp/services/hex_to_color.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';


class ProcurementApprovalFormA extends StatefulWidget {
  final DocumentSnapshot post;
  final User user;
  ProcurementApprovalFormA({Key key, this.post, this.user}) : super(key: key);

  @override
  _ProcurementApprovalFormAState createState() => _ProcurementApprovalFormAState();
}

class _ProcurementApprovalFormAState extends State<ProcurementApprovalFormA> {

  int receiverCount = 2;
  List <String> receiverUids =  ['9hm9y2c08pdAS5zZcnJRSH3TnsZ2', 'zpYyXei6FjU1qzrI4AviUK0QudE3'];
  List <String> receiverNames = ['Sumedh Boralkar', 'Rahul Tak'];


  List <dynamic> imageUpload = new List(6);
  List <dynamic> showImg = new List(6);
  bool showUploadingScreen = false;
  List <StorageUploadTask> _uploadStatus = new List(6);


  final picker = ImagePicker();
  final StorageReference firebaseStorageRef = FirebaseStorage.instance.ref();

  List <bool> imageArr = new List(6);


  Future _getImages(int index) async {
    var image = await picker.getImage(source: ImageSource.gallery);

    print("IMAGE HERE <<<<>>>>>");
    print(image);
    setState(() {
      occupied[index] = 1;
      imageUpload[index] = image;
      imageArr[index] = true;
      already[index] = false;
    });
  }

  var JsonResult;
  loadJSONData() async {
    String codes = await DefaultAssetBundle.of(context).loadString('assets/codes.json');
    JsonResult = json.decode(codes);
  }


  List<String> urls = new List(6);
  List<String> billurls = new List(6);


  List <bool> already = new List(6);
  List occupied = new List(6);
  List fromFile = new List(6);


  bool loading = true;
  bool onlyOnce = true;
  var filepath;
  final key = new GlobalKey<ScaffoldState>();
  var remarkController = TextEditingController();
  static final procurementFormKey = new GlobalKey<FormState>();
  var costRequirementController = TextEditingController();
  var procuringDetailsController = TextEditingController();


  @override
  void initState() {
    super.initState();
  }





  @override
  Widget build(BuildContext context) {
    final db = Firestore.instance;
    firstForm form = firstForm();
    final remarkFormKey = GlobalKey<FormState>();


    final List<StorageReference> imgRefs = [
      widget.post.data['img1'] == null ? null : FirebaseStorage.instance.ref().child(widget.post.data['img1']),
      widget.post.data['img2'] == null ? null : FirebaseStorage.instance.ref().child(widget.post.data['img2']),
      widget.post.data['img3'] == null ? null : FirebaseStorage.instance.ref().child(widget.post.data['img3']),
      widget.post.data['img4'] == null ? null : FirebaseStorage.instance.ref().child(widget.post.data['img4']),
      widget.post.data['img5'] == null ? null : FirebaseStorage.instance.ref().child(widget.post.data['img5']),
      widget.post.data['img6'] == null ? null : FirebaseStorage.instance.ref().child(widget.post.data['img6']),
    ];

    List<StorageReference> billImgRefs = new List(6);

    loadUrls() async{
      print('-------IN LOADING URLS');
      for(int i=0; i<6; i++) {
        if(imgRefs[i] != null) {
          await imgRefs[i].getDownloadURL().then((value) => setState(() => urls[i] = value));
          print('++++++====');
          print(urls[i]);
        }
        if(billImgRefs[i] != null) {
          await billImgRefs[i].getDownloadURL().then((value) => setState(() => billurls[i] = value));
          print('++++++====');
          print(urls[i]);
        }
      }
      setState(() {loading = false;});
    }

    if(onlyOnce == true)
    {
      billImgRefs = [
        widget.post.data['billImg1'] == null ? null : FirebaseStorage.instance.ref().child(widget.post.data['billImg1']),
        widget.post.data['billImg2'] == null ? null : FirebaseStorage.instance.ref().child(widget.post.data['billImg2']),
        widget.post.data['billImg3'] == null ? null : FirebaseStorage.instance.ref().child(widget.post.data['billImg3']),
        widget.post.data['billImg4'] == null ? null : FirebaseStorage.instance.ref().child(widget.post.data['billImg4']),
        widget.post.data['billImg5'] == null ? null : FirebaseStorage.instance.ref().child(widget.post.data['billImg5']),
        widget.post.data['billImg6'] == null ? null : FirebaseStorage.instance.ref().child(widget.post.data['billImg6']),
      ];

      occupied[0] = widget.post.data['billImg1'] == null ? null : 1;
      occupied[1] = widget.post.data['billImg2'] == null ? null : 1;
      occupied[2] = widget.post.data['billImg3'] == null ? null : 1;
      occupied[3] = widget.post.data['billImg4'] == null ? null : 1;
      occupied[4] = widget.post.data['billImg5'] == null ? null : 1;
      occupied[5] = widget.post.data['billImg6'] == null ? null : 1;

      fromFile[0] = occupied[0] == 1 ? 0 : 1;
      fromFile[1] = occupied[1] == 1 ? 0 : 1;
      fromFile[2] = occupied[2] == 1 ? 0 : 1;
      fromFile[3] = occupied[3] == 1 ? 0 : 1;
      fromFile[4] = occupied[4] == 1 ? 0 : 1;
      fromFile[5] = occupied[5] == 1 ? 0 : 1;


      onlyOnce = false;
      loadUrls();
    }





    Widget plotValue(String name, String value)
    {
      if (name != 'Form Status') {
        return Container(
          margin: EdgeInsets.only(top: 10),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                name + ":",
                style: TextStyle(
                  color: Colors.deepOrangeAccent,
                  fontSize: 20,
                  fontStyle:  FontStyle.italic,
                ),
              ),
              SizedBox(height: 5,),
              Text(
                value,
                style: TextStyle(
                  fontSize: 25,
                ),
              )
            ],
          ),
        );
      } else {
        String statusString;
        if (value == 'stage-1') {statusString = 'Returned back';}
        if (value == 'stage0') {statusString = 'Waiting for head(s) approval';}
        if (value == 'stage1') {statusString = 'Head(s) approved, waiting for market survey';}
        if (value == 'stage2') {statusString = 'Procurement(market survey approved), waiting for treasurer approval';}
        if (value == 'stage3') {statusString = 'Treasurer approved, waiting for procuring';}
        if (value == 'stage4') {statusString = 'Procuring completed, waiting for QC approval';}
        if (value == 'stage5') {statusString = 'QC approved, process complete';}


        return Container(
          margin: EdgeInsets.only(top: 10),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                name + ":",
                style: TextStyle(
                  color: Colors.deepOrangeAccent,
                  fontSize: 20,
                  fontStyle:  FontStyle.italic,
                ),
              ),
              SizedBox(height: 5,),
              Text(
                statusString,
                style: TextStyle(
                  fontSize: 25,
                ),
              )
            ],
          ),
        );
      }
    }


    Widget imagesArea(String img1, String img2, String img3, String img4, String img5, String img6) {
      print(img1);
      return Container(
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  blurRadius: 5,
                  spreadRadius: 1,
                  offset: Offset(0, 4)
              )
            ]
        ),
        child: Column(
          children: <Widget>[
            SizedBox(height: 15,),
            Text(
              'Images',
              style: TextStyle(
                color: Colors.deepOrangeAccent,
                fontSize: 20,
                fontStyle: FontStyle.italic,
              ),
            ),
            GridView.count(
              shrinkWrap: true,
              primary: false,
              padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              crossAxisCount: 3,
              children: <Widget>[
                GestureDetector(
                    onTap: () {
                    },
                    child: Container(
                      child: img1 == null ?
                      Container(
                        color: Colors.black12,
                        child: Center(child: Text('Empty')),
                      )  :
                      Stack(
                        children: <Widget>[
                          new Container(
                            child: Center(child: Image.network(urls[0])),
                          ),
                          new Align(
                              alignment: Alignment.topRight,
                              child: SizedBox(
                                height: 30,
                                width: 30,
                                child: FloatingActionButton(
                                  mini: true,
                                  heroTag: 'click1',
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => ShowFullScreen(url: urls[0],))
                                    );
                                  },
                                  backgroundColor: Colors.red,
                                  child: Icon(
                                    Icons.open_in_new,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                          )
                        ],
                      ),
                    )
                ),
                GestureDetector(
                    onTap: () {

                    },
                    child: Container(
                      child: img2 == null ?
                      Container(
                        color: Colors.black12,
                        child: Center(child: Text('Empty')),
                      )  :
                      Stack(
                        children: <Widget>[
                          new Container(
                            child: Center(child: Image.network(urls[1])),
                          ),
                          new Align(
                              alignment: Alignment.topRight,
                              child: SizedBox(
                                height: 30,
                                width: 30,
                                child: FloatingActionButton(
                                  heroTag: 'show2',
                                  mini: true,
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => ShowFullScreen(url: urls[1],))
                                    );
                                  },
                                  backgroundColor: Colors.red,
                                  child: Icon(
                                    Icons.open_in_new,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                          )
                        ],
                      ),
                    )
                ),
                GestureDetector(
                    onTap: () {
                    },
                    child: Container(
                      child: img3 == null ?
                      Container(
                        color: Colors.black12,
                        child: Center(child: Text('Empty')),
                      )  :
                      Stack(
                        children: <Widget>[
                          new Container(
                            child: Center(child: Image.network(urls[2])),
                          ),
                          new Align(
                              alignment: Alignment.topRight,
                              child: SizedBox(
                                height: 30,
                                width: 30,
                                child: FloatingActionButton(
                                  heroTag: 'show3',
                                  mini: true,
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => ShowFullScreen(url: urls[2],))
                                    );
                                  },
                                  backgroundColor: Colors.red,
                                  child: Icon(
                                    Icons.open_in_new,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                          )
                        ],
                      ),
                    )
                ),
                GestureDetector(
                    onTap: () {
                    },
                    child: Container(
                      child: img4 == null ?
                      Container(
                        color: Colors.black12,
                        child: Center(child: Text('Empty')),
                      )  :
                      Stack(
                        children: <Widget>[
                          new Container(
                            child: Center(child: Image.network(urls[3])),
                          ),
                          new Align(
                              alignment: Alignment.topRight,
                              child: SizedBox(
                                height: 30,
                                width: 30,
                                child: FloatingActionButton(
                                  heroTag: 'show4',
                                  mini: true,
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => ShowFullScreen(url: urls[3],))
                                    );
                                  },
                                  backgroundColor: Colors.red,
                                  child: Icon(
                                    Icons.open_in_new,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                          )
                        ],
                      ),
                    )
                ),
                GestureDetector(
                    onTap: () {
                    },
                    child: Container(
                      child: img5 == null ?
                      Container(
                        color: Colors.black12,
                        child: Center(child: Text('Empty')),
                      )  :
                      Stack(
                        children: <Widget>[
                          new Container(
                            child: Center(child: Image.network(urls[4])),
                          ),
                          new Align(
                              alignment: Alignment.topRight,
                              child: SizedBox(
                                height: 30,
                                width: 30,
                                child: FloatingActionButton(
                                  heroTag: 'show5',
                                  mini: true,
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => ShowFullScreen(url: urls[4],))
                                    );
                                  },
                                  backgroundColor: Colors.red,
                                  child: Icon(
                                    Icons.open_in_new,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                          )
                        ],
                      ),
                    )
                ),
                GestureDetector(
                    onTap: () {
                    },
                    child: Container(
                      child: img6 == null ?
                      Container(
                        color: Colors.black12,
                        child: Center(child: Text('Empty')),
                      )  :
                      Stack(
                        children: <Widget>[
                          new Container(
                            child: Center(child: Image.network(urls[5])),
                          ),
                          new Align(
                              alignment: Alignment.topRight,
                              child: SizedBox(
                                height: 30,
                                width: 30,
                                child: FloatingActionButton(
                                  heroTag: 'show6',
                                  mini: true,
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => ShowFullScreen(url: urls[5],))
                                    );
                                  },
                                  backgroundColor: Colors.red,
                                  child: Icon(
                                    Icons.open_in_new,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                          )
                        ],
                      ),
                    )
                ),
              ],
            ),
            /*Container(
            padding: EdgeInsets.only(top: 5),
            child:
              (imageUpload[0] != null || imageUpload[1] !=null || imageUpload[2] != null ||
              imageUpload[3] != null || imageUpload[4] !=null || imageUpload[5] !=null)
                  ? FlatButton(
                onPressed: () {},
                color: Colors.red,
                child: Text(
                  'Upload',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                )
                  : Container(margin: EdgeInsets.only(top: 5, bottom: 10),child:Text('Nothing to upload')),
          )*/
          ],
        ),
      );
    }



    showAlertDialog(BuildContext context, String di) {

      // set up the button
      Widget okButton = FlatButton(
        child: Text("Okay"),
        onPressed: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      );

      // set up the AlertDialog
      AlertDialog alert = AlertDialog(
        title: Text("Success"),
        content: Text(di),
        actions: [
          okButton,
        ],
      );

      // show the dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return alert;
        },
      );
    }

    Widget uploadImagesArea() {
      return Container(
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  blurRadius: 5,
                  spreadRadius: 1,
                  offset: Offset(0, 4)
              )
            ]
        ),
        child: Column(
          children: <Widget>[
            SizedBox(height: 15,),
            Text(
              'Bill Image(s)',
              style: TextStyle(
                color: Colors.deepOrangeAccent,
                fontSize: 20,
                fontStyle: FontStyle.italic,
              ),
            ),
            GridView.count(
              shrinkWrap: true,
              primary: false,
              padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              crossAxisCount: 3,
              children: <Widget>[
                GestureDetector(
                    onTap: () {
                    },
                    child: Container(
                      child: occupied[0] != 1 ?
                      GestureDetector(
                        onTap: (() {
                          _getImages(0);
                        }),
                        child: Container(
                          color: Colors.black12,
                          child: Center(child: Icon(Icons.add)),
                        ),
                      )  :
                      Stack(
                        children: <Widget>[
                          new Container(
                            child: Center(child : fromFile[0] == 1 ? Image.file(File(imageUpload[0].path)) : Image.network(billurls[0])),
                          ),
                          new Align(
                              alignment: Alignment.topRight,
                              child: SizedBox(
                                height: 30,
                                width: 30,
                                child: FloatingActionButton(
                                  mini: true,
                                  heroTag: 'click1bill',
                                  onPressed: () {
                                    setState(() {
                                      occupied[0] = 0;
                                      fromFile[0] = 1;
                                    });
                                  },
                                  backgroundColor: Colors.red,
                                  child: Icon(
                                    Icons.clear,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                          ),
                          new Align(
                              alignment: Alignment.topLeft,
                              child: SizedBox(
                                height: 30,
                                width: 30,
                                child: FloatingActionButton(
                                  mini: true,
                                  heroTag: 'click2bill',
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => ShowFullScreen(url: billurls[0],))
                                    );
                                  },
                                  backgroundColor: Colors.blue,
                                  child: Icon(
                                    Icons.open_in_new,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                          )

                        ],
                      ),
                    )
                ),
                GestureDetector(
                    onTap: () {
                    },
                    child: Container(
                      child: occupied[1] != 1 ?
                      GestureDetector(
                        onTap: (() {
                          _getImages(1);
                        }),
                        child: Container(
                          color: Colors.black12,
                          child: Center(child: Icon(Icons.add)),
                        ),
                      )  :
                      Stack(
                        children: <Widget>[
                          new Container(
                            child: Center(child : fromFile[1] == 1 ? Image.file(File(imageUpload[1].path)) : Image.network(billurls[1])),
                          ),
                          new Align(
                              alignment: Alignment.topRight,
                              child: SizedBox(
                                height: 30,
                                width: 30,
                                child: FloatingActionButton(
                                  mini: true,
                                  heroTag: 'click1bill2',
                                  onPressed: () {
                                    setState(() {
                                      occupied[1] = 0;
                                      fromFile[1] = 1;
                                    });
                                  },
                                  backgroundColor: Colors.red,
                                  child: Icon(
                                    Icons.clear,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                          ),
                          new Align(
                              alignment: Alignment.topLeft,
                              child: SizedBox(
                                height: 30,
                                width: 30,
                                child: FloatingActionButton(
                                  mini: true,
                                  heroTag: 'click2bill2',
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => ShowFullScreen(url: billurls[1],))
                                    );
                                  },
                                  backgroundColor: Colors.blue,
                                  child: Icon(
                                    Icons.open_in_new,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                          )

                        ],
                      ),
                    )
                ),
                GestureDetector(
                    onTap: () {
                    },
                    child: Container(
                      child: occupied[2] != 1 ?
                      GestureDetector(
                        onTap: (() {
                          _getImages(2);
                        }),
                        child: Container(
                          color: Colors.black12,
                          child: Center(child: Icon(Icons.add)),
                        ),
                      )  :
                      Stack(
                        children: <Widget>[
                          new Container(
                            child: Center(child : fromFile[2] == 1 ? Image.file(File(imageUpload[2].path)) : Image.network(billurls[2])),
                          ),
                          new Align(
                              alignment: Alignment.topRight,
                              child: SizedBox(
                                height: 30,
                                width: 30,
                                child: FloatingActionButton(
                                  mini: true,
                                  heroTag: 'click1bill3',
                                  onPressed: () {
                                    setState(() {
                                      occupied[2] = 0;
                                      fromFile[2] = 1;
                                    });
                                  },
                                  backgroundColor: Colors.red,
                                  child: Icon(
                                    Icons.clear,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                          ),
                          new Align(
                              alignment: Alignment.topLeft,
                              child: SizedBox(
                                height: 30,
                                width: 30,
                                child: FloatingActionButton(
                                  mini: true,
                                  heroTag: 'click2bill3',
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => ShowFullScreen(url: billurls[2],))
                                    );
                                  },
                                  backgroundColor: Colors.blue,
                                  child: Icon(
                                    Icons.open_in_new,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                          )

                        ],
                      ),
                    )
                ),
                GestureDetector(
                    onTap: () {
                    },
                    child: Container(
                      child: occupied[3] != 1 ?
                      GestureDetector(
                        onTap: (() {
                          _getImages(3);
                        }),
                        child: Container(
                          color: Colors.black12,
                          child: Center(child: Icon(Icons.add)),
                        ),
                      )  :
                      Stack(
                        children: <Widget>[
                          new Container(
                            child: Center(child : fromFile[3] == 1 ? Image.file(File(imageUpload[3].path)) : Image.network(billurls[3])),
                          ),
                          new Align(
                              alignment: Alignment.topRight,
                              child: SizedBox(
                                height: 30,
                                width: 30,
                                child: FloatingActionButton(
                                  mini: true,
                                  heroTag: 'click1',
                                  onPressed: () {
                                    setState(() {
                                      occupied[3] = 0;
                                      fromFile[3] = 1;
                                    });
                                  },
                                  backgroundColor: Colors.red,
                                  child: Icon(
                                    Icons.clear,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                          ),
                          new Align(
                              alignment: Alignment.topLeft,
                              child: SizedBox(
                                height: 30,
                                width: 30,
                                child: FloatingActionButton(
                                  mini: true,
                                  heroTag: 'click2bill4',
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => ShowFullScreen(url: billurls[3],))
                                    );
                                  },
                                  backgroundColor: Colors.blue,
                                  child: Icon(
                                    Icons.open_in_new,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                          )

                        ],
                      ),
                    )
                ),
                GestureDetector(
                    onTap: () {
                    },
                    child: Container(
                      child: occupied[4] != 1 ?
                      GestureDetector(
                        onTap: (() {
                          _getImages(4);
                        }),
                        child: Container(
                          color: Colors.black12,
                          child: Center(child: Icon(Icons.add)),
                        ),
                      )  :
                      Stack(
                        children: <Widget>[
                          new Container(
                            child: Center(child : fromFile[4] == 1 ? Image.file(File(imageUpload[4].path)) : Image.network(billurls[4])),
                          ),
                          new Align(
                              alignment: Alignment.topRight,
                              child: SizedBox(
                                height: 30,
                                width: 30,
                                child: FloatingActionButton(
                                  mini: true,
                                  heroTag: 'click1bill42',
                                  onPressed: () {
                                    setState(() {
                                      occupied[4] = 0;
                                      fromFile[4] = 1;
                                    });
                                  },
                                  backgroundColor: Colors.red,
                                  child: Icon(
                                    Icons.clear,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                          ),
                          new Align(
                              alignment: Alignment.topLeft,
                              child: SizedBox(
                                height: 30,
                                width: 30,
                                child: FloatingActionButton(
                                  mini: true,
                                  heroTag: 'click2bill',
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => ShowFullScreen(url: billurls[4],))
                                    );
                                  },
                                  backgroundColor: Colors.blue,
                                  child: Icon(
                                    Icons.open_in_new,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                          )

                        ],
                      ),
                    )
                ),
                GestureDetector(
                    onTap: () {
                    },
                    child: Container(
                      child: occupied[5] != 1 ?
                      GestureDetector(
                        onTap: (() {
                          _getImages(5);
                        }),
                        child: Container(
                          color: Colors.black12,
                          child: Center(child: Icon(Icons.add)),
                        ),
                      )  :
                      Stack(
                        children: <Widget>[
                          new Container(
                            child: Center(child : fromFile[5] == 1 ? Image.file(File(imageUpload[5].path)) : Image.network(billurls[5])),
                          ),
                          new Align(
                              alignment: Alignment.topRight,
                              child: SizedBox(
                                height: 30,
                                width: 30,
                                child: FloatingActionButton(
                                  mini: true,
                                  heroTag: 'clicasdk1',
                                  onPressed: () {
                                    setState(() {
                                      occupied[5] = 0;
                                      fromFile[5] = 1;
                                    });
                                  },
                                  backgroundColor: Colors.red,
                                  child: Icon(
                                    Icons.clear,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                          ),
                          new Align(
                              alignment: Alignment.topLeft,
                              child: SizedBox(
                                height: 30,
                                width: 30,
                                child: FloatingActionButton(
                                  mini: true,
                                  heroTag: 'clicasdaqk2',
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => ShowFullScreen(url: billurls[5],))
                                    );
                                  },
                                  backgroundColor: Colors.blue,
                                  child: Icon(
                                    Icons.open_in_new,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                          )

                        ],
                      ),
                    )
                ),
              ],
            ),
          ],
        ),
      );
    }

    uploadForm() async{

      setState(() {showUploadingScreen = true;});
      List<StorageUploadTask> tasks = new List(6);
      List<String> files = new List(6);
      var now = DateTime.now();
      String formattedTime = DateFormat('kk:mm EEE d MMM').format(now);

      for(int i=0; i<imageUpload.length; i++)
      {
        if(imageUpload[i] != null)
        {
          print('OVER HERE');
          String imgExtension = imageUpload[i].path.split('/').last.split('.').last;
          String filename = formattedTime + '_bill_' + '_Pic_' + i.toString() + '.' +imgExtension;
          files[i] = filename;
          setState(() {
            _uploadStatus[i] = firebaseStorageRef.child(filename).putFile((File(imageUpload[i].path)));
          });
          String billName = 'billImg' + (i+1).toString();
          await Firestore.instance.collection('forms').document(widget.post.documentID).updateData({billName: files[i], 'billsAttached': true});
        }
      }
    }


    approve() async{
      setState(() {
        loading = true;
      });
      var currentTime = DateTime.now();
      await db.collection('forms').document(widget.post.documentID).updateData({'status': 'stage4','procurementApproval' : 1, 'procurementApprovalBy': widget.user.name, 'procurementApprovalByUid': widget.user.uid, 's4c': currentTime});
      await uploadForm();

      print('completed');
      showAlertDialog(context, 'Sent To Quality Check');
    }



    Widget displayForm()
    {
      return Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              plotValue('Time', widget.post.data['dateTime']),
              plotValue('Sender Name', widget.post.data['senderName']),
              plotValue('Form Status', widget.post.data['status']),
              plotValue('Receiver(s)', widget.post.data['receiverName1'] +'\n'+
                  widget.post.data['receiverName2']),
              plotValue('First Field', widget.post.data['firstField']),
              plotValue('Second Field', widget.post.data['secondField']),
              imagesArea(
                urls[0],
                urls[1],
                urls[2],
                urls[3],
                urls[4],
                urls[5],
              ),
              SizedBox(height: 5),
              uploadImagesArea(),
              Row(
                children: <Widget>[
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        approve();
                      },
                      child: Container(
                          height: 40,
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.green,
                          ),
                          child: Center(
                            child: Text(
                              'Send for QC Aproval',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          )
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )
      );
    }




    return Scaffold(
        key: key,
        appBar: AppBar(
          iconTheme: new IconThemeData(color: Colors.indigo[800]),
          elevation: 6,
          backgroundColor: Colors.white,
          title: Text(
            widget.post.data['dateTime'],
            style: TextStyle(
              color: Colors.indigo[800],
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0,
            ),
          ),
          centerTitle: true,
        ),
        drawer: SafeArea(
          child: Drawer(
            child: SingleChildScrollView(child: formDetailDrawer()),
          ),
        ),
        endDrawer: SafeArea(
          child: Drawer(
            child: searchContainer(),
          ),
        ),
        body: SingleChildScrollView(
          child: loading == true ? Container(height: MediaQuery.of(context).size.height, width: MediaQuery.of(context).size.width,color:Colors.white, child: Center(child: CircularProgressIndicator(), heightFactor: 10,)) : displayForm(),
        )
    );
  }


  Widget formDetailDrawer() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      color: Colors.blue[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Text(
              'Form Details',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w600,
                color: getColorFromHex('03045e'),
              ),
            ),
          ),
          Divider(
            height: 30,
            thickness: 1,
            color: Colors.grey[850],
          ),
          Center(
              child: Text(
                  'Status',
                  style: TextStyle(
                    color: getColorFromHex('03045e'),
                    fontSize: 20,
                  )
              )
          ),
          Container(
            margin: EdgeInsets.only(top: 10),
            height: 70,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  child: FractionallySizedBox(
                      widthFactor: 0.7,
                      child: Center(
                          child: Text('Head(s) Approval:',
                            style: TextStyle(
                              fontSize: 15,
                            ),)
                      )
                  ),
                ),
                Flexible(
                    child: FractionallySizedBox(
                        widthFactor: 1.25,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Flexible(
                                flex: 1,
                                child: Column(
                                  children: <Widget>[
                                    whichIconHead1(),
                                    Center(
                                        child: Text(
                                          receiverNames[0],
                                          textAlign: TextAlign.center,
                                        )),
                                  ],
                                )
                            ),
                            Flexible(
                                flex: 1,
                                child: Column(
                                  children: <Widget>[
                                    whichIconHead2(),
                                    Center(
                                        child: Text(
                                          receiverNames[1],
                                          textAlign: TextAlign.center,
                                        )
                                    )
                                  ],
                                )
                            ),
                          ],
                        )
                    )
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10),
            height: 70,
            child: Row(
              children: <Widget>[
                Flexible(
                  child: FractionallySizedBox(
                      widthFactor: 0.7,
                      child: Center(
                          child: Text('Market Survey Approval:',
                              style: TextStyle(
                                fontSize: 15,
                              ))
                      )
                  ),
                ),
                Flexible(
                    child: FractionallySizedBox(
                        widthFactor: 1.25,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Flexible(
                                flex: 1,
                                child: Column(
                                  children: <Widget>[
                                    marketSurveyReceiverIcon(),
                                    Center(
                                      child: marketSurveyReceiver(),
                                    ),
                                  ],
                                )
                            ),
                          ],
                        )
                    )
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10),
            height: 70,
            child: Row(
              children: <Widget>[
                Flexible(
                  child: FractionallySizedBox(
                      widthFactor: 0.7,
                      child: Center(
                          child: Text('Treasurer Approval:',
                              style: TextStyle(
                                fontSize: 15,
                              ))
                      )
                  ),
                ),
                Flexible(
                    child: FractionallySizedBox(
                        widthFactor: 1.25,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Flexible(
                                flex: 1,
                                child: Column(
                                  children: <Widget>[
                                    treasurerReceiverIcon(),
                                    Center(
                                      child: treasurerReceiver(),
                                    ),
                                  ],
                                )
                            ),
                          ],
                        )
                    )
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10),
            height: 70,
            child: Row(
              children: <Widget>[
                Flexible(
                  child: FractionallySizedBox(
                      widthFactor: 0.7,
                      child: Center(
                          child: Text('Procurement Approval:',
                              style: TextStyle(
                                fontSize: 15,
                              ))
                      )
                  ),
                ),
                Flexible(
                    child: FractionallySizedBox(
                        widthFactor: 1.25,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Flexible(
                                flex: 1,
                                child: Column(
                                  children: <Widget>[
                                    procurementReceiverIcon(),
                                    Center(
                                      child: procurementReceiver(),
                                    ),
                                  ],
                                )
                            ),
                          ],
                        )
                    )
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10),
            height: 70,
            child: Row(
              children: <Widget>[
                Flexible(
                  child: FractionallySizedBox(
                      widthFactor: 0.7,
                      child: Center(
                          child: Text('Quality-Check Approval:',
                              style: TextStyle(
                                fontSize: 15,
                              ))
                      )
                  ),
                ),
                Flexible(
                    child: FractionallySizedBox(
                        widthFactor: 1.25,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Flexible(
                                flex: 1,
                                child: Column(
                                  children: <Widget>[
                                    qcReceiverIcon(),
                                    Center(
                                      child: qcReceiver(),
                                    ),
                                  ],
                                )
                            ),
                          ],
                        )
                    )
                ),
              ],
            ),
          ),
          Divider(
            height: 30,
            thickness: 1,
            color: Colors.grey[850],
          ),
          Center(
              child: Text(
                  'Remarks',
                  style: TextStyle(
                    color: getColorFromHex('03045e'),
                    fontSize: 20,
                  )
              )
          ),
          Container(
            child: remarkList(),
          ),
          SizedBox(height: 100),
        ],
      ),
    );
  }


  remarkList() {
    if(widget.post.data['remarks'].length > 0) {
      print('herer');
      print(widget.post.data['remarks'].length);
      print(widget.post.data['remarks'][0]['remark']);
      return Container(
        width: 400,
        child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: widget.post.data['remarks'].length,
            itemBuilder: (_, index) {
              print('inside');
              return Container(
                margin: EdgeInsets.symmetric(vertical:10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(widget.post.data['remarks'][index]['time'],
                        style: TextStyle(
                          fontSize: 15,
                        )),
                    Text(widget.post.data['remarks'][index]['person'],
                        style: TextStyle(
                          fontSize: 15,
                        )),
                    Text(widget.post.data['remarks'][index]['remark'],
                        style: TextStyle(
                          color:Colors.red,
                          fontSize: 15,
                        )
                    ),
                  ],
                ),
              );
            }
        ),
      );
    } else {
      return Text('no remarks');
    }
  }

  marketSurveyReceiverIcon() {
    return widget.post.data['marketSurveyApproval'] == 0 ?
    Icon(
      Icons.access_time,
      color: Colors.grey,
    ) :
    widget.post.data['marketSurveyApproval'] == 1 ?
    Icon(
        Icons.done,
        color: Colors.green
    ) :
    Icon(
        Icons.clear,
        color: Colors.red
    );
  }
  marketSurveyReceiver() {
    return widget.post.data['marketSurveyApprovalBy'] != null ?
    Text(widget.post.data['marketSurveyApprovalBy']) : Text('Awaiting');
  }

  treasurerReceiverIcon() {
    return widget.post.data['treasurerApproval'] == 0 ?
    Icon(
      Icons.access_time,
      color: Colors.grey,
    ) :
    widget.post.data['treasurerApproval'] == 1 ?
    Icon(
        Icons.done,
        color: Colors.green
    ) :
    Icon(
        Icons.clear,
        color: Colors.red
    );
  }
  treasurerReceiver() {
    return widget.post.data['treasurerApprovalBy'] != null ?
    Text(widget.post.data['treasurerApprovalBy']) : Text('Awaiting');
  }

  qcReceiverIcon() {
    return widget.post.data['qcApproval'] == 0 ?
    Icon(
      Icons.access_time,
      color: Colors.grey,
    ) :
    widget.post.data['qcApproval'] == 1 ?
    Icon(
        Icons.done,
        color: Colors.green
    ) :
    Icon(
        Icons.clear,
        color: Colors.red
    );
  }
  qcReceiver() {
    return widget.post.data['qcApprovalBy'] != null ?
    Text(widget.post.data['qcApprovalBy']) : Text('Awaiting');
  }

  procurementReceiverIcon() {
    return widget.post.data['procurementApproval'] == 0 ?
    Icon(
      Icons.access_time,
      color: Colors.grey,
    ) :
    widget.post.data['procurementApproval'] == 1 ?
    Icon(
        Icons.done,
        color: Colors.green
    ) :
    Icon(
        Icons.clear,
        color: Colors.red
    );
  }
  procurementReceiver() {
    return widget.post.data['procurementApprovalBy'] != null ?
    Text(widget.post.data['procurementApprovalBy']) : Text('Awaiting');
  }

  whichIconHead1() {
    return widget.post.data['approval1'] == 0 ?
    Icon(
      Icons.access_time,
      color: Colors.grey,
    ) :
    widget.post.data['approval1'] == 1 ?
    Icon(
        Icons.done,
        color: Colors.green
    ) :
    Icon(
        Icons.clear,
        color: Colors.red
    );
  }
  whichIconHead2() {
    return widget.post.data['approval2'] == 0 ?
    Icon(
      Icons.access_time,
      color: Colors.grey,
    ) :
    widget.post.data['approval2'] == 1 ?
    Icon(
        Icons.done,
        color: Colors.green
    ) :
    Icon(
        Icons.clear,
        color: Colors.red
    );
  }

  bool showResults=false;
  TextEditingController searchBar = TextEditingController();
  getSearchResults() {

    if(showResults == true) {
      String ipString = searchBar.text;

      if(searchBar.text.isEmpty) {
        return Text('Search a code');
      }
      else {
        int lengthOfCodes = ipString.length ~/ 2;

        return ListView.builder(
            itemCount: lengthOfCodes,
            itemBuilder: (context, index) {
              String ipSubString = ipString.substring(2*index, (2*index)+2).toUpperCase();
              return Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          blurRadius: 5,
                          spreadRadius: 1,
                          offset: Offset(0, 4)
                      )
                    ]
                ),
                margin: EdgeInsets.fromLTRB(5, 0, 5, 10),
                child: ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(10),
                    child: Text(ipSubString,
                      style: TextStyle(
                        color: getColorFromHex('03045e'),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  title: JsonResult[ipSubString] != null ? Text(JsonResult[ipSubString]) : Text('No such Abbrevation'),
                ),
              );
            });
      }
    }
    if(showResults == false)
    {
      return Text('Search a code');
    }
  }
  Widget searchContainer() {
    return Container(
      color: Colors.blue[50],
      child: Padding(
          padding: const EdgeInsets.all(10.0),

          child: Column(
            children: <Widget>[
              TextField(
                  controller: searchBar,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(width: 0.8),
                    ),
                    hintText: 'Search Abbrevation',
                    prefixIcon: Icon(
                      Icons.search,
                      size: 30,
                    ),
                  ),
                  onChanged: (val) {
                    setState(() => showResults = true);
                  }
              ),
              Divider(
                height: 30,
                thickness: 1,
                color: Colors.grey[850],
              ),
              Expanded(
                  child: getSearchResults()
              ),

            ],
          )
      ),
    );
  }
}

