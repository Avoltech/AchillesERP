import 'package:achilleserp/screens/procurement/marketSurvey/marketSurveyBlock.dart';
import 'package:flutter/material.dart';

typedef OnDelete();

class msBlockForm extends StatefulWidget {

  final msBlock block;
  final state = _msBlockFormState();
  final OnDelete onDelete;

  msBlockForm({Key key, this.block, this.onDelete}) :  super(key: key);
  @override
  _msBlockFormState createState() => state;

  bool isValid() => state.validate();

}

class _msBlockFormState extends State<msBlockForm> {

  final form = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {
    return Form(
      key: form,
      child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                initialValue: widget.block.cost,
                keyboardType: TextInputType.numberWithOptions(),
                maxLines: null,
                decoration: InputDecoration(
                  labelText: 'Cost Withdrawal Requirement',
                  labelStyle: TextStyle(
                    color: Colors.indigo[800],
                    fontSize: 20,
                  ),
                  fillColor: Colors.grey[300],
                  filled: true,
                ),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
                onChanged: (val) {
                  widget.block.cost = val;
                },
                validator: (val) =>
                val.isEmpty
                    ? 'Enter Cost Requirement before Approval.'
                    : null,
              ),
              TextFormField(
                initialValue: widget.block.detail,
                maxLines: null,
                decoration: InputDecoration(
                  labelText: 'Procuring Details and Contact',
                  labelStyle: TextStyle(
                    color: Colors.indigo[800],
                    fontSize: 20,
                  ),
                  fillColor: Colors.grey[300],
                  filled: true,
                ),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
                onChanged: (val) {
                  widget.block.detail = val;
                },
                validator: (val) =>
                val.isEmpty
                    ? 'Enter Procuring Details and contact before Approval.'
                    : null,
              ),
            ],
          )
      ),
    );
  }


  bool validate(){
    var valid = form.currentState.validate();
    if (valid) form.currentState.save();
    return valid;
  }

}
