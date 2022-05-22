import 'package:flutter/material.dart';
import 'package:achilleserp/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:achilleserp/screens/fullyApproved/fullyApprovedFormA.dart';


class fullyApprovedList extends StatefulWidget {

  final User user;
  fullyApprovedList({Key key, this.user}) : super(key: key);

  @override
  _fullyApprovedListState createState() => _fullyApprovedListState();
}

class _fullyApprovedListState extends State<fullyApprovedList> {
  Future _data;
  dynamic totalDocCount;
  bool noForms = false;


  Future<int> totalDocs(String uid) async {
    var queryRequest = Firestore.instance.collection('firstForm').where('senderUid', isEqualTo: uid);
    var querySnapshot = await queryRequest.getDocuments();
    var length = querySnapshot.documents.length;
    print(querySnapshot.documents.length);
    return length != null ? 0 : length;
  }

  Future getForms(String uid) async {
    var firestore = Firestore.instance;
    ///Form A
    QuerySnapshot qs = await firestore.collection('forms').where('senderUid', isEqualTo: widget.user.uid).where('status', isEqualTo: 'stage5').getDocuments();


    //Form B


    //Form C



    //FormD
    //print(qs.documents[0].data);
    return qs.documents;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(">>>>>=====INIT=====<<<<<");
    //print(widget.user_.toString());
    _data = getForms(widget.user.uid);
    _data.whenComplete(() => print(_data));
    print('Completed init');
  }

  @override
  Widget build(BuildContext context) {
    //var count = totalDocs(args.uid);
    return Scaffold(
        backgroundColor: Colors.blue[50],
        appBar: AppBar(
          iconTheme: new IconThemeData(color: Colors.indigo[800]),
          elevation: 6,
          backgroundColor: Colors.white,
          title: Text(
            "Fully Approved",
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
                    print(snapshot.data.length);
                    if (snapshot.data.length == 0){
                      return Center(child: Text('No forms to show.'));
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
                              subtitle: Text('Form Type: ' + snapshot.data[index].data['formType'] +'\n' + snapshot.data[index].data['senderName']),
                              trailing: snapshot.data[index].data['inventoryApproval'] == 1 ? Icon(Icons.done, color: Colors.green, size: 30) :
                                  Icon(Icons.access_time, color: Colors.red, size: 30),
                              onTap: () {
                                if(snapshot.data[index].data['formType'] == 'A') {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => FullyApprovedFormA(post: snapshot.data[index], user: widget.user))
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
