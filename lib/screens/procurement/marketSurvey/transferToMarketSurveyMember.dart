import 'package:flutter/material.dart';
import 'package:achilleserp/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:achilleserp/screens/forms/detail/detailPageFormA.dart';

class TransferToMarketSurveyMember extends StatefulWidget {
  final DocumentSnapshot post;
  final User user;

  TransferToMarketSurveyMember({Key key, this.post, this.user}) : super(key: key);
  @override
  _TransferToMarketSurveyMemberState createState() => _TransferToMarketSurveyMemberState();
}

class _TransferToMarketSurveyMemberState extends State<TransferToMarketSurveyMember> {
  final db = Firestore.instance;
  Future _data;
  dynamic totalDocCount;
  bool noForms = false;
  bool loading = false;


  showAlertDialog(BuildContext context,String Member) {

    String dialog = 'Successfully assigned task to following member';

    // set up the button
    Widget okButton = FlatButton(
      child: Text("Okay"),
      onPressed: () {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(dialog),
      content: Text(Member),
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

  assignTo(String _receiverUid, String _memberName) async
  {
    print('^^^^^^^^');
    print(_receiverUid);
    setState(() {
      loading = true;
    });
    await db.collection('forms').document(widget.post.documentID).updateData({'marketSurveyReceiver': _receiverUid});
    showAlertDialog(context, _memberName);
  }


  Future getUsers() async {
    var firestore = Firestore.instance;

    QuerySnapshot qs = await firestore.collection('users').where('department', isEqualTo: 'procurement').where('position2', isEqualTo: '').getDocuments();
    print('*************');
    print(qs.documents);
    // print(head);
    return qs.documents;
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(">>>>>=====INIT=====<<<<<");
    //print(widget.user_.toString());
    _data = getUsers();
    _data.whenComplete(() => print(_data));
    print('Completed init');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blue[50],
        appBar: AppBar(
          iconTheme: new IconThemeData(color: Colors.indigo[800]),
          elevation: 6,
          backgroundColor: Colors.white,
          title: Text(
            "Transfer to member",
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
            :
        Container(
            child: FutureBuilder(
                future: _data,
                builder: (_, snapshot)
                {
                  if(snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Text("Loading...."),
                    );
                  }else {
                    print(snapshot.data.length);
                    if (snapshot.data.length == 0){
                      return Center(child: Text('No users to show.'));
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
                              title: Text(snapshot.data[index].data['name']),
                              onTap: () {
                                print('tapped here');
                                assignTo(snapshot.data[index].data['uid'], snapshot.data[index].data['name']);
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
