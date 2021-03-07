import 'package:flutter/material.dart';
import 'package:notekeeper_app/models/note.dart';
import 'package:notekeeper_app/utils/database_helper.dart';
// ignore: unused_import
import 'dart:async';
import 'package:intl/intl.dart';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;
  NoteDetail(this.note, this.appBarTitle);
  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.note, this.appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetail> {
  String appBarTitle;
  Note note;
  DatabaseHelper helper = DatabaseHelper();
  static var _priorities = ['High', "Low"];
  var _formKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  NoteDetailState(this.note, this.appBarTitle);
  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    TextStyle textStyle = Theme.of(context).textTheme.title;

    titleController.text = note.title;
    descriptionController.text = note.description;

    return WillPopScope(
        // ignore: missing_return
        onWillPop: () {
          //write some code to control things , when user press Back button in device
          moveToLastScreen();
        },
        child: Scaffold(
            appBar: AppBar(
              title: Text(appBarTitle),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  //write some code to control things , when user press Back button in appbar
                  debugPrint("pressed back button in appBar");
                  moveToLastScreen();
                },
              ),
            ),
            body: Form(
                key: _formKey,
                child: Padding(
                  padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
                  child: ListView(
                    children: <Widget>[
                      //First Element
                      ListTile(
                          title: DropdownButton(
                        items: _priorities.map((String dropDownStringItem) {
                          return DropdownMenuItem<String>(
                            value: dropDownStringItem,
                            child: Text(dropDownStringItem),
                          );
                        }).toList(),
                        style: textStyle,
                        value: getPriorityAsString(note.priority),
                        onChanged: (valueSelectedByUser) {
                          setState(() {
                            debugPrint("User Selected $valueSelectedByUser");
                            updatePriorityAsInt(valueSelectedByUser);
                          });
                        },
                      )),

                      //Second Element
                      Padding(
                          padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                          child: TextFormField(
                            controller: titleController,
                            style: textStyle,
                            // ignore: missing_return
                            validator: (String value) {
                              if (value.isEmpty) {
                                return 'Please Enter Something in Title Field';
                              }
                            },
                            onChanged: (value) {
                              debugPrint(
                                  "Something changed in Tile Text Field");
                              updateTitle();
                            },
                            decoration: InputDecoration(
                                labelText: 'Title',
                                labelStyle: textStyle,
                                errorStyle: TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 15.0,
                                ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0))),
                          )),

                      //Third Element
                      Padding(
                          padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                          child: TextField(
                            controller: descriptionController,
                            style: textStyle,
                            onChanged: (value) {
                              debugPrint(
                                  "Something changed in Description Text Field");
                              updateDescription();
                            },
                            decoration: InputDecoration(
                                labelText: 'Description',
                                labelStyle: textStyle,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0))),
                          )),

                      //Fourth Element
                      Padding(
                        padding: EdgeInsets.only(
                          top: 15.0,
                          bottom: 15.0,
                        ),
                        child: Row(
                          children: <Widget>[
                            //"Save" raised button
                            Expanded(
                              // ignore: deprecated_member_use
                              child: RaisedButton(
                                color: Theme.of(context).primaryColorDark,
                                textColor: Theme.of(context).primaryColorLight,
                                child: Text(
                                  "Save",
                                  textScaleFactor: 1.5,
                                ),
                                onPressed: () {
                                  setState(() {
                                    debugPrint("Save Button Clicked");
                                    if (_formKey.currentState.validate()) {
                                      _save();
                                      debugPrint("Saved New Note");
                                    }
                                  });
                                },
                              ),
                            ),

                            //creating gap bw buttos using container
                            Container(
                              width: 5.0,
                            ),

                            //Delete Raised Button
                            Expanded(
                              // ignore: deprecated_member_use
                              child: RaisedButton(
                                color: Theme.of(context).primaryColorDark,
                                textColor: Theme.of(context).primaryColorLight,
                                child: Text(
                                  "Delete",
                                  textScaleFactor: 1.5,
                                ),
                                onPressed: () {
                                  setState(() {
                                    debugPrint("Delete Button Clicked");
                                    _delete();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ))));
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }

  //Convert int priority to String priority and display it to user in Dropdown
  String getPriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = _priorities[0]; //High
        break;
      case 2:
        priority = _priorities[1]; //Low
        break;
    }
    return priority;
  }

//update te title of note object
  void updateTitle() {
    note.title = titleController.text;
  }

//update the description of note object
  void updateDescription() {
    note.description = descriptionController.text;
  }

//save data to database
  void _save() async {
    moveToLastScreen();
    note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (note.id != null) {
      //case 1: update operation
      debugPrint("Updated new node");

      result = await helper.updateNote(note);
    } else {
      //Case 2: INsert operation
      debugPrint("INserted new node");
      result = await helper.insertNote(note);
    }
    if (result != 0) {
      //success
      _showAlertDialog('Status', 'Note saved successfully');
    } else {
      //Failure
      _showAlertDialog('Status', 'Problem Saving Note');
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(
      context: context,
      builder: (_) => alertDialog,
    );
  }

  void _delete() async {
    moveToLastScreen();
    //case 1: if user is trying to delete the new node i.e. he has come to
    //the detail page by pressing the addnote button of notelist page.
    if (note.id == null) {
      _showAlertDialog('Status', 'No Note was deleted');
      return;
    }
    //case 2: user is trying to delete the old note that already has a valid ID
    int result = await helper.deletetNote(note.id);
    if (result != 0) {
      _showAlertDialog('Status', 'Note Deleted Successfully');
    } else {
      _showAlertDialog('Status', 'Error occured while Deleting Node');
    }
  }
}
