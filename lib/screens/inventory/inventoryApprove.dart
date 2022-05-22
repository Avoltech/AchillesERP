import 'package:flutter/material.dart';
import 'package:achilleserp/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:achilleserp/screens/treasurer/treasurerApprovalFormA.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';

class InventoryApproval extends StatefulWidget {
  final User user;
  InventoryApproval({Key key, this.user}) : super(key: key);

  @override
  _InventoryApprovalState createState() => _InventoryApprovalState();
}

class _InventoryApprovalState extends State<InventoryApproval> {
  Future _data;
  bool loading = false;
  String error = '';

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
          if(res.data['inventoryApproval'] == 0) {
            await Firestore.instance.collection('forms').document(formId).updateData({'inventoryApproval': 1});
            showApprovedAlertDialog(context);
          } else {
            showAlreadyApprovedDialog(context);
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


  showApprovedAlertDialog(BuildContext context) {

    // set up the button
    Widget okButton = FlatButton(
      child: Text("Okay"),
      onPressed: () {
        Navigator.of(context).pop();
        Navigator.of(context).pop();

      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Success"),
      content: Text('Inventory approval completed, hand over the supplies to the member.'),
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

  showAlreadyApprovedDialog(BuildContext context) {

    // set up the button
    Widget okButton = FlatButton(
      child: Text("Okay"),
      onPressed: () {
        Navigator.of(context).pop();
        Navigator.of(context).pop();

      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Alert!"),
      content: Text('This form has aleady been Inventory Approved', style: TextStyle(color: Colors.red),),
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
  void initState() {
    // TODO: implement initState
    super.initState();
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
          "Inventory Approval",
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
          child: RichText(text: TextSpan(
            text: 'Note:',
            style: TextStyle(color: Colors.orange[600]),
            children: <TextSpan> [
              TextSpan(text: 'A '),
              TextSpan(text: 'Red QR CODE ', style: TextStyle(color: Colors.red)),
              TextSpan(text: 'means that supplies have been already provided, while a '),
              TextSpan(text: 'Green QR CODE ', style: TextStyle(color: Colors.green)),
              TextSpan(text: 'means that supplies are yet to be provided to the member. ')


            ]
          )

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
