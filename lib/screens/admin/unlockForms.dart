import 'package:flutter/material.dart';
import 'package:achilleserp/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:achilleserp/screens/admin//unlockPage.dart';

class UnlockForms extends StatefulWidget {
  final User user;
  UnlockForms({Key key, this.user}) : super(key: key);

  @override
  _UnlockFormsState createState() => _UnlockFormsState();
}

class _UnlockFormsState extends State<UnlockForms> {
  Future _data;



  var stage0TimeHours;
  var stage1TimeHours;
  var stage2TimeHours;
  var stage3TimeHours;
  var stage4TimeHours;



  Future getTimeCounters() async{
    var counterSnapshot = await Firestore.instance.collection('counters').document('counter').get();
    stage0TimeHours = counterSnapshot.data['stage0'];
    stage1TimeHours = counterSnapshot.data['stage1'];
    stage2TimeHours = counterSnapshot.data['stage2'];
    stage3TimeHours = counterSnapshot.data['stage3'];
    stage4TimeHours = counterSnapshot.data['stage4'];
  }

  var qsCounter = 0;

  Future getForms(String uid) async {

    await getTimeCounters();
    var qsCounter = 0;
    var currentTime = DateTime.now();
    QuerySnapshot qs1 = await Firestore.instance.collection('forms').getDocuments();

    var qs1List = qs1.documents.toList();
    var ql = qs1List;
    qs1List.removeWhere((element) => element.data['status'] == 'stage-1');
    qs1List.removeWhere((element) => element.data['status'] == 'stage5');
    print(qs1List.length);
    qs1List.forEach((element) {
      String tempStatus = element.data['status'];
      print(tempStatus);
      String stage = tempStatus[5];
      print(stage);
      switch(stage) {
        case '0': var diffMins = currentTime.difference(element.data['s0c'].toDate()).inMinutes;
                  print(diffMins);
                  if(diffMins <= (stage0TimeHours * 60)) {
                    ql.removeWhere((element2) => element2.documentID == element.documentID);
                  }
                  break;

        case '1': var diffMins = currentTime.difference(element.data['s1c'].toDate()).inMinutes;
                  if(diffMins <= (stage0TimeHours * 60)) {
                    ql.removeWhere((element2) => element2.documentID == element.documentID);
                  }
                  break;

        case '2': var diffMins = currentTime.difference(element.data['s2c'].toDate()).inMinutes;
                  if(diffMins <= (stage0TimeHours * 60)) {
                    ql.removeWhere((element2) => element2.documentID == element.documentID);
                  }
                  break;

        case '3': var diffMins = currentTime.difference(element.data['s3c'].toDate()).inMinutes;
                  if(diffMins <= (stage0TimeHours * 60)) {
                    ql.removeWhere((element2) => element2.documentID == element.documentID);
                  }
                  break;

        case '4': var diffMins = currentTime.difference(element.data['s4c'].toDate()).inMinutes;
                  if(diffMins <= (stage0TimeHours * 60)) {
                    ql.removeWhere((element2) => element2.documentID == element.documentID);
                  }
                  break;
      }
      qsCounter += 1;
    }
    );

    print(ql.length);
    return (ql);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(">>>>>=====INIT=====<<<<<");
    //print(widget.user_.toString());
    getTimeCounters();
    print(widget.user.uid);
    _data = getForms(widget.user.uid);
    _data.asStream();
    _data.whenComplete(() => print(_data));
    print('Completed init');
  }


  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  _showSnackBarNoForms() {
    final snackBar = new SnackBar(
      content: Text('This form has been locked, as you failed to process it in time, ask the admin to unlock it.', style: TextStyle(color: Colors.indigo[800], fontWeight: FontWeight.w400, fontStyle: FontStyle.italic, fontSize: 17), ),
      duration: Duration(seconds: 6),
      backgroundColor: Colors.white,
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }




  @override
  Widget build(BuildContext context) {

    var currentTime = DateTime.now();

    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.blue[50],
        appBar: AppBar(
          iconTheme: new IconThemeData(color: Colors.indigo[800]),
          elevation: 6,
          backgroundColor: Colors.white,
          title: Text(
            "Unlock Forms",
            style: TextStyle(
              color: Colors.indigo[800],
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0,
            ),
          ),
          centerTitle: true,
        ),
        body: Container(
            child: FutureBuilder(
                future: _data,
                builder: (_, snapshot)
                {
                  if(snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Text("Loading...."),
                    );
                  }else {
                    if(snapshot.hasData) {
                      if(snapshot.data.length == 0) {
                        return Center(child: Text('No forms to show'),);
                      }
                      else {
                        return ListView.builder(
                          //separatorBuilder: (_, __) => Divider(),
                          itemCount: snapshot.data.length,
                          itemBuilder: (_, index) {

                            return Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      blurRadius: 5,
                                      spreadRadius: 1,
                                      offset: Offset(0, 2)
                                  )]
                              ),
                              margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                              child: ListTile(
                                title: Text(snapshot.data[index].data['dateTime']),
                                subtitle: Text(snapshot.data[index].data['receiverName1'] + '\n' +
                                    snapshot.data[index].data['receiverName2']
                                ),

                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => UnlockPage(post: snapshot.data[index], user: widget.user)));
                                },
                              ),
                            );
                          },
                        );
                      }
                    }
                    else {
                      return Center(child: Text('No forms to show'),);
                    }
                  }
                }
            )
        )
    );
  }
}
