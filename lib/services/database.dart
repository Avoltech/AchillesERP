import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {


  Future<Map<String, dynamic>>getUserDetails (String uid) async {

    await Firestore.instance.collection('users')
        .where("uid", isEqualTo: uid)
        .getDocuments().then((event) {
          if(event.documents.isEmpty) {
            print('DOCUMENT IS EMPTY<<<<<<<>>>>>>>>>><<>>>');
          }
          Map<String, dynamic> documentData = event.documents.single.data;
          print(documentData['firstName']);
          return documentData;
    }).catchError((e) => print('Error Fetching Data: $e'));
  }
}

