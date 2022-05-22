import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:achilleserp/models/forms.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:achilleserp/models/user.dart';
import 'package:achilleserp/screens/forms/fullScreenImage.dart';
import 'package:network_image_to_byte/network_image_to_byte.dart';
import 'dart:convert';
import 'package:achilleserp/services/hex_to_color.dart';


class detailPageFormA extends StatefulWidget {
  final DocumentSnapshot post;
  final User user;
  detailPageFormA({Key key, this.post, this.user}) : super(key: key);

  @override
  _detailPageFormAState createState() => _detailPageFormAState();
}

class _detailPageFormAState extends State<detailPageFormA> {

  int receiverCount = 2;
  List <String> receiverUids =  ['9hm9y2c08pdAS5zZcnJRSH3TnsZ2', 'zpYyXei6FjU1qzrI4AviUK0QudE3'];
  List <String> receiverNames = ['Sumedh Boralkar', 'Rahul Tak'];


  var JsonResult;
  TextEditingController searchBar = TextEditingController();
  bool showResults = false;


  int currentUser;

  bool loading = true;
  bool onlyOnce = true;
  var filepath;
  final key = new GlobalKey<ScaffoldState>();
  var remarkController = TextEditingController();


  List<String> urls = new List(6);
  @override
  void initState() {
    super.initState();
  }

  loadJSONData() async {
    String codes = await DefaultAssetBundle.of(context).loadString('assets/codes.json');
    JsonResult = json.decode(codes);
  }

  @override
  Widget build(BuildContext context) {
    loadJSONData();


    if(widget.user.uid == receiverUids[0]) {
      setState(() => currentUser = 0);
    }
    else {
      setState(() => currentUser = 1);
    }


    final remarkFormKey = GlobalKey<FormState>();

    firstForm form = firstForm();

    final List<StorageReference> imgRefs = [
      widget.post.data['img1'] == null ? null : FirebaseStorage.instance.ref().child(widget.post.data['img1']),
      widget.post.data['img2'] == null ? null : FirebaseStorage.instance.ref().child(widget.post.data['img2']),
      widget.post.data['img3'] == null ? null : FirebaseStorage.instance.ref().child(widget.post.data['img3']),
      widget.post.data['img4'] == null ? null : FirebaseStorage.instance.ref().child(widget.post.data['img4']),
      widget.post.data['img5'] == null ? null : FirebaseStorage.instance.ref().child(widget.post.data['img5']),
      widget.post.data['img6'] == null ? null : FirebaseStorage.instance.ref().child(widget.post.data['img6']),
    ];


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
      onlyOnce = false;
      loadUrls();
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




    Widget displayForm()
    {
      return Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              plotValue('Form Number', widget.post.data['formNumber'].toString()  ),
              plotValue('Form Type', widget.post.data['formType']),
              plotValue('Form Status', widget.post.data['status']),
              plotValue('Time', widget.post.data['dateTime']),
              plotValue('Sender Name', widget.post.data['senderName']),
              plotValue('Receiver1', widget.post.data['receiverName1']),
              plotValue('Receiver2', widget.post.data['receiverName2']),
              plotValue('First Field', widget.post.data['firstField']),
              plotValue('Second Field', widget.post.data['secondField']),
              imagesArea(
                urls[0],
                urls[1],
                urls[2],
                urls[3],
                urls[4],
                urls[5],
              ), // plotValue()
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
          child: loading == true ? Expanded(child: Center(child: CircularProgressIndicator(), heightFactor: 10,)) :
              displayForm(),
        )
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

