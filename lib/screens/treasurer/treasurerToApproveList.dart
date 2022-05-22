import 'package:flutter/material.dart';
import 'package:achilleserp/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:achilleserp/screens/treasurer/treasurerApprovalFormA.dart';

class TreasurerToApproveList extends StatefulWidget {
  final User user;
  TreasurerToApproveList({Key key, this.user}) : super(key: key);

  @override
  _TreasurerToApproveListState createState() => _TreasurerToApproveListState();
}

class _TreasurerToApproveListState extends State<TreasurerToApproveList> {
  Future _data;

  Future getForms(String uid) async {
    QuerySnapshot qs1 = await Firestore.instance.collection('forms').where('treasurerApproval', isEqualTo: 0).where('status', isEqualTo: 'stage2').getDocuments();
     //print(qs.documents[0].data);
    return (qs1.documents);
  }

  var stageTimeHours;

  Future getTimeCounters() async{
    var counterSnapshot = await Firestore.instance.collection('counters').document('counter').get();
    stageTimeHours = counterSnapshot.data['stage2'];
    print(stageTimeHours);
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
            "Treasurer Approval",
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
                    print(snapshot.data.toString());
                    if(snapshot.data.length == 0) {
                      return Center(child: Text('No forms to show'),);
                    }
                    else {
                      return ListView.builder(
                        //separatorBuilder: (_, __) => Divider(),
                        itemCount: snapshot.data.length,
                        itemBuilder: (_, index) {

                          var s2c = snapshot.data[index].data['s2c'];
                          print(currentTime);
                          print(s2c.toDate());
                          print(currentTime.difference(s2c.toDate()).inMinutes);
                          var diffMins = currentTime.difference(s2c.toDate()).inMinutes;
                          print(diffMins);
                          print('****');
                          print(stageTimeHours);

                          var _timeLeft = ((stageTimeHours * 60) - diffMins) ~/60;
                          print(_timeLeft);
                          String timeLeft = _timeLeft.toString();

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
                              subtitle: Text(
                                  'Form Type : ' + snapshot.data[index].data['formType']+ '\n'
                                      'by: ' + snapshot.data[index].data['senderName']
                              ),



                              trailing: (stageTimeHours * 60) - diffMins < 0 ? Icon(Icons.lock, color: Colors.red, size: 30): Text(
                                'hrs left  $timeLeft',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.blue,
                                ),
                              ),

                              onTap: () {
                                if ((stageTimeHours * 60) - diffMins < 0) {
                                  _showSnackBarNoForms();
                                } else {
                                  if (snapshot.data[index].data['formType'] == 'A') {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => TreasurerApprovalFormA(post: snapshot.data[index], user: widget.user))
                                    );
                                  }
                                }

                              },
                            ),
                          );
                        },
                      );
                    }

                  }
                }
            )
        )
    );
  }
}
