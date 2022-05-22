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
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart' as pdf;
import 'package:path/path.dart' as path;
import 'package:network_image_to_byte/network_image_to_byte.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui';


class QcApprovalFormA extends StatefulWidget {
  final DocumentSnapshot post;
  final User user;
  QcApprovalFormA({Key key, this.post, this.user}) : super(key: key);

  @override
  _QcApprovalFormAState createState() => _QcApprovalFormAState();
}

class _QcApprovalFormAState extends State<QcApprovalFormA> {

  GlobalKey _renderObjectKey = GlobalKey();

  List images = new List(6);
  List <Uint8List>imgBytes = new List(6);
  List billImages = new List(6);
  List <Uint8List> billImgBytes = new List(6);


  int receiverCount = 2;
  List <String> receiverUids =  ['9hm9y2c08pdAS5zZcnJRSH3TnsZ2', 'zpYyXei6FjU1qzrI4AviUK0QudE3'];
  List <String> receiverNames = ['Sumedh Boralkar', 'Rahul Tak'];

  static final remarkFormKey = GlobalKey<FormState>();

  var JsonResult;
  loadJSONData() async {
    String codes = await DefaultAssetBundle.of(context).loadString('assets/codes.json');
    JsonResult = json.decode(codes);
  }


  bool loading = true;
  bool onlyOnce = true;
  var filepath;
  static final key = new GlobalKey<ScaffoldState>();
  var remarkController = TextEditingController();


  List<String> urls = new List(6);
  List<String> billUrls = new List(6);

  @override
  void initState() {
    super.initState();
  }


  Future<Uint8List> toQrImageData(String text) async {
    try {
      final image = await QrPainter(
        data: text,
        version: QrVersions.auto,
        gapless: false,
        color: Colors.black,
        emptyColor: Colors.white,
      ).toImage(300);
      final a = await image.toByteData(format: ImageByteFormat.png);
      return a.buffer.asUint8List();
    } catch (e) {
      throw e;
    }
  }



  @override
  Widget build(BuildContext context) {
    final db = Firestore.instance;
    firstForm form = firstForm();


    final List<StorageReference> imgRefs = [
      widget.post.data['img1'] == null ? null : FirebaseStorage.instance.ref().child(widget.post.data['img1']),
      widget.post.data['img2'] == null ? null : FirebaseStorage.instance.ref().child(widget.post.data['img2']),
      widget.post.data['img3'] == null ? null : FirebaseStorage.instance.ref().child(widget.post.data['img3']),
      widget.post.data['img4'] == null ? null : FirebaseStorage.instance.ref().child(widget.post.data['img4']),
      widget.post.data['img5'] == null ? null : FirebaseStorage.instance.ref().child(widget.post.data['img5']),
      widget.post.data['img6'] == null ? null : FirebaseStorage.instance.ref().child(widget.post.data['img6']),
    ];

    final List<StorageReference> billImgRefs = [
    widget.post.data['billImg1'] == null ? null : FirebaseStorage.instance.ref().child(widget.post.data['billImg1']),
    widget.post.data['billImg2'] == null ? null : FirebaseStorage.instance.ref().child(widget.post.data['billImg2']),
    widget.post.data['billImg3'] == null ? null : FirebaseStorage.instance.ref().child(widget.post.data['billImg3']),
    widget.post.data['billImg4'] == null ? null : FirebaseStorage.instance.ref().child(widget.post.data['billImg4']),
    widget.post.data['billImg5'] == null ? null : FirebaseStorage.instance.ref().child(widget.post.data['billImg5']),
    widget.post.data['billImg6'] == null ? null : FirebaseStorage.instance.ref().child(widget.post.data['billImg6']),
    ];



    loadUrls() async{
      print('-------IN LOADING URLS');
      for(int i=0; i<6; i++) {
        if (imgRefs[i] != null) {
          await imgRefs[i].getDownloadURL().then((value) =>
              setState(() => urls[i] = value));
          print('++++++====');
          print(urls[i]);
          imgBytes[i] = await networkImageToByte(urls[i]);
        }
      }
      for(int i=0; i<6; i++) {
        if(billImgRefs[i] != null) {
          await billImgRefs[i].getDownloadURL().then((value) => setState(() => billUrls[i] = value));
          print('++++++====');
          print(billUrls[i]);
          billImgBytes[i] = await networkImageToByte(billUrls[i]);
          print(i);
          print(billImgBytes[i]);

        }
      }
      setState(() {loading = false;});
    }

    if(onlyOnce == true)
    {
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

    Widget billImagesArea(String img1, String img2, String img3, String img4, String img5, String img6) {
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
              'Bill Images',
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
                            child: Center(child: Image.network(billUrls[0])),
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
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => ShowFullScreen(url: billUrls[0],))
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
                            child: Center(child: Image.network(billUrls[1])),
                          ),
                          new Align(
                              alignment: Alignment.topRight,
                              child: SizedBox(
                                height: 30,
                                width: 30,
                                child: FloatingActionButton(
                                  heroTag: 'show2bill',
                                  mini: true,
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => ShowFullScreen(url: billUrls[1],))
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
                            child: Center(child: Image.network(billUrls[2])),
                          ),
                          new Align(
                              alignment: Alignment.topRight,
                              child: SizedBox(
                                height: 30,
                                width: 30,
                                child: FloatingActionButton(
                                  heroTag: 'show3bill',
                                  mini: true,
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => ShowFullScreen(url: billUrls[2],))
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
                            child: Center(child: Image.network(billUrls[3])),
                          ),
                          new Align(
                              alignment: Alignment.topRight,
                              child: SizedBox(
                                height: 30,
                                width: 30,
                                child: FloatingActionButton(
                                  heroTag: 'show4bill',
                                  mini: true,
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => ShowFullScreen(url: billUrls[3],))
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
                            child: Center(child: Image.network(billUrls[4])),
                          ),
                          new Align(
                              alignment: Alignment.topRight,
                              child: SizedBox(
                                height: 30,
                                width: 30,
                                child: FloatingActionButton(
                                  heroTag: 'show5bill',
                                  mini: true,
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => ShowFullScreen(url: billUrls[4],))
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
                            child: Center(child: Image.network(billUrls[5])),
                          ),
                          new Align(
                              alignment: Alignment.topRight,
                              child: SizedBox(
                                height: 30,
                                width: 30,
                                child: FloatingActionButton(
                                  heroTag: 'show6bill',
                                  mini: true,
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => ShowFullScreen(url: billUrls[5],))
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
          ],
        ),
      );
    }

    showPdfSavedDialog(BuildContext context, String pdfName) {
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
        content: Text("Form has been approved and Pdf: $pdfName has been saved to 'Dowloads' folder"),
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

    generatePDF() async {
      setState(() {
        loading =true;
      });
      final doc = pw.Document();

      int totalImages = 0;
      for (int i = 0; i < 6; i++) {
        if (imgRefs[i] != null) {
          var image = pdf.PdfImage.file(
            doc.document,
            bytes: imgBytes[i],
          );
          images[totalImages] = image;
          totalImages += 1;
          print(i);
        }
      }

      int totalBillImages = 0;
      for (int i = 0; i < 6; i++) {
        if (billImgRefs[i] != null) {
          var image = new pdf.PdfImage.file(
            doc.document,
            bytes: billImgBytes[i],
          );
          billImages[totalBillImages] = image;
          totalBillImages += 1;
          print(i);
          print(billImages[i]);
        }
      }

      var _qr_image = await toQrImageData(widget.post.documentID);
      var qrImage = new pdf.PdfImage.file(
          doc.document,
          bytes: _qr_image);

      print(qrImage);



      print(billImages[2].toString());


      print("????????????");
      doc.addPage(
        pw.Page(
            build: (pw.Context context) => pw.Container(
              child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: <pw.Widget>[
                    pw.Center(
                        child: pw.Text(
                          'Achilles ERP Form\n',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            color: pdf.PdfColor(0, 0, 0),
                            fontSize: 27,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        )
                    ),

                    pw.SizedBox(height: 15),

                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: <pw.Widget> [
                        pw.Flexible(
                          flex: 5,
                          child: pw.Column(
                            children: <pw.Widget> [
                              pw.Text(
                                  'Details : \n',
                                  style: pw.TextStyle(
                                    color: pdf.PdfColor(1, 0.5, 0),
                                    fontSize: 23,
                                    fontStyle: pw.FontStyle.italic,
                                  )
                              ),

                              pw.SizedBox(height: 15),

                              pw.Text(
                                  'Form Type : ${widget.post.data['formType']}\n',
                                  style: pw.TextStyle(
                                    fontSize: 20,
                                  )
                              ),

                              pw.Text(
                                'Form Number : ${widget.post.data['formNumber']}\n',
                                style: pw.TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            ]
                          )
                        ),
                        pw.Flexible(
                          flex: 1,
                          child: pw.Center(
                            child: pw.Image(qrImage),
                          )
                        )
                      ]
                    ),

                    pw.SizedBox(height: 15),

                    pw.Text(
                        'Creator Name : ${widget.post.data['senderName']}\n',
                        style: pw.TextStyle(
                          fontSize: 20,
                        )
                    ),

                    pw.Text(
                        'Creation Date-Time : ${widget.post.data['dateTime']}\n',
                        style: pw.TextStyle(
                          fontSize: 20,
                        )
                    ),

                    pw.SizedBox(height: 15),

                    pw.Text(
                        'Head Approval by : ${widget.post.data['receiverName1']}, ${widget.post.data['receiverName2']}\n',
                        style: pw.TextStyle(
                          fontSize: 20,
                        )
                    ),

                    pw.SizedBox(height: 15),
                    pw.SizedBox(height: 15),

                    pw.Text(
                        'Market Surveys : \n',
                        style: pw.TextStyle(
                          color: pdf.PdfColor(1, 0.5, 0),
                          fontSize: 23,
                          fontStyle: pw.FontStyle.italic,
                        )
                    ),
                    pw.SizedBox(height: 15),
                    pw.Text(
                        'Procurement By : ${widget.post.data['marketSurveyApprovalBy']}\n',
                        style: pw.TextStyle(
                          fontSize: 20,
                        )
                    ),
                    pw.ListView.builder(
                      itemCount: widget.post.data['marketSurvey'].length,
                      itemBuilder: (_,i ) {
                        return pw.Column(
                          children: <pw.Widget> [
                            pw.Text(
                                'Cost Request of : Rs. ${widget.post.data['marketSurvey'][i]['cost']}\n',
                                style: pw.TextStyle(
                                  fontSize: 20,
                                )
                            ),
                            pw.Text(
                                'Procuring Details : ${widget.post.data['marketSurvey'][i]['detail']}\n',
                                style: pw.TextStyle(
                                  fontSize: 20,
                                )
                            ),
                            pw.SizedBox(height: 15),
                          ]
                        );
                      }
                    ),

                    pw.SizedBox(height: 15),

                    pw.Text(
                        'Treasurer Approval by : ${widget.post.data['treasurerApprovalBy']}\n',
                        style: pw.TextStyle(
                          fontSize: 20,
                        )
                    ),


                    pw.SizedBox(height: 15),

                    pw.Text(
                        'QC Approval by : ${widget.post.data['qcApprovalBy']}\n',
                        style: pw.TextStyle(
                          fontSize: 20,
                        )
                    ),
                  ]
              ),
            )
        ),
      );

      if(totalImages == 0) {
        pw.SizedBox(height: 0);
      }

      if(totalImages == 1) {
        doc.addPage(pw.Page(
            build: (pw.Context context) =>
                pw.Expanded(
                    child: pw.Column(
                        children: <pw.Widget>[
                          pw.Text(
                              'Images : \n',
                              style: pw.TextStyle(
                                color: pdf.PdfColor(1, 0.5, 0),
                                fontSize: 23,
                                fontStyle: pw.FontStyle.italic,
                              )
                          ),
                          pw.Expanded(
                              child: pw.Column(
                                  children: <pw.Widget> [
                                    pw.Flexible(
                                        flex: 1,
                                        child: pw.Container(
                                          padding: pw.EdgeInsets.all(5),
                                          child: pw.Center(
                                            child: pw.Image(images[0]),
                                          ),
                                        )
                                    ),
                                    pw.Flexible(
                                        flex: 1,
                                        child: pw.Container(
                                          padding: pw.EdgeInsets.all(5),
                                          child: pw.Center(
                                          ),
                                        )
                                    ),
                                  ]
                              )
                          ),
                        ]

                    )
                )
        ));
      }


      if(totalImages == 2) {
        doc.addPage(pw.Page(
            build: (pw.Context context) =>
                pw.Expanded(
                    child: pw.Column(
                        children: <pw.Widget>[
                          pw.Text(
                              'Images : \n',
                              style: pw.TextStyle(
                                color: pdf.PdfColor(1, 0.5, 0),
                                fontSize: 23,
                                fontStyle: pw.FontStyle.italic,
                              )
                          ),
                          pw.Expanded(
                              child: pw.Column(
                                  children: <pw.Widget> [
                                    pw.Flexible(
                                        flex: 1,
                                        child: pw.Container(
                                          padding: pw.EdgeInsets.all(5),
                                          child: pw.Center(
                                            child: pw.Image(images[0]),
                                          ),
                                        )
                                    ),
                                    pw.Flexible(
                                        flex: 1,
                                        child: pw.Container(
                                          padding: pw.EdgeInsets.all(5),
                                          child: pw.Center(
                                            child: pw.Image(images[1]),
                                          ),
                                        )
                                    ),
                                  ]
                              )
                          ),
                        ]

                    )
                )
        ));
      }


      if(totalImages == 3) {
        doc.addPage(pw.Page(
            build: (pw.Context context) =>
                pw.Expanded(
                    child: pw.Column(
                        children: <pw.Widget>[
                          pw.Text(
                              'Images : \n',
                              style: pw.TextStyle(
                                color: pdf.PdfColor(1, 0.5, 0),
                                fontSize: 23,
                                fontStyle: pw.FontStyle.italic,
                              )
                          ),
                          pw.Expanded(
                              child: pw.Column(
                                  children: <pw.Widget> [
                                    pw.Flexible(
                                        flex: 1,
                                        child: pw.Container(
                                          padding: pw.EdgeInsets.all(5),
                                          child: pw.Center(
                                            child: pw.Image(images[0]),
                                          ),
                                        )
                                    ),
                                    pw.Flexible(
                                        flex: 1,
                                        child: pw.Container(
                                          padding: pw.EdgeInsets.all(5),
                                          child: pw.Center(
                                            child: pw.Image(images[1]),
                                          ),
                                        )
                                    ),
                                  ]
                              )
                          ),
                        ]

                    )
                )
        ));
        doc.addPage(pw.Page(
          build: (pw.Context context) =>
              pw.Expanded(
                  child: pw.Column(
                      children: <pw.Widget> [
                        pw.Flexible(
                            flex: 1,
                            child: pw.Container(
                              padding: pw.EdgeInsets.all(5),
                              child: pw.Center(
                                child: pw.Image(images[2]),
                              ),
                            )
                        ),
                        pw.Flexible(
                            flex: 1,
                            child: pw.Container(
                              padding: pw.EdgeInsets.all(5),
                              child: pw.Center(
                              ),
                            )
                        ),
                      ]
                  )
              ),
        ));
      }


      if(totalImages == 4) {
        doc.addPage(pw.Page(
            build: (pw.Context context) =>
                pw.Expanded(
                    child: pw.Column(
                        children: <pw.Widget>[
                          pw.Text(
                              'Images : \n',
                              style: pw.TextStyle(
                                color: pdf.PdfColor(1, 0.5, 0),
                                fontSize: 23,
                                fontStyle: pw.FontStyle.italic,
                              )
                          ),
                          pw.Expanded(
                              child: pw.Column(
                                  children: <pw.Widget> [
                                    pw.Flexible(
                                        flex: 1,
                                        child: pw.Container(
                                          padding: pw.EdgeInsets.all(5),
                                          child: pw.Center(
                                            child: pw.Image(images[0]),
                                          ),
                                        )
                                    ),
                                    pw.Flexible(
                                        flex: 1,
                                        child: pw.Container(
                                          padding: pw.EdgeInsets.all(5),
                                          child: pw.Center(
                                            child: pw.Image(images[1]),
                                          ),
                                        )
                                    ),
                                  ]
                              )
                          ),
                        ]

                    )
                )
        ));
        doc.addPage(pw.Page(
          build: (pw.Context context) =>
              pw.Expanded(
                  child: pw.Column(
                      children: <pw.Widget> [
                        pw.Flexible(
                            flex: 1,
                            child: pw.Container(
                              padding: pw.EdgeInsets.all(5),
                              child: pw.Center(
                                child: pw.Image(images[2]),
                              ),
                            )
                        ),
                        pw.Flexible(
                            flex: 1,
                            child: pw.Container(
                              padding: pw.EdgeInsets.all(5),
                              child: pw.Center(
                                child: pw.Image(images[3]),
                              ),
                            )
                        ),
                      ]
                  )
              ),
        ));
      }

      if(totalImages == 5) {
        doc.addPage(pw.Page(
            build: (pw.Context context) =>
                pw.Expanded(
                    child: pw.Column(
                        children: <pw.Widget>[
                          pw.Text(
                              'Images : \n',
                              style: pw.TextStyle(
                                color: pdf.PdfColor(1, 0.5, 0),
                                fontSize: 23,
                                fontStyle: pw.FontStyle.italic,
                              )
                          ),
                          pw.Expanded(
                              child: pw.Column(
                                  children: <pw.Widget> [
                                    pw.Flexible(
                                        flex: 1,
                                        child: pw.Container(
                                          padding: pw.EdgeInsets.all(5),
                                          child: pw.Center(
                                            child: pw.Image(images[0]),
                                          ),
                                        )
                                    ),
                                    pw.Flexible(
                                        flex: 1,
                                        child: pw.Container(
                                          padding: pw.EdgeInsets.all(5),
                                          child: pw.Center(
                                            child: pw.Image(images[1]),
                                          ),
                                        )
                                    ),
                                  ]
                              )
                          ),
                        ]

                    )
                )
        ));
        doc.addPage(pw.Page(
          build: (pw.Context context) =>
              pw.Expanded(
                  child: pw.Column(
                      children: <pw.Widget> [
                        pw.Flexible(
                            flex: 1,
                            child: pw.Container(
                              padding: pw.EdgeInsets.all(5),
                              child: pw.Center(
                                child: pw.Image(images[2]),
                              ),
                            )
                        ),
                        pw.Flexible(
                            flex: 1,
                            child: pw.Container(
                              padding: pw.EdgeInsets.all(5),
                              child: pw.Center(
                                child: pw.Image(images[3]),
                              ),
                            )
                        ),
                      ]
                  )
              ),
        ));
        doc.addPage(pw.Page(
          build: (pw.Context context) =>
              pw.Expanded(
                  child: pw.Column(
                      children: <pw.Widget> [
                        pw.Flexible(
                            flex: 1,
                            child: pw.Container(
                              padding: pw.EdgeInsets.all(5),
                              child: pw.Center(
                                child: pw.Image(images[4]),
                              ),
                            )
                        ),
                        pw.Flexible(
                            flex: 1,
                            child: pw.Container(
                              padding: pw.EdgeInsets.all(5),
                              child: pw.Center(
                              ),
                            )
                        ),
                      ]
                  )
              ),
        ));
      }


      if(totalImages == 6) {
        doc.addPage(pw.Page(
            build: (pw.Context context) =>
                pw.Expanded(
                    child: pw.Column(
                        children: <pw.Widget>[
                          pw.Text(
                              'Images : \n',
                              style: pw.TextStyle(
                                color: pdf.PdfColor(1, 0.5, 0),
                                fontSize: 23,
                                fontStyle: pw.FontStyle.italic,
                              )
                          ),
                          pw.Expanded(
                              child: pw.Column(
                                  children: <pw.Widget> [
                                    pw.Flexible(
                                        flex: 1,
                                        child: pw.Container(
                                          padding: pw.EdgeInsets.all(5),
                                          child: pw.Center(
                                            child: pw.Image(images[0]),
                                          ),
                                        )
                                    ),
                                    pw.Flexible(
                                        flex: 1,
                                        child: pw.Container(
                                          padding: pw.EdgeInsets.all(5),
                                          child: pw.Center(
                                            child: pw.Image(images[1]),
                                          ),
                                        )
                                    ),
                                  ]
                              )
                          ),
                        ]

                    )
                )
        ));
        doc.addPage(pw.Page(
          build: (pw.Context context) =>
              pw.Expanded(
                  child: pw.Column(
                      children: <pw.Widget> [
                        pw.Flexible(
                            flex: 1,
                            child: pw.Container(
                              padding: pw.EdgeInsets.all(5),
                              child: pw.Center(
                                child: pw.Image(images[2]),
                              ),
                            )
                        ),
                        pw.Flexible(
                            flex: 1,
                            child: pw.Container(
                              padding: pw.EdgeInsets.all(5),
                              child: pw.Center(
                                child: pw.Image(images[3]),
                              ),
                            )
                        ),
                      ]
                  )
              ),
        ));
        doc.addPage(pw.Page(
          build: (pw.Context context) =>
              pw.Expanded(
                  child: pw.Column(
                      children: <pw.Widget> [
                        pw.Flexible(
                            flex: 1,
                            child: pw.Container(
                              padding: pw.EdgeInsets.all(5),
                              child: pw.Center(
                                child: pw.Image(images[4]),
                              ),
                            )
                        ),
                        pw.Flexible(
                            flex: 1,
                            child: pw.Container(
                              padding: pw.EdgeInsets.all(5),
                              child: pw.Center(
                                child: pw.Image(images[5]),
                              ),
                            )
                        ),
                      ]
                  )
              ),
        ));
      }

      if(totalBillImages == 0) {
        pw.SizedBox(height: 0);
      }

      if(totalBillImages == 1) {
        doc.addPage(pw.Page(
            build: (pw.Context context) =>
                pw.Expanded(
                    child: pw.Column(
                        children: <pw.Widget>[
                          pw.Text(
                              'Bill Images : \n',
                              style: pw.TextStyle(
                                color: pdf.PdfColor(1, 0.5, 0),
                                fontSize: 23,
                                fontStyle: pw.FontStyle.italic,
                              )
                          ),
                          pw.Expanded(
                              child: pw.Column(
                                  children: <pw.Widget> [
                                    pw.Flexible(
                                        flex: 1,
                                        child: pw.Container(
                                          padding: pw.EdgeInsets.all(5),
                                          child: pw.Center(
                                            child: pw.Image(billImages[0]),
                                          ),
                                        )
                                    ),
                                    pw.Flexible(
                                        flex: 1,
                                        child: pw.Container(
                                          padding: pw.EdgeInsets.all(5),
                                          child: pw.Center(
                                          ),
                                        )
                                    ),
                                  ]
                              )
                          ),
                        ]

                    )
                )
        ));
      }


      if(totalBillImages == 2) {
        doc.addPage(pw.Page(
            build: (pw.Context context) =>
                pw.Expanded(
                    child: pw.Column(
                        children: <pw.Widget>[
                          pw.Text(
                              'Bill Images : \n',
                              style: pw.TextStyle(
                                color: pdf.PdfColor(1, 0.5, 0),
                                fontSize: 23,
                                fontStyle: pw.FontStyle.italic,
                              )
                          ),
                          pw.Expanded(
                              child: pw.Column(
                                  children: <pw.Widget> [
                                    pw.Flexible(
                                        flex: 1,
                                        child: pw.Container(
                                          padding: pw.EdgeInsets.all(5),
                                          child: pw.Center(
                                            child: pw.Image(billImages[0]),
                                          ),
                                        )
                                    ),
                                    pw.Flexible(
                                        flex: 1,
                                        child: pw.Container(
                                          padding: pw.EdgeInsets.all(5),
                                          child: pw.Center(
                                            child: pw.Image(billImages[1]),
                                          ),
                                        )
                                    ),
                                  ]
                              )
                          ),
                        ]

                    )
                )
        ));
      }


      if(totalBillImages == 3) {
        doc.addPage(pw.Page(
            build: (pw.Context context) =>
                pw.Expanded(
                    child: pw.Column(
                        children: <pw.Widget>[
                          pw.Text(
                              'Bill Images : \n',
                              style: pw.TextStyle(
                                color: pdf.PdfColor(1, 0.5, 0),
                                fontSize: 23,
                                fontStyle: pw.FontStyle.italic,
                              )
                          ),
                          pw.Expanded(
                              child: pw.Column(
                                  children: <pw.Widget> [
                                    pw.Flexible(
                                        flex: 1,
                                        child: pw.Container(
                                          padding: pw.EdgeInsets.all(5),
                                          child: pw.Center(
                                            child: pw.Image(billImages[0]),
                                          ),
                                        )
                                    ),
                                    pw.Flexible(
                                        flex: 1,
                                        child: pw.Container(
                                          padding: pw.EdgeInsets.all(5),
                                          child: pw.Center(
                                            child: pw.Image(billImages[1]),
                                          ),
                                        )
                                    ),
                                  ]
                              )
                          ),
                        ]

                    )
                )
        ));
        doc.addPage(pw.Page(
          build: (pw.Context context) =>
              pw.Expanded(
                  child: pw.Column(
                      children: <pw.Widget> [
                        pw.Flexible(
                            flex: 1,
                            child: pw.Container(
                              padding: pw.EdgeInsets.all(5),
                              child: pw.Center(
                                child: pw.Image(billImages[2]),
                              ),
                            )
                        ),
                        pw.Flexible(
                            flex: 1,
                            child: pw.Container(
                              padding: pw.EdgeInsets.all(5),
                              child: pw.Center(
                              ),
                            )
                        ),
                      ]
                  )
              ),
        ));
      }


      if(totalBillImages == 4) {
        doc.addPage(pw.Page(
            build: (pw.Context context) =>
                pw.Expanded(
                    child: pw.Column(
                        children: <pw.Widget>[
                          pw.Text(
                              'Bill Images : \n',
                              style: pw.TextStyle(
                                color: pdf.PdfColor(1, 0.5, 0),
                                fontSize: 23,
                                fontStyle: pw.FontStyle.italic,
                              )
                          ),
                          pw.Expanded(
                            child: pw.Column(
                              children: <pw.Widget> [
                                pw.Flexible(
                                  flex: 1,
                                  child: pw.Container(
                                    padding: pw.EdgeInsets.all(5),
                                    child: pw.Center(
                                      child: pw.Image(billImages[0]),
                                    ),
                                  )
                                ),
                                pw.Flexible(
                                  flex: 1,
                                    child: pw.Container(
                                      padding: pw.EdgeInsets.all(5),
                                      child: pw.Center(
                                      child: pw.Image(billImages[1]),
                                      ),
                                    )
                                ),
                              ]
                            )
                          ),
                        ]

                    )
                )
        ));
        doc.addPage(pw.Page(
            build: (pw.Context context) =>
                pw.Expanded(
                    child: pw.Column(
                        children: <pw.Widget> [
                          pw.Flexible(
                              flex: 1,
                              child: pw.Container(
                                padding: pw.EdgeInsets.all(5),
                                child: pw.Center(
                                  child: pw.Image(billImages[2]),
                                ),
                              )
                          ),
                          pw.Flexible(
                              flex: 1,
                              child: pw.Container(
                                padding: pw.EdgeInsets.all(5),
                                child: pw.Center(
                                  child: pw.Image(billImages[3]),
                                ),
                              )
                          ),
                        ]
                    )
                ),
        ));
      }

      if(totalBillImages == 5) {
        doc.addPage(pw.Page(
            build: (pw.Context context) =>
                pw.Expanded(
                    child: pw.Column(
                        children: <pw.Widget>[
                          pw.Text(
                              'Bill Images : \n',
                              style: pw.TextStyle(
                                color: pdf.PdfColor(1, 0.5, 0),
                                fontSize: 23,
                                fontStyle: pw.FontStyle.italic,
                              )
                          ),
                          pw.Expanded(
                              child: pw.Column(
                                  children: <pw.Widget> [
                                    pw.Flexible(
                                        flex: 1,
                                        child: pw.Container(
                                          padding: pw.EdgeInsets.all(5),
                                          child: pw.Center(
                                            child: pw.Image(billImages[0]),
                                          ),
                                        )
                                    ),
                                    pw.Flexible(
                                        flex: 1,
                                        child: pw.Container(
                                          padding: pw.EdgeInsets.all(5),
                                          child: pw.Center(
                                            child: pw.Image(billImages[1]),
                                          ),
                                        )
                                    ),
                                  ]
                              )
                          ),
                        ]

                    )
                )
        ));
        doc.addPage(pw.Page(
          build: (pw.Context context) =>
              pw.Expanded(
                  child: pw.Column(
                      children: <pw.Widget> [
                        pw.Flexible(
                            flex: 1,
                            child: pw.Container(
                              padding: pw.EdgeInsets.all(5),
                              child: pw.Center(
                                child: pw.Image(billImages[2]),
                              ),
                            )
                        ),
                        pw.Flexible(
                            flex: 1,
                            child: pw.Container(
                              padding: pw.EdgeInsets.all(5),
                              child: pw.Center(
                                child: pw.Image(billImages[3]),
                              ),
                            )
                        ),
                      ]
                  )
              ),
        ));
        doc.addPage(pw.Page(
          build: (pw.Context context) =>
              pw.Expanded(
                  child: pw.Column(
                      children: <pw.Widget> [
                        pw.Flexible(
                            flex: 1,
                            child: pw.Container(
                              padding: pw.EdgeInsets.all(5),
                              child: pw.Center(
                                child: pw.Image(billImages[4]),
                              ),
                            )
                        ),
                        pw.Flexible(
                            flex: 1,
                            child: pw.Container(
                              padding: pw.EdgeInsets.all(5),
                              child: pw.Center(
                              ),
                            )
                        ),
                      ]
                  )
              ),
        ));
      }


      if(totalBillImages == 6) {
        doc.addPage(pw.Page(
            build: (pw.Context context) =>
                pw.Expanded(
                    child: pw.Column(
                        children: <pw.Widget>[
                          pw.Text(
                              'Bill Images : \n',
                              style: pw.TextStyle(
                                color: pdf.PdfColor(1, 0.5, 0),
                                fontSize: 23,
                                fontStyle: pw.FontStyle.italic,
                              )
                          ),
                          pw.Expanded(
                              child: pw.Column(
                                  children: <pw.Widget> [
                                    pw.Flexible(
                                        flex: 1,
                                        child: pw.Container(
                                          padding: pw.EdgeInsets.all(5),
                                          child: pw.Center(
                                            child: pw.Image(billImages[0]),
                                          ),
                                        )
                                    ),
                                    pw.Flexible(
                                        flex: 1,
                                        child: pw.Container(
                                          padding: pw.EdgeInsets.all(5),
                                          child: pw.Center(
                                            child: pw.Image(billImages[1]),
                                          ),
                                        )
                                    ),
                                  ]
                              )
                          ),
                        ]

                    )
                )
        ));
        doc.addPage(pw.Page(
          build: (pw.Context context) =>
              pw.Expanded(
                  child: pw.Column(
                      children: <pw.Widget> [
                        pw.Flexible(
                            flex: 1,
                            child: pw.Container(
                              padding: pw.EdgeInsets.all(5),
                              child: pw.Center(
                                child: pw.Image(billImages[2]),
                              ),
                            )
                        ),
                        pw.Flexible(
                            flex: 1,
                            child: pw.Container(
                              padding: pw.EdgeInsets.all(5),
                              child: pw.Center(
                                child: pw.Image(billImages[3]),
                              ),
                            )
                        ),
                      ]
                  )
              ),
        ));
        doc.addPage(pw.Page(
          build: (pw.Context context) =>
              pw.Expanded(
                  child: pw.Column(
                      children: <pw.Widget> [
                        pw.Flexible(
                            flex: 1,
                            child: pw.Container(
                              padding: pw.EdgeInsets.all(5),
                              child: pw.Center(
                                child: pw.Image(billImages[4]),
                              ),
                            )
                        ),
                        pw.Flexible(
                            flex: 1,
                            child: pw.Container(
                              padding: pw.EdgeInsets.all(5),
                              child: pw.Center(
                                child: pw.Image(billImages[5]),
                              ),
                            )
                        ),
                      ]
                  )
              ),
        ));
      }

      String file_name = widget.post.data['formNumber'].toString() + '.pdf';
      String pdf_name = '/storage/emulated/0/Download/' + widget.post.data['formNumber'].toString() + '.pdf';

      final file = File(pdf_name);
      file.writeAsBytesSync(doc.save());
      print('done');

      showPdfSavedDialog(context, file_name);
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
          if(di == 'disapproved') {
            Navigator.of(context).pop();
          }
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

    showDisapprovalAlertDialog(BuildContext context, List _tempRemarks) async{

      var currentTime = DateTime.now();
      // set up the button
      Widget member = FlatButton(
        child: Text("Member"),
        onPressed: () {
          setState(() async {
            loading = true;
            await db.collection('forms').document(widget.post.documentID).updateData({'approval1': 0, 'approval2': 0, 'marketSurveyApproval': 0, 'marketSurveyApprovalBy': '', 'marketSurveyApprovalUid': '', 'marketSurveyReceiver': '',  'procurementApproval': 0, 'procurementApprovalBy': '', 'procurementApprovalByUid': '', 'procurementReceiver': '', 'treasurerApproval': 0, 'treasurerApprovalBy': '','treasurerApprovalByUid': '','status': 'stage-1', 'returned': true, 'remarks': _tempRemarks});
            showAlertDialog(context, 'disapproved');
          });
        },
      );
      Widget head = FlatButton(
        child: Text("Head"),
        onPressed: () {
          setState(() async {
            loading = true;
            await db.collection('forms').document(widget.post.documentID).updateData({'approval1': 0, 'approval2': 0,'marketSurveyApproval': 0, 'marketSurveyApprovalBy': '', 'marketSurveyApprovalUid': '', 'marketSurveyReceiver': '',  'procurementApproval': 0, 'procurementApprovalBy': '', 'procurementApprovalByUid': '', 'procurementReceiver': '', 'treasurerApproval': 0, 'treasurerApprovalBy': '','treasurerApprovalByUid': '', 'status': 'stage0', 'returned': true, 'remarks': _tempRemarks, 's0c': currentTime});
            showAlertDialog(context, 'disapproved');
          });
        },
      );
      Widget marketSurvey = FlatButton(
        child: Text("Market Survey"),
        onPressed: () {
          setState(() async {
            loading = true;
            await db.collection('forms').document(widget.post.documentID).updateData({'marketSurveyApproval': 0, 'marketSurveyApprovalBy': '', 'marketSurveyApprovalUid': '', 'marketSurveyReceiver': '',  'procurementApproval': 0, 'procurementApprovalBy': '', 'procurementApprovalByUid': '', 'procurementReceiver': '', 'treasurerApproval': 0, 'treasurerApprovalBy': '','treasurerApprovalByUid': '', 'status': 'stage1', 'returned': true, 'remarks': _tempRemarks, 's1c': currentTime});
            showAlertDialog(context, 'disapproved');
          });
        },
      );
      Widget treasurer = FlatButton(
        child: Text("Treasurer"),
        onPressed: () {
          setState(() async {
            loading = true;
            await db.collection('forms').document(widget.post.documentID).updateData({'procurementApproval': 0, 'procurementApprovalBy': '', 'procurementApprovalByUid': '', 'procurementReceiver': '', 'treasurerApproval': 0, 'treasurerApprovalBy': '','treasurerApprovalByUid': '', 'status': 'stage2', 'returned': true, 'remarks': _tempRemarks, 's2c': currentTime});
            showAlertDialog(context, 'disapproved');
          });
        },
      );
      Widget procurement = FlatButton(
        child: Text("Procurement"),
        onPressed: () {
          setState(() async {
            loading = true;
            await db.collection('forms').document(widget.post.documentID).updateData({'procurementApproval': 0, 'procurementApprovalBy': '', 'procurementApprovalByUid': '', 'procurementReceiver': '', 'status': 'stage3', 'returned': true, 'remarks': _tempRemarks, 's3c': currentTime});
            showAlertDialog(context, 'disapproved');
          });
        },
      );
      // set up the AlertDialog
      AlertDialog alert = AlertDialog(
        title: Text("Disapprove"),
        content: Text('Whom to the send form back to?'),
        actions: [
          member,
          head,
          marketSurvey,
          treasurer,
          procurement
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


    approve() async{
      setState(() {
        loading = true;
      });
      var currentTime = DateTime.now();

      await db.collection('forms').document(widget.post.documentID).updateData({'status': 'stage5','qcApproval' : 1, 'qcApprovalBy': widget.user.name, 'qcApprovalByUid': widget.user.uid, 's5c': currentTime});
      await generatePDF();
    }

    disapprove() async{
      setState(() {
        loading = true;
      });

      var now = DateTime.now();
      String formattedTime = DateFormat('kk:mm EEE d MMM').format(now);
      Map remark = {
        'time': formattedTime,
        'person': widget.user.name,
        'personUid': widget.user.uid,
        'remark': remarkController.text,
      };

      DocumentSnapshot doc = await db.collection('forms').document(widget.post.documentID).get();
      List tempRemarks = doc.data['remarks'];
      tempRemarks.add(remark);

      showDisapprovalAlertDialog(context, tempRemarks);
    }


    Widget displayForm()
    {
      return Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              plotValue('Form Number', widget.post.data['formNumber'].toString()),
              plotValue('Time', widget.post.data['dateTime']),
              plotValue('Sender Name', widget.post.data['senderName']),
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

              SizedBox(height: 10),
              marketSurveyList(),
              SizedBox(height: 10),

              billImagesArea(billUrls[0], billUrls[1], billUrls[2], billUrls[3], billUrls[4], billUrls[5]),
              Form(
                key: remarkFormKey,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextFormField(
                    controller: remarkController,
                    maxLines: null,
                    decoration: InputDecoration(
                      labelText: 'Remarks',
                      labelStyle: TextStyle(
                        color: Colors.indigo[800],
                        fontSize: 20,
                      ),
                      fillColor: Colors.grey[300],
                      filled: true,
                    ),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    ),
                    onChanged: (val) {
                      print(remarkController.text);
                    },
                    validator: (val) => val.isEmpty ? 'Enter remark before disapproval.' : null,
                  ),
                ),
              ),
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
                              'Approve',
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
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if(remarkFormKey.currentState.validate()) {
                          disapprove();
                        }
                      },
                      child: Container(
                          height: 40,
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.red,
                          ),
                          child: Center(
                            child: Text(
                              'Disapprove',
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

  marketSurveyList() {

    if(widget.post.data['marketSurvey'].length > 0) {
      return Container(
        width: 400,
        child: ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: widget.post.data['marketSurvey'].length,
            itemBuilder: (_, index) {
              print('inside');
              return Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          blurRadius: 5,
                          spreadRadius: 1,
                          offset: Offset(0, 4)
                      )
                    ]
                ),
                margin: EdgeInsets.all(8),
                padding: EdgeInsets.all(8),
                child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextFormField(
                          readOnly: true,
                          maxLines: null,
                          initialValue: widget.post.data['marketSurvey'][index]['cost'],
                          decoration: InputDecoration(
                            labelText: 'Cost Withdrawal Requirement',
                            labelStyle: TextStyle(
                              color: Colors.indigo[800],
                              fontSize: 20,
                            ),
                            fillColor: Colors.grey[300],
                            filled: true,
                          ),
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                        TextFormField(
                          readOnly: true,
                          maxLines: null,
                          initialValue: widget.post.data['marketSurvey'][index]['detail'],
                          decoration: InputDecoration(
                            labelText: 'Procuring Details and Contact',
                            labelStyle: TextStyle(
                              color: Colors.indigo[800],
                              fontSize: 20,
                            ),
                            fillColor: Colors.grey[300],
                            filled: true,
                          ),
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    )
                ),
              );
            }
        ),
      );
    } else {
      return Text('no market survey conducted');
    }
  }

}

