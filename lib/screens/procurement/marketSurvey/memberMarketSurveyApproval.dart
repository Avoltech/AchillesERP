import 'package:flutter/material.dart';
import 'package:achilleserp/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:achilleserp/screens/procurement/marketSurvey/marketSurveyFormA.dart';

class MemberMarketSurveyToApprove extends StatefulWidget {
  final User user;
  MemberMarketSurveyToApprove({Key key, this.user}) : super(key: key);

  @override
  _MemberMarketSurveyToApproveState createState() => _MemberMarketSurveyToApproveState();
}

class _MemberMarketSurveyToApproveState extends State<MemberMarketSurveyToApprove> {
  Future _data;

  Future getForms() async {


    //FORM     A
    QuerySnapshot qs1 = await Firestore.instance.collection('forms').where('formType', isEqualTo: 'A').where('status', isEqualTo: 'stage1').where('marketSurveyReceiver', isEqualTo: widget.user.uid).getDocuments();


    //FORM     B


    //FORM     C


    //FORM     D

    //print(qs.documents[0].data);
    return (qs1.documents);
  }

  var stageTimeHours;


  Future getTimeCounters() async{
    var counterSnapshot = await Firestore.instance.collection('counters').document('counter').get();
    stageTimeHours = counterSnapshot.data['stage1'];
    print(stageTimeHours);
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(">>>>>=====INIT=====<<<<<");
    //print(widget.user_.toString());
    print(widget.user.uid);
    _data = getForms();
    _data.whenComplete(() => print(_data));
    getTimeCounters();

    print('Completed init');
  }

  @override
  Widget build(BuildContext context) {
    var currentTime = DateTime.now();

    return Scaffold(
        backgroundColor: Colors.blue[50],
        appBar: AppBar(
          iconTheme: new IconThemeData(color: Colors.indigo[800]),
          elevation: 6,
          backgroundColor: Colors.white,
          title: Text(
            "Market Survey Approval",
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

                          var s1c = snapshot.data[index].data['s1c'];
                          print(currentTime);
                          print(s1c.toDate());
                          print(currentTime.difference(s1c.toDate()).inMinutes);
                          var diffMins = currentTime.difference(s1c.toDate()).inMinutes;
                          print(diffMins);

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
                              subtitle: Text(snapshot.data[index].data['receiverName1'] + '\n' +
                                  snapshot.data[index].data['receiverName2']
                              ),
                              trailing: (stageTimeHours * 60) - diffMins < 0 ? Icon(Icons.lock, color: Colors.red, size: 30): Text(
                                'hrs left  $timeLeft',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.blue,
                                ),
                              ),
                              onTap: () {
                                if (snapshot.data[index].data['formType'] == 'A') {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => MarketSurveyApprovalFormA(post: snapshot.data[index], user: widget.user))
                                  );
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
