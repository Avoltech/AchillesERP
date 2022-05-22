import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FormAService {

  getFormCounter() async {
    QuerySnapshot qs =await Firestore.instance.collection('counters').getDocuments();
    return await qs.documents;
  }

  final CollectionReference formsReference = Firestore.instance.collection('forms');
  final CollectionReference counterReference = Firestore.instance.collection('counters');


  Future uploadForm(String dateTime, String senderName, String senderUid, String status, String formType,
      int receiverCount, String receiverName1, String receiverUid1, String receiverName2, String receiverUid2,
      int approval1, int approval2, String firstField, String secondField, String img1, String img2,
      String img3, String img4, String img5, String img6, DateTime s0c) async {

    var getNum = await getFormCounter();

    int formNumber = getNum[0].data['formNumber'];
    counterReference.document('counter').updateData({'formNumber': formNumber + 1});

    return await formsReference.document().setData({
      'formNumber' : formNumber,
      'dateTime' : dateTime,
      'senderName' : senderName,
      'senderUid' : senderUid,
      'status' : status,
      'formType': formType,
      'receiverCount': receiverCount,
      'receiverName1': receiverName1,
      'receiverUid1': receiverUid1,
      'receiverName2': receiverName2,
      'receiverUid2': receiverUid2,
      'approval1': approval1,
      'approval2': approval2,
      'firstField' : firstField,
      'secondField' : secondField,
      'img1': img1,
      'img2': img2,
      'img3': img3,
      'img4': img4,
      'img5': img5,
      'img6': img6,
      'marketSurvey': <Map>[],
      'marketSurveyApproval': 0,
      'marketSurveyApprovalBy': null,
      'marketSurveyReceiver' : '',
      'billsAttached': false,
      'procurementApproval': 0,
      'procurementApprovalBy': null,
      'treasurerApproval': 0,
      'treasurerApprovalBy': null,
      'qcApproval': 0,
      'qcApprovalBy': null,
      'procurementReceiver': '',
      'remarks': <Map>[],
      'returned': false,
      'previousStage': null,
      's0c': s0c,
      'inventoryApproval': 0,

    });
  }

}

class FormBService {

}
class FormCService {

}
class FormDService {

}

class FirstFormService {



  //var formCount = Firestore.instance.document(counterPath.toString()).get();


}
