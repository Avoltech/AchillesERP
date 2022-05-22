import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:achilleserp/screens/forms/detail/detailPageFormA.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:achilleserp/models/user.dart';


class QrRead extends StatefulWidget {
  final User user;
  QrRead({this.user});
  @override
  _QrReadState createState() => _QrReadState();
}

class _QrReadState extends State<QrRead> {
  String error = '';
  bool loading = false;

  Future _scanQR() async {
   try {
     ScanResult qrResult = await BarcodeScanner.scan();
     setState(() async{
       loading = true;

       String formId = qrResult.rawContent;

       DocumentSnapshot res = await Firestore.instance.collection('forms').document(formId).get();
       if(res == null) {
         error = 'No form found for the given QR code.';
       } else {
         switch(res.data['formType']) {
           case 'A':  Navigator.pushReplacement(
                         context,
                         MaterialPageRoute(builder: (context) => detailPageFormA(post: res, user: widget.user))
                      );
                      break;
         }
       }


     });
   } on PlatformException catch(ex) {
     if(ex.code == BarcodeScanner.cameraAccessDenied) {
       setState(() {
         error = 'Camera permission was denied.';
       });
     } else {
       setState(() {
         error = "Unknown Error: $ex";
       });
     }
   } on FormatException {
     setState(() {
       error = 'You pressed back button before scanning.';
     });
     Navigator.of(context).pop();
   } catch(ex) {
     error = "Unknown Error: $ex";
   }
  }



  @override
  Widget build(BuildContext context) {
    return loading == true ? Expanded(child: Center(child: CircularProgressIndicator(), heightFactor: 10,)) :
    Scaffold(
      appBar: AppBar(
        iconTheme: new IconThemeData(color: Colors.indigo[800]),
        elevation: 6,
        backgroundColor: Colors.white,
        title: Text(
          "QC Approval",
          style: TextStyle(
            color: Colors.indigo[800],
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        child: Center(
          child: Text(
            error,
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ),

      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.camera_alt),
        onPressed: _scanQR,
        label: Text('Scan'),

      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
