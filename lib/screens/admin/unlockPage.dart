import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:achilleserp/screens/forms/detail/detailPageFormA.dart';
import 'package:achilleserp/models/user.dart';
import 'package:intl/intl.dart';

class UnlockPage extends StatefulWidget {
  final DocumentSnapshot post;
  final User user;

  UnlockPage({this.post, this.user});

  @override
  _UnlockPageState createState() => _UnlockPageState();
}


class _UnlockPageState extends State<UnlockPage> {

  double ExtraTime = 0.5;

  List<double> extraTimeSlot = [0.5, 1, 2, 3, 4, 5];

  List <String> formAReceiverUids =  ['9hm9y2c08pdAS5zZcnJRSH3TnsZ2', 'zpYyXei6FjU1qzrI4AviUK0QudE3'];
  List <String> formAReceiverNames = ['Sumedh Boralkar', 'Rahul Tak'];

  List <String> procMemberNames = ['Shubham Khairnar', 'Procurement Name 1'];
  List <String> procMemberUid = ['Shubham Khairnar', 'Procurement Name 1'];


  String treasurerName = 'Sumedh Boralkar';
  String treasurerUid = 'Sumedh Boralkar';
  String qcName = 'Aditya Waghire';
  String qcUid = 'Aditya Waghire';


  String delayPerson = '';
  String delayPersonUid = '';

  int delayStage;
  bool loading = false;

  delayedBecauseOf() {
    String currentStatus = widget.post.data['status'];
    currentStatus = currentStatus[5];

    delayPerson = '';
    print('**************');
    print(delayPerson);

    switch(currentStatus) {
      case '0':
        delayStage = 0;
        switch(widget.post.data['formType']) {
          case 'A':
            if(widget.post.data['approval1'] == 0) {delayPerson = delayPerson + formAReceiverNames[0] + '\n'; delayPersonUid = delayPersonUid + formAReceiverUids[0] +'\n';}
            if(widget.post.data['approval2'] == 0) {delayPerson = delayPerson + formAReceiverNames[1]+ '\n'; delayPersonUid = delayPersonUid + formAReceiverUids[1]+'\n';}

            break;
          case 'B': break;
          case 'C': break;
        }
        break;

      case '1':
        delayStage = 1;

        if (widget.post.data['marketSurveyReceiver'] == '') {
          delayPerson = procMemberNames[0];
        } else {
          delayPerson = widget.post.data['marketSurveyReceiver'];
        }
        break;

      case '2':
        delayStage = 2;

        delayPerson = treasurerName;
        break;

      case '3':
        delayStage = 3;

        if (widget.post.data['marketSurveyReceiver'] == '') {
          delayPerson = procMemberNames[0];
        } else {
          delayPerson = widget.post.data['marketSurveyReceiver'];
        }
        break;

      case '4':
        delayStage = 4;

        delayPerson = qcName;
        break;
    }

    print(delayPerson);

    String formattedTime = DateFormat('kk:mm EEE d MMM').format(DateTime.now());
    Map remark = {
      'time': formattedTime,
      'person': '',
      'personUid': '',
      'remark': 'FORM DELAYED BECAUSE OF \n$delayPerson',
    };

    return remark;
  }

  showAlertDialog(BuildContext context) {

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
      content: Text('Form has been unlocked for next $ExtraTime hours'),
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



  unlockForm() async {
    Map _remark = delayedBecauseOf();
    var currentTime = DateTime.now();

    var prevStageTime;
    var stageTime;
    switch(delayStage) {
      case 0:
        print('here');
        prevStageTime = widget.post.data['s0c'].toDate();
        var prevStageTime_ = prevStageTime;
        var qs = await Firestore.instance.collection('counters').document('counter').get();

        DocumentSnapshot doc = await Firestore.instance.collection('forms').document(widget.post.documentID).get();

        List tempRemarks = doc.data['remarks'];
        tempRemarks.add(_remark);

        stageTime = qs.data['stage0'];
        var tempMins = currentTime.difference(prevStageTime_.add(Duration(hours: stageTime))).inMinutes + (ExtraTime * 60);
        print(tempMins);
        var newTime = prevStageTime.add(Duration(minutes: tempMins.round()));

        print('alsohere');
        await Firestore.instance.collection('forms').document(widget.post.documentID).updateData({'s0c': newTime, 'remarks': tempRemarks}).then((value) => print('hiya'));
        break;

      case 1:
        prevStageTime = widget.post.data['s1c'].toDate();
        var prevStageTime_ = prevStageTime;

        var qs = await Firestore.instance.collection('counters').document('counter').get();

        DocumentSnapshot doc = await Firestore.instance.collection('forms').document(widget.post.documentID).get();

        List tempRemarks = doc.data['remarks'];
        tempRemarks.add(_remark);

        stageTime = qs.data['stage1'];
        var tempMins = currentTime.difference(prevStageTime_.add(Duration(hours: stageTime))).inMinutes + (ExtraTime * 60);
        var newTime = prevStageTime.add(Duration(minutes: tempMins.round()));
        await Firestore.instance.collection('forms').document(widget.post.documentID).updateData({'s1c': newTime, 'remarks': tempRemarks});
        break;

      case 2:

        prevStageTime = widget.post.data['s2c'].toDate();
        var prevStageTime_ = prevStageTime;

        var qs = await Firestore.instance.collection('counters').document('counter').get();

        DocumentSnapshot doc = await Firestore.instance.collection('forms').document(widget.post.documentID).get();

        List tempRemarks = doc.data['remarks'];
        tempRemarks.add(_remark);

        stageTime = qs.data['stage2'];
        var tempMins = currentTime.difference(prevStageTime_.add(Duration(hours: stageTime))).inMinutes + (ExtraTime * 60);
        var newTime = prevStageTime.add(Duration(minutes: tempMins.round()));
        await Firestore.instance.collection('forms').document(widget.post.documentID).updateData({'s2c': newTime, 'remarks': tempRemarks});
        break;

      case 3:
        prevStageTime = widget.post.data['s3c'].toDate();
        var prevStageTime_ = prevStageTime;

        var qs = await Firestore.instance.collection('counters').document('counter').get();
        DocumentSnapshot doc = await Firestore.instance.collection('forms').document(widget.post.documentID).get();

        List tempRemarks = doc.data['remarks'];
        tempRemarks.add(_remark);
        stageTime = qs.data['stage3'];
        var tempMins = currentTime.difference(prevStageTime_.add(Duration(hours: stageTime))).inMinutes + (ExtraTime * 60);
        var newTime = prevStageTime.add(Duration(minutes: tempMins.round()));
        await Firestore.instance.collection('forms').document(widget.post.documentID).updateData({'s3c': newTime, 'remarks': tempRemarks});
        break;

      case 4:
        var qs = await Firestore.instance.collection('counters').document('counter').get();
        stageTime = qs.data['stage4'];
        var prevStageTime_ = prevStageTime;


        DocumentSnapshot doc = await Firestore.instance.collection('forms').document(widget.post.documentID).get();

        List tempRemarks = doc.data['remarks'];
        tempRemarks.add(_remark);
        var tempMins = currentTime.difference(prevStageTime_.add(Duration(hours: stageTime))).inMinutes + (ExtraTime * 60);
        var newTime = prevStageTime.add(Duration(minutes: tempMins.round()));
        await Firestore.instance.collection('forms').document(widget.post.documentID).updateData({'s4c': newTime, 'remarks': tempRemarks});
        break;
    }

    showAlertDialog(context);
  }


  @override
  Widget build(BuildContext context) {

    double _currentVal = 0.5;
    return Scaffold(
        backgroundColor: Colors.blue[50],
        appBar: AppBar(
          iconTheme: new IconThemeData(color: Colors.indigo[800]),
          elevation: 6,
          backgroundColor: Colors.white,
          title: Text(
            "Unlock Page",
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
        : Container(
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
           // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[

              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                    MaterialPageRoute(builder: (context) => detailPageFormA(post: widget.post, user: widget.user))
                  );
                  detailPageFormA(post: widget.post);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    color: Colors.white,
                    child: Center(
                      child: Text(
                          'View Form',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                          color: Colors.indigo[800],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 50,),
              Center(
                child: Text('Time to unlock form for',
                  style: TextStyle(
                    color: Colors.indigo[800],
                    fontSize: 20,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: DropdownButtonFormField(
                  value: 0.5,
                  onChanged: ((val) {
                    setState(() => ExtraTime = val);
                  }),
                  items: extraTimeSlot.map((ets) {
                     return DropdownMenuItem(
                       value: ets,
                       child: Text('$ets   hours'));
                  }).toList(),
                ),
              ),
              SizedBox(height: 50,),
              GestureDetector(
                onTap: () {
                  setState(() {
                    loading =true;
                  });
                  unlockForm();
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    color: Colors.red,
                    child: Center(
                      child: Text('UNLOCK',
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
          ),
        )
    );


  }
}
