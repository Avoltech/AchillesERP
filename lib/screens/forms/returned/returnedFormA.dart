import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:achilleserp/models/forms.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:achilleserp/models/user.dart';
import 'package:achilleserp/screens/forms/fullScreenImage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:achilleserp/services/formServices.dart';
import 'package:achilleserp/screens/forms/fullScreenImageFile.dart';
import 'dart:convert';
import 'package:achilleserp/services/hex_to_color.dart';




class returnedFormA extends StatefulWidget {
  final DocumentSnapshot post;
  final User user;
  returnedFormA({Key key, this.post, this.user}) : super(key: key);

  @override
  _returnedFormAState createState() => _returnedFormAState();
}

class _returnedFormAState extends State<returnedFormA> {

  int receiverCount = 2;
  List <String> receiverUids =  ['9hm9y2c08pdAS5zZcnJRSH3TnsZ2', 'zpYyXei6FjU1qzrI4AviUK0QudE3'];
  List <String> receiverNames = ['Sumedh Boralkar', 'Rahul Tak'];


  TextEditingController searchBar = TextEditingController();
  var JsonResult;
  bool showResult = false;


  loadJSONData() async {
    String codes = await DefaultAssetBundle.of(context).loadString('assets/codes.json');
    JsonResult = json.decode(codes);
  }


  bool showUploadingScreen = false;
  bool loading = true;
  bool onlyOnce = true;
  var filepath;
  final key = new GlobalKey<ScaffoldState>();
  var remarkController = TextEditingController();

  final _formkey = GlobalKey<FormState>();


  TextEditingController firstFieldController;
  TextEditingController secondFieldController;

  loadFields() async {
    firstFieldController = TextEditingController(text: widget.post.data['firstField']);
    secondFieldController = TextEditingController(text: widget.post.data['secondField']);
  }


  List <StorageUploadTask> _uploadStatus = new List(6);
  final StorageReference firebaseStorageRef = FirebaseStorage.instance.ref();

  List<String> urls = new List(6);


  final picker = ImagePicker();
  List <int> already = new List(6);
  List <dynamic> imageUpload = new List(6);



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadFields();
  }

  List<StorageReference> imgRefs = new List(6);
  List occupied = new List(6);
  List fromFile = new List(6);

  @override
  Widget build(BuildContext context) {

    loadJSONData();


    loadUrls() async{
      print('-------IN LOADING URLS');
      for(int i=0; i<6; i++) {
        if(imgRefs[i] != null) {
          await imgRefs[i].getDownloadURL().then((value) => setState(() => urls[i] = value));
          print('++++++====');
          print(urls[i]);
        }
      }
      setState(() {loading = false;});
    }

    if(onlyOnce == true)
    {
      imgRefs = [
        widget.post.data['img1'] == null ? null : FirebaseStorage.instance.ref().child(widget.post.data['img1']),
        widget.post.data['img2'] == null ? null : FirebaseStorage.instance.ref().child(widget.post.data['img2']),
        widget.post.data['img3'] == null ? null : FirebaseStorage.instance.ref().child(widget.post.data['img3']),
        widget.post.data['img4'] == null ? null : FirebaseStorage.instance.ref().child(widget.post.data['img4']),
        widget.post.data['img5'] == null ? null : FirebaseStorage.instance.ref().child(widget.post.data['img5']),
        widget.post.data['img6'] == null ? null : FirebaseStorage.instance.ref().child(widget.post.data['img6']),
      ];

      occupied[0] = widget.post.data['img1'] == null ? null : 1;
      occupied[1] = widget.post.data['img2'] == null ? null : 1;
      occupied[2] = widget.post.data['img3'] == null ? null : 1;
      occupied[3] = widget.post.data['img4'] == null ? null : 1;
      occupied[4] = widget.post.data['img5'] == null ? null : 1;
      occupied[5] = widget.post.data['img6'] == null ? null : 1;

      fromFile[0] = occupied[0] == 1 ? 0 : 1;
      fromFile[1] = occupied[1] == 1 ? 0 : 1;
      fromFile[2] = occupied[2] == 1 ? 0 : 1;
      fromFile[3] = occupied[3] == 1 ? 0 : 1;
      fromFile[4] = occupied[4] == 1 ? 0 : 1;
      fromFile[5] = occupied[5] == 1 ? 0 : 1;


    onlyOnce = false;
      loadUrls();
    }



    final remarkFormKey = GlobalKey<FormState>();

    firstForm form = firstForm();

    List <bool> imageArr = new List(6);
    List <bool> already = new List(6);

    showAlertDialog(BuildContext context, String di) {

      List <String> dialogs = ['Form Submitted Successfully', 'Form has been approved by you.', 'Form has been disapproved by you.'];
      String dialog;

      if(di == 'uploaded' ) {dialog = dialogs[0];}
      if(di == 'approved' ) {dialog = dialogs[1];}
      if(di == 'disapproved' ) {dialog = dialogs[2];}

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
        content: Text(dialog),
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

    updateForm() async{

      setState(() {loading = true;});
      List<StorageUploadTask> tasks = new List(6);
      List<String> files = new List(6);
      var now = DateTime.now();
      String formattedTime = DateFormat('kk:mm:ss_EEE_d_MMM').format(now);

      for(int i=0; i<imageUpload.length; i++)
      {
        if(imageUpload[i] != null)
        {
          print('OVER HERE');
          String imgExtension = imageUpload[i].path.split('/').last.split('.').last;
          String filename = formattedTime + '_' +widget.user.name +'_Pic_' + i.toString() + '.' +imgExtension;
          files[i] = filename;
          setState(() {
            _uploadStatus[i] = firebaseStorageRef.child(filename).putFile((File(imageUpload[i].path)));
          });
        }
      }

      String getImageName(int index) {
        switch(index) {
          case 0: return widget.post.data['img1'];
          case 1: return widget.post.data['img2'];
          case 2: return widget.post.data['img3'];
          case 3: return widget.post.data['img4'];
          case 4: return widget.post.data['img5'];
          case 5: return widget.post.data['img6'];
        }
      }

      List imageUpdates = new List(6);
      for(int i=0; i<6; i++)
        {
          if(occupied[i] ==1 ) {
            if( fromFile[i] == 1) {
              imageUpdates[i] = files[i];
            }
            else {
              imageUpdates[i] = getImageName(i);
            }
          }
          else {
            imageUpdates[i] = null;
          }
        }

      final CollectionReference formsReference = await Firestore.instance.collection('forms');

      var s0c = DateTime.now();
      dynamic res = formsReference.document(widget.post.documentID).updateData({
          'approval1': 0,
          'approval2': 0,
          'procurementReceiver' : null,
          'procurementApproval' : 0,
          'procurementApprovalBy' : null,
          'treasurerApproval' : 0,
          'treasurerApprovalBy' : null,
          'qcApproval' : 0,
          'qcApprovalBy' : null,
          'status': 'stage0',
          'firstField':  firstFieldController.text,
          'secondField':  secondFieldController.text,
          'img1': imageUpdates[0],
          'img2':  imageUpdates[1],
          'img3':  imageUpdates[2],
          'img4':  imageUpdates[3],
          'img5':  imageUpdates[4],
          'img6':  imageUpdates[5],
          's0c': s0c,
      });

      if(res!=null) {

        for(int i=0; i<6; i++)
        {
          if(_uploadStatus[i] != null)
          {
            StorageTaskSnapshot taskSnapshot = await _uploadStatus[i].onComplete;
          }
        }
        showAlertDialog(context, 'uploaded');
      }
      else {
        print('Failed');
      }
    }


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


    Widget imagesArea() {
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
                      child: occupied[0] != 1 ?
                      GestureDetector(
                        onTap: (() {
                          _getImages(0);
                        }),
                        child: Container(
                          color: Colors.black12,
                          child: Center(child: Text('Empty')),
                        ),
                      )  :
                      Stack(
                        children: <Widget>[
                          new Container(
                            child: Center(child : fromFile[0] == 1 ? Image.file(File(imageUpload[0].path)) : Image.network(urls[0])),
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
                                  heroTag: 'click2',
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => ShowFullScreen(url: urls[0],))
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
                          child: Center(child: Text('Empty')),
                        ),
                      )  :
                      Stack(
                        children: <Widget>[
                          new Container(
                            child: Center(child : fromFile[1] == 1 ? Image.file(File(imageUpload[1].path)) : Image.network(urls[1])),
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
                                  heroTag: 'click2',
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => ShowFullScreen(url: urls[1],))
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
                          child: Center(child: Text('Empty')),
                        ),
                      )  :
                      Stack(
                        children: <Widget>[
                          new Container(
                            child: Center(child : fromFile[2] == 1 ? Image.file(File(imageUpload[2].path)) : Image.network(urls[2])),
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
                                  heroTag: 'click2',
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => ShowFullScreen(url: urls[2],))
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
                          child: Center(child: Text('Empty')),
                        ),
                      )  :
                      Stack(
                        children: <Widget>[
                          new Container(
                            child: Center(child : fromFile[3] == 1 ? Image.file(File(imageUpload[3].path)) : Image.network(urls[3])),
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
                                  heroTag: 'click2',
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => ShowFullScreen(url: urls[3],))
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
                          child: Center(child: Text('Empty')),
                        ),
                      )  :
                      Stack(
                        children: <Widget>[
                          new Container(
                            child: Center(child : fromFile[4] == 1 ? Image.file(File(imageUpload[4].path)) : Image.network(urls[4])),
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
                                  heroTag: 'click2',
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => ShowFullScreen(url: urls[4],))
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
                          child: Center(child: Text('Empty')),
                        ),
                      )  :
                      Stack(
                        children: <Widget>[
                          new Container(
                            child: Center(child : fromFile[5] == 1 ? Image.file(File(imageUpload[5].path)) : Image.network(urls[5])),
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
                                  heroTag: 'click2',
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => ShowFullScreen(url: urls[5],))
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


    Widget displayForm()
    {
      return Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              plotValue('Remarks', widget.post.data['remarks']),
              plotValue('Form Number', widget.post.data['formNumber'].toString()  ),
              plotValue('Time', widget.post.data['dateTime']),
              plotValue('Sender Name', widget.post.data['senderName']),
              plotValue('Form Status', widget.post.data['status']),
              plotValue('Form Type', widget.post.data['formType']),
              plotValue('Receiver1', widget.post.data['receiverName1']),
              plotValue('Receiver2', widget.post.data['receiverName2']),
              plotValue('First Field', widget.post.data['firstField']),
              plotValue('Second Field', widget.post.data['secondField']),
              imagesArea(), // plotValue()
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
        endDrawer: Drawer(
          child: searchContainer(),
        ),
        body: SingleChildScrollView(
          child: loading == true ? Expanded(child: Center(child: CircularProgressIndicator(), heightFactor: 10,)) :
          Form(
          key: _formkey,
          child: Column(
            children: <Widget>[
              _formNumber(),
              SizedBox(height: 20,),
              _formDateTime(),
              SizedBox(height: 20,),
              _senderField(widget.user.name),
              SizedBox(height: 20,),
              _formType(),
              SizedBox(height: 20),
              _receiverField(),
              SizedBox(height: 20),
              _firstField(),
              SizedBox(height: 20),
              _secondField(),
              SizedBox(height: 20),
              imagesArea(),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      height:40,
                      child: FlatButton(
                          color: Colors.amber[800],
                          onPressed: () {
                            if (_formkey.currentState.validate()) {
                              updateForm();
                            }
                          },
                          child: Center(
                            child: Text(
                              'Submit',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          )
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        )
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

  treasurerReceiver() {
    return widget.post.data['treasurerApprovedBy'] != null ?
    Text(widget.post.data['treasurerApprovedBy']) : Text('Awaiting');
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
    return widget.post.data['qcApprovedBy'] != null ?
    Text(widget.post.data['qcApprovedBy']) : Text('Awaiting');
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
    return widget.post.data['procurementApprovedBy'] != null ?
    Text(widget.post.data['procurementApprovedBy']) : Text('Awaiting');
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


  Widget _formNumber() {
    return TextFormField(
      readOnly: true,
      initialValue: widget.post.data['formNumber'].toString(),
      decoration: InputDecoration(
        labelText: 'Form Type',
        labelStyle: TextStyle(
          color: Colors.orange[800],
          fontSize: 20,
        ),
        fillColor: Colors.white,
        filled: true,
      ),
      style: TextStyle(
        color: Colors.grey[700],
        fontSize: 20,
      ),
    );
  }

  Widget _formDateTime() {
    return TextFormField(
      readOnly: true,
      initialValue: widget.post.data['dateTime'],
      decoration: InputDecoration(
        labelText: 'Form Type',
        labelStyle: TextStyle(
          color: Colors.orange[800],
          fontSize: 20,
        ),
        fillColor: Colors.white,
        filled: true,
      ),
      style: TextStyle(
        color: Colors.grey[700],
        fontSize: 20,
      ),
    );
  }

  Widget _senderField(String sender) {
    return TextFormField(
      readOnly: true,
      initialValue: sender,
      decoration: InputDecoration(
        labelText: 'Sender',
        labelStyle: TextStyle(
            color: Colors.orange[800],
            fontSize: 20
        ),
        fillColor: Colors.white,
        filled: true,
      ),
      style: TextStyle(
        color: Colors.grey[700],
        fontSize: 20,
      ),
    );
  }

  Widget _receiverField() {
    return TextFormField(
      maxLines: null,
      readOnly: true,
      initialValue: receiverNames[0] + '\n' + receiverNames[1],
      decoration: InputDecoration(
        labelText: 'Receiver(s)',
        labelStyle: TextStyle(
          color: Colors.orange[800],
          fontSize: 20,
        ),
        fillColor: Colors.white,
        filled: true,
      ),
      style: TextStyle(
        color: Colors.grey[700],
        fontSize: 20,
      ),
    );
  }

  Widget _formType() {
    return TextFormField(
      readOnly: true,
      initialValue: 'A',
      decoration: InputDecoration(
        labelText: 'Form Type',
        labelStyle: TextStyle(
          color: Colors.orange[800],
          fontSize: 20,
        ),
        fillColor: Colors.white,
        filled: true,
      ),
      style: TextStyle(
        color: Colors.grey[700],
        fontSize: 20,
      ),
    );
  }

  Widget _firstField() {
    return TextFormField(
      controller: firstFieldController,
      maxLines: null,
      //readOnly: true,
      decoration: InputDecoration(
        labelText: 'First Field',
        labelStyle: TextStyle(
          color: Colors.orange[800],
          fontSize: 20,
        ),
        fillColor: Colors.white,
        filled: true,
      ),
      style: TextStyle(
        color: Colors.grey[700],
        fontSize: 20,
      ),
      validator: (val) => val.isEmpty ? 'Empty Field' : null,
    );
  }

  Widget _secondField() {
    return TextFormField(
      controller: secondFieldController,
      maxLines: null,
      //readOnly: true,
      decoration: InputDecoration(
        labelText: 'Second Field',
        labelStyle: TextStyle(
          color: Colors.orange[800],
          fontSize: 20,
        ),
        fillColor: Colors.white,
        filled: true,
      ),
      style: TextStyle(
        color: Colors.grey[700],
        fontSize: 20,
      ),
      validator: (val) => val.isEmpty ? 'Empty Field' : null,
    );
  }


  bool showResults = false;
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


class menuTile extends StatelessWidget {

  final IconData icon_name;
  final String tile_name;

  menuTile({this.icon_name, this.tile_name});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(15),
      // height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.9),
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
          SizedBox(height: 20,),
          Icon(
            icon_name,
            size: 90,
            color: Colors.blue[200],
          ),
          SizedBox(height: 5,),
          Text(
            tile_name,
            style: TextStyle(
              color: Colors.indigo[800],
              fontSize: 18,
            ),
          ),
        ],
      ),

    );
  }


}

