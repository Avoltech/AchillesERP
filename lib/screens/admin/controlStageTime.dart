import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:achilleserp/models/user.dart';

class ControlStageTime extends StatefulWidget {
  final User user;
  ControlStageTime({this.user});
  @override
  _ControlStageTimeState createState() => _ControlStageTimeState();
}

class _ControlStageTimeState extends State<ControlStageTime> {

  Future _data;
  bool loading = true;

  TextEditingController stage0Controller;
  TextEditingController stage1Controller;
  TextEditingController stage2Controller;
  TextEditingController stage3Controller;
  TextEditingController stage4Controller;

  DocumentSnapshot qs;
  void getTimeCounters() async {
    qs = await Firestore.instance.collection('counters').document('counter').get();
    //print(qs.documents[0].data);
    stage0Controller = TextEditingController(text: qs.data['stage0'].toString());
    stage1Controller = TextEditingController(text: qs.data['stage1'].toString());
    stage2Controller = TextEditingController(text: qs.data['stage2'].toString());
    stage3Controller = TextEditingController(text: qs.data['stage3'].toString());
    stage4Controller = TextEditingController(text: qs.data['stage4'].toString());

    setState(() => loading = false);
  }

  updateTime() async{
    await Firestore.instance
        .collection('counters')
        .document('counter')
        .updateData({
          'stage0': int.parse(stage0Controller.text),
          'stage1': int.parse(stage1Controller.text),
          'stage2': int.parse(stage2Controller.text),
          'stage3': int.parse(stage3Controller.text),
          'stage4': int.parse(stage4Controller.text),
    });

    showAlertDialog(context);

  }


  showAlertDialog(BuildContext context) {

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
      content: Text('Stage time have been updated'),
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
    print(">>>>>=====INIT=====<<<<<");
    //print(widget.user_.toString());
    print(widget.user.uid);
    getTimeCounters();
    print('Completed init');
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        iconTheme: new IconThemeData(color: Colors.indigo[800]),
        elevation: 6,
        backgroundColor: Colors.white,
        title: Text(
          "Stage Time",
          style: TextStyle(
            color: Colors.indigo[800],
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
      ),
      body: loading == true ?
      Container(height: MediaQuery.of(context).size.height, width: MediaQuery.of(context).size.width,color:Colors.white, child: Center(child: CircularProgressIndicator(), heightFactor: 10,))
          : SingleChildScrollView(
            child: Container(
        margin: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: stage0Controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Stage0 (Head Approval Time) in Hours',
                    labelStyle: TextStyle(
                      color: Colors.orange[800],
                      fontSize: 20,
                    ),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: stage1Controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Stage1 (Market Survey Time) in Hours',
                    labelStyle: TextStyle(
                      color: Colors.orange[800],
                      fontSize: 20,
                    ),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: stage2Controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Stage2 (Treasurer Approval Time) in Hours',
                    labelStyle: TextStyle(
                      color: Colors.orange[800],
                      fontSize: 20,
                    ),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: stage3Controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Stage3 (Procuring Time) in Hours',
                    labelStyle: TextStyle(
                      color: Colors.orange[800],
                      fontSize: 20,
                    ),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: stage4Controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Stage4 (Quality Check Time) in Hours',
                    labelStyle: TextStyle(
                      color: Colors.orange[800],
                      fontSize: 20,
                    ),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      loading =true;
                    });
                    updateTime();
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                        padding: EdgeInsets.all(10),
                        color: Colors.red,
                        child: Center(
                          child: Text('UPDATE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              )
                          ),
                        )
                    ),
                  ),
                ),
              ],
        )
      ),
          )
    );
  }
}

