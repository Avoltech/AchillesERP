import 'package:flutter/material.dart';
import 'package:achilleserp/models/user.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/painting.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:achilleserp/screens/loading.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:achilleserp/services/formServices.dart';
import 'package:achilleserp/services/hex_to_color.dart';
import 'dart:convert';

class FormA extends StatefulWidget {

  final User user_;
  FormA({Key key, this.user_}) : super(key: key);


  @override
  _FormAState createState() => _FormAState();
}

class _FormAState extends State<FormA> {

  int receiverCount = 2;
  List <String> receiverUids =  ['9hm9y2c08pdAS5zZcnJRSH3TnsZ2', 'zpYyXei6FjU1qzrI4AviUK0QudE3'];
  List <String> receiverNames = ['Sumedh Boralkar', 'Rahul Tak'];


  var JsonResult;
  TextEditingController searchBar = TextEditingController();
  bool showResults = false;


  List <dynamic> imageUpload = new List(6);
  List <dynamic> showImg = new List(6);
  bool showUploadingScreen = false;
  List <StorageUploadTask> _uploadStatus = new List(6);

  final picker = ImagePicker();
  final StorageReference firebaseStorageRef = FirebaseStorage.instance.ref();

  final _formkey = GlobalKey<FormState>();

  String _senderName = '';
  String _firstInput = '';
  String _secondInput = '';


  loadJSONData() async {
    String codes = await DefaultAssetBundle.of(context).loadString('assets/codes.json');
    JsonResult = json.decode(codes);
  }

  Future _getImages(int index) async {
    var image = await picker.getImage(source: ImageSource.gallery);

    print("IMAGE HERE <<<<>>>>>");
    print(image);
    setState(() {
      imageUpload[index] = image;
    });
  }

  Widget imagesArea() {
    return Container(
      margin: EdgeInsets.all(5),
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
          Text('Add images (if any)'),
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
                    _getImages(0);
                    showImg[0] = true;
                  },
                  child: Container(
                    child: showImg[0] == null ?
                    Container(
                      color: Colors.black12,
                      child: Icon(Icons.add),
                    )  :
                    Stack(
                      children: <Widget>[
                        new Container(
                          child: Center(child: Image.file(File(imageUpload[0].path))),
                        ),
                        new Align(
                            alignment: Alignment.topRight,
                            child: SizedBox(
                              height: 30,
                              width: 30,
                              child: FloatingActionButton(
                                mini: true,
                                onPressed: () {
                                  setState(() {
                                    imageUpload[0] = null;
                                    showImg[0] = null;
                                  });
                                },
                                backgroundColor: Colors.red,
                                child: Icon(
                                  Icons.clear,
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
                    _getImages(1);
                    showImg[1] = true;
                  },
                  child: Container(
                    child: showImg[1] == null ?
                    Container(
                      color: Colors.black12,
                      child: Icon(Icons.add),
                    )  :
                    Stack(
                      children: <Widget>[
                        new Container(
                          child: Center(child: Image.file(File(imageUpload[1].path))),
                        ),
                        new Align(
                            alignment: Alignment.topRight,
                            child: SizedBox(
                              height: 30,
                              width: 30,
                              child: FloatingActionButton(
                                mini: true,
                                onPressed: () {
                                  setState(() {
                                    imageUpload[1] = null;
                                    showImg[1] = null;
                                  });
                                },
                                backgroundColor: Colors.red,
                                child: Icon(
                                  Icons.clear,
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
                    _getImages(2);
                    showImg[2] = true;
                  },
                  child: Container(
                    child: showImg[2] == null ?
                    Container(
                      color: Colors.black12,
                      child: Icon(Icons.add),
                    )  :
                    Stack(
                      children: <Widget>[
                        new Container(
                          child: Center(child: Image.file(File(imageUpload[2].path))),
                        ),
                        new Align(
                            alignment: Alignment.topRight,
                            child: SizedBox(
                              height: 30,
                              width: 30,
                              child: FloatingActionButton(
                                mini: true,
                                onPressed: () {
                                  setState(() {
                                    imageUpload[2] = null;
                                    showImg[20] = null;
                                  });
                                },
                                backgroundColor: Colors.red,
                                child: Icon(
                                  Icons.clear,
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
                    _getImages(3);
                    showImg[3] = true;
                  },
                  child: Container(
                    child: showImg[3] == null ?
                    Container(
                      color: Colors.black12,
                      child: Icon(Icons.add),
                    )  :
                    Stack(
                      children: <Widget>[
                        new Container(
                          child: Center(child: Image.file(File(imageUpload[3].path))),
                        ),
                        new Align(
                            alignment: Alignment.topRight,
                            child: SizedBox(
                              height: 30,
                              width: 30,
                              child: FloatingActionButton(
                                mini: true,
                                onPressed: () {
                                  setState(() {
                                    imageUpload[3] = null;
                                    showImg[3] = null;
                                  });
                                },
                                backgroundColor: Colors.red,
                                child: Icon(
                                  Icons.clear,
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
                    _getImages(4);
                    showImg[4] = true;
                  },
                  child: Container(
                    child: showImg[4] == null ?
                    Container(
                      color: Colors.black12,
                      child: Icon(Icons.add),
                    )  :
                    Stack(
                      children: <Widget>[
                        new Container(
                          child: Center(child: Image.file(File(imageUpload[4].path))),
                        ),
                        new Align(
                            alignment: Alignment.topRight,
                            child: SizedBox(
                              height: 30,
                              width: 30,
                              child: FloatingActionButton(
                                mini: true,
                                onPressed: () {
                                  setState(() {
                                    imageUpload[4] = null;
                                    showImg[4] = null;
                                  });
                                },
                                backgroundColor: Colors.red,
                                child: Icon(
                                  Icons.clear,
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
                    _getImages(5);
                    showImg[5] = true;
                  },
                  child: Container(
                    child: showImg[5] == null ?
                    Container(
                      color: Colors.black12,
                      child: Icon(Icons.add),
                    )  :
                    Stack(
                      children: <Widget>[
                        new Container(
                          child: Center(child: Image.file(File(imageUpload[5].path))),
                        ),
                        new Align(
                            alignment: Alignment.topRight,
                            child: SizedBox(
                              height: 30,
                              width: 30,
                              child: FloatingActionButton(
                                mini: true,
                                onPressed: () {
                                  setState(() {
                                    imageUpload[5] = null;
                                    showImg[5] = null;
                                  });
                                },
                                backgroundColor: Colors.red,
                                child: Icon(
                                  Icons.clear,
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

  uploadForm(String senderName, String senderUid, String status, String formType,
      int receiverCount, String receiverName1, String receiverUid1, String receiverName2, String receiverUid2,
      int approval1, int approval2, String firstField, String secondField) async{

    int formCount = widget.user_.formCounter + 1;

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
        String filename = formattedTime + '_' +senderName +'_Pic_' + i.toString() + '.' +imgExtension;
        files[i] = filename;
        setState(() {
          _uploadStatus[i] = firebaseStorageRef.child(filename).putFile((File(imageUpload[i].path)));
        });
      }
    }
    var s0c = DateTime.now();

    FormAService formA = FormAService();
    dynamic res =  formA.uploadForm(
        formattedTime,
        senderName,
        senderUid,
        'stage0',
        'A',
        receiverCount,
        receiverName1,
        receiverUid1,
        receiverName2,
        receiverUid2,
        0,
        0,
        firstField,
        secondField,
        files[0],
        files[1],
        files[2],
        files[3],
        files[4],
        files[5],
        s0c,
    );

    await Firestore.instance.collection('users').document(widget.user_.uid).updateData({'formCounter': formCount});

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


  @override
  Widget build(BuildContext context) {
    loadJSONData();

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
        builder: (BuildContext context) {
          return alert;
        },
      );
    }

    return showUploadingScreen ?  Container(height: MediaQuery.of(context).size.height, width: MediaQuery.of(context).size.width,color:Colors.white, child: Center(child: CircularProgressIndicator(), heightFactor: 10,)): Scaffold(
        backgroundColor: Colors.blue[50],
        appBar: AppBar(
          iconTheme: new IconThemeData(color: Colors.indigo[800]),
          elevation: 6,
          backgroundColor: Colors.white,
          title: Text(
            "First Form",
            style: TextStyle(
              color: Colors.indigo[800],
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0,
            ),
          ),
          centerTitle: true,
        ),
        endDrawer: SafeArea(
          child: Drawer(
            child: searchContainer(),
          ),
        ),
        body: Container(
          //margin: EdgeInsets.symmetric(vertical: 50, horizontal: 40),
          padding: EdgeInsets.symmetric(vertical: 30, horizontal: 30),
          child: SingleChildScrollView(
              child: Form(
                key: _formkey,
                child: Column(
                  children: <Widget>[
                    _formType(),
                    SizedBox(height: 20,),
                    _senderField(widget.user_.name),
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
                            height: 40,
                            child: FlatButton(
                                color: Colors.amber[800],
                                onPressed: () {
                                  if (_formkey.currentState.validate()) {
                                    uploadForm(widget.user_.name, widget.user_.uid, 'stage0',
                                        'A', receiverCount, receiverNames[0],
                                        receiverUids[0],receiverNames[1],receiverUids[1],
                                        0,0,_firstInput, _secondInput);
                                  }
                                },
                                child: Text(
                                  'Submit',
                                  style: TextStyle(
                                    color: Colors.white,
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
          ),
        )
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
      maxLines: null,
      //readOnly: true,
      //initialValue: 'Super User',
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
      onChanged: (val) {
        setState(() => _firstInput = val);
      },
      validator: (val) => val.isEmpty ? 'Empty Field' : null,
    );
  }

  Widget _secondField() {
    return TextFormField(
      maxLines: null,
      //readOnly: true,
      //initialValue: 'Super User',
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
      onChanged: (val) {
        setState(() => _secondInput = val);
      },
      validator: (val) => val.isEmpty ? 'Empty Field' : null,
    );
  }


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

