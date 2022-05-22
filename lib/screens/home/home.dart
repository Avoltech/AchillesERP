import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:achilleserp/models/user.dart';
import 'package:achilleserp/services/database.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:achilleserp/screens/loading.dart';
import 'package:achilleserp/screens/forms/forms_history.dart';
import 'package:achilleserp/screens/forms/create/createForm.dart';
import 'package:achilleserp/screens/heads/toApprove.dart';
import 'package:achilleserp/screens/forms/returned_forms.dart';
import 'package:achilleserp/screens/procurement/procurementApproval.dart';
import 'package:achilleserp/screens/procurement/memberProcurementApproval.dart';
import 'package:achilleserp/screens/approvedUserHistory.dart';
import 'package:achilleserp/services/hex_to_color.dart';
import 'package:achilleserp/screens/treasurer/treasurerToApproveList.dart';
import 'package:achilleserp/screens/qc/qcApprovalList.dart';
import 'package:achilleserp/screens/misc/changePassword.dart';
import 'package:achilleserp/screens/procurement/marketSurvey/marketSurveyApproval.dart';
import 'package:achilleserp/screens/procurement/marketSurvey/memberMarketSurveyApproval.dart';
import 'package:achilleserp/screens/admin/unlockForms.dart';
import 'package:achilleserp/screens/admin/controlStageTime.dart';
import 'package:achilleserp/screens/authenticate/sign_in.dart';
import 'package:achilleserp/services/auth.dart';
import 'package:achilleserp/screens/misc/qr_read.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:achilleserp/screens/fullyApproved/fullyApprovedList.dart';
import 'package:achilleserp/screens/inventory/inventoryApprovedList.dart';
import 'package:achilleserp/screens/inventory/inventoryApprove.dart';


class Home extends StatefulWidget {

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController searchBar = TextEditingController();

  final AuthService _auth = AuthService();

  bool loading = true;
  var JsonResult;
  User user;
  var doc;
  bool onlyOnce = true;
  User tempUser;

  @override
Widget build(BuildContext context) {

  loadJSONData() async {
    String codes = await DefaultAssetBundle.of(context).loadString('assets/codes.json');
    JsonResult = json.decode(codes);
  }

  loadJSONData();



  final fbUser = Provider.of<FirebaseUser>(context);
  Future <Map<String, dynamic>> document = DatabaseService().getUserDetails(fbUser.uid);

  DocumentSnapshot qs;
  initializeTempUser() async {
   qs =  await Firestore.instance.collection('users').document(fbUser.uid).get();
   print('***************^^^^^^');
   tempUser = User(
     uid: qs.data['uid'].toString(),
     name: qs.data['name'].toString(),
     department: qs.data['department'].toString(),
     position1: qs.data['position1'].toString(),
     position2: qs.data['position2'].toString(),
     position3: qs.data['position3'].toString(),
     position4: qs.data['position4'].toString(),
     position5: qs.data['position5'].toString(),
     position6: qs.data['position6'].toString(),
     formCounter: qs.data['formCounter'],
   );
   print(tempUser.name);
   setState(() {
     loading=false;
      onlyOnce = false;
   });
  }

  if(onlyOnce) {
    initializeTempUser();
  }


  _showSnackBarNoForms() {
    final snackBar = new SnackBar(
      content: Text('No forms to show!', style: TextStyle(color: Colors.indigo[800], fontWeight: FontWeight.w400, fontStyle: FontStyle.italic), ),
      duration: Duration(seconds: 2),
      backgroundColor: Colors.white,
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  return loading == true ? Loading() :Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        iconTheme: new IconThemeData(color: Colors.indigo[800]),
        elevation: 6,
        backgroundColor: Colors.white,
        title: Text(
          "ESTAA",
          style: TextStyle(
            color: Colors.indigo[800],
            fontWeight: FontWeight.w800,
            letterSpacing: 10,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          FlatButton.icon(
            icon: Icon(
              Icons.person_outline,
              color: Colors.indigo[800],
            ),
            label: Text(
              'Sign Out',
              style: TextStyle(
                color: Colors.indigo[800],
              ),
            ),
            onPressed: () async {
              setState(() => loading = true);
              print('eher');
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => SignIn()),
                    (Route<dynamic> route) => false,
              );
            },
          )
        ],
      ),
      endDrawer: Drawer(
          child: searchContainer(),
      ),
      drawer: SafeArea(
        child: Drawer(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Flexible(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                    color: Colors.blue[600],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        SizedBox(height: 20,),
                        Text(
                          'Hey,',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          tempUser.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  flex: 7,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ChangePassword(user: tempUser)),
                            );
                          },
                          splashColor: Colors.blue[100],
                          child: Container(
                            padding: EdgeInsets.all(20),
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.settings,
                                  size: 25,
                                  color: Colors.indigo[800],
                                ),
                                SizedBox(width: 10,),
                                Text(
                                  'Change Password',
                                  style: TextStyle(
                                    color: Colors.indigo[800],
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],

                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                           Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => QrRead(user: user)),
                            );
                          },
                          splashColor: Colors.blue[100],
                          child: Container(
                            padding: EdgeInsets.all(20),
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.camera_alt,
                                  size: 25,
                                  color: Colors.indigo[800],
                                ),
                                SizedBox(width: 10,),
                                Text(
                                  'Scan QR Code',
                                  style: TextStyle(
                                    color: Colors.indigo[800],
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],

                            ),
                          ),
                        )
                      ],
                    )
                  ),
                )
              ],
            )
          ),
        )
      ),
      body: StreamBuilder(
        stream: Firestore.instance.collection('users').where("uid", isEqualTo: fbUser.uid).snapshots(),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Text("Loading...."),
            );
          }
          else {
            user = User(
              uid: snapshot.data.documents[0]['uid'].toString(),
              name: snapshot.data.documents[0]['name'].toString(),
              department: snapshot.data.documents[0]['department'].toString(),
              position1: snapshot.data.documents[0]['position1'].toString(),
              position2: snapshot.data.documents[0]['position2'].toString(),
              position3: snapshot.data.documents[0]['position3'].toString(),
              position4: snapshot.data.documents[0]['position4'].toString(),
              position5: snapshot.data.documents[0]['position5'].toString(),
              position6: snapshot.data.documents[0]['position6'].toString(),
              position7: snapshot.data.documents[0]['position7'].toString(),
              formCounter: snapshot.data.documents[0]['formCounter'],
            );

            return user.position6 != 'admin' ? Container(
                padding: EdgeInsets.all(10),
                color: Colors.blue[50],
                child: GridView.count(
                  crossAxisCount: 2,
                  children: <Widget>[
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => createForm(user: user))
                          );
                        },
                        child: menuTile(
                            icon_name: Icons.add_circle, tile_name: 'Create')
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => returnedForms(user: user))
                        );
                      },
                      child: menuTile(icon_name: Icons.assignment_return,
                          tile_name: 'Returned'),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>
                                fullyApprovedList(user: user))
                        );
                      },
                      child: menuTile(icon_name: Icons.assignment_turned_in,
                          tile_name: 'Approved'),
                    ),
                    GestureDetector(
                      onTap: () {
                        snapshot.data.documents[0]['formCounter'] == 0 ?
                        _showSnackBarNoForms()
                            :
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => formHistory(user_: user))
                        );
                      },
                      child: menuTile(
                          icon_name: Icons.watch_later, tile_name: 'History'),
                    ),
                    user.position2 == 'head' && user.department != 'procurement' ?
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => toApprove(user: user))
                          );
                        },
                        child: menuTile(icon_name: Icons.local_post_office,
                            tile_name: 'To Approve')) :
                    user.department == 'procurement' ?
                    GestureDetector(
                        onTap: () {
                          if (user.position2 == 'head') {
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) =>
                                    MarketSurveyToApprove(user: user))
                            );
                          } else {
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) =>
                                    MemberMarketSurveyToApprove(user: user))
                            );
                          }
                        },
                        child: menuTileTreasurerQCProc(icon_name: Icons.search,
                            tile_name: 'Market Survey Approval')) :
                    user.position4 == 'treasurer' ?
                    GestureDetector(
                      onTap: () {
                        print('Pressed');
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>
                                TreasurerToApproveList(user: user))
                        );
                      },
                      child: menuTileTreasurerQCProc(icon_name: Icons.monetization_on,
                          tile_name: 'Treasurer Approval'),
                    ) :
                    user.position5 =='qc' ?
                    GestureDetector(
                      onTap: () {
                        print('Pressed');
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>
                                QcToApproveList(user: user))
                        );
                      },
                      child: menuTileTreasurerQCProc(icon_name: Icons.search,
                          tile_name: 'QC Approval'),
                    ) :
                    user.position7 == 'inventory' ?
                    GestureDetector(
                      onTap: () {
                        print('Pressed');
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>
                                InventoryApproval(user: user))
                        );
                      },
                      child: menuTileTreasurerQCProc(icon_name: Icons.build,
                          tile_name: 'Inventory Approval'),
                    )
                    : Container(),
                    user.department == 'procurement' ?
                    GestureDetector(
                      onTap: () {
                        if (user.position2 == 'head') {
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>
                                  ProcurementToApprove(user: user))
                          );
                        } else {
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>
                                  MemberProcurementToApprove(user: user))
                          );
                        }
                      },
                      child: menuTileTreasurerQCProc(icon_name: Icons.shopping_cart,
                          tile_name: 'Procurement Approval'),
                    ) :
                    user.position7 == 'inventory'?
                    GestureDetector(
                      onTap: () {
                        print('Pressed');
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>
                                InventoryApprovedList(user: user))
                        );
                      },
                      child: menuTileTreasurerQCProc(icon_name: Icons.assignment,
                          tile_name: 'Inventory Approval'),
                    )
                        : Container()

                  ],
                )
            ) :
            Container(
              padding: EdgeInsets.all(10),
              color: Colors.blue[50],
              child: GridView.count(
                crossAxisCount: 2,
                children: <Widget>[
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UnlockForms(user: user))
                        );
                      },
                      child: menuTile(
                          icon_name: Icons.lock_open, tile_name: 'Unlock Forms')
                  ),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ControlStageTime(user: user))
                        );
                      },
                      child: menuTile(
                          icon_name: Icons.timelapse, tile_name: 'Control Stage Time')
                  )
                ],
              )
            );
          }
        }
      ),

    );
  }



  bool showResults = false;
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
  }


  class menuTile extends StatelessWidget {

    final IconData icon_name;
    final String tile_name;

    menuTile({this.icon_name, this.tile_name});

    @override
    Widget build(BuildContext context) {
      return Container(
            margin: EdgeInsets.all(15),
           // height: MediaQuery.of(context).size.height,
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Icon(
                    icon_name,
                    size: 90,
                    color: Colors.blue[200],
                  ),

                   Text(
                    tile_name,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.indigo[800],
                        fontSize: 16,
                    ),
                  ),
                ],
              ),

      );
    }
}


class menuTileTreasurerQCProc extends StatelessWidget {

  final IconData icon_name;
  final String tile_name;

  menuTileTreasurerQCProc({this.icon_name, this.tile_name});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(15),
      // height: MediaQuery.of(context).size.height,
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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Icon(
            icon_name,
            size: 90,
            color: Colors.red[300],
          ),

          Text(
            tile_name,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.indigo[800],
              fontSize: 16,
            ),
          ),
        ],
      ),

    );
  }
}
