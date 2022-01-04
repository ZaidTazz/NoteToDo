import 'package:flutter/material.dart';
import 'package:notetodo_flutter_application/data/models/note.dart';
import 'package:notetodo_flutter_application/domain/utilities/database_helper.dart';
import 'package:intl/intl.dart';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;

  NoteDetail(this.note, this.appBarTitle, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.note, this.appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetail> {
  DatabaseHelper helper = DatabaseHelper();

  String appBarTitle;
  Note note;

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  NoteDetailState(this.note, this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    titleController.text = note.title;
    descriptionController.text = note.description;

    final _formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: Color(0xFF2A2438),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color(0xFF352F44),
        title: Text(appBarTitle),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              moveToLastScreen();
            }),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
          child: ListView(
            children: <Widget>[
              // First Text Field
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: TextFormField(
                  validator: (val) =>
                      val.isEmpty ? 'Title cannot be an empty field!' : null,
                  controller: titleController,
                  style: TextStyle(
                    color: Color(0xFFDBD8E3),
                  ),
                  onChanged: (value) {
                    debugPrint('Title Field has been Altered');
                    _updateTitle();
                  },
                  decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle:
                        TextStyle(color: Color(0xFFDBD8E3), fontSize: 18.0),
                    errorStyle:
                        TextStyle(color: Colors.redAccent, fontSize: 15.0),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF5C5470),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide:
                          BorderSide(color: Color(0xFFDBD8E3), width: 1.0),
                    ),
                  ),
                ),
              ),

              // Second Text Field
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: TextFormField(
                  validator: (val) => val.isEmpty
                      ? 'Description cannot be an empty field!'
                      : null,
                  controller: descriptionController,
                  style: TextStyle(
                    color: Color(0xFFDBD8E3),
                  ),
                  onChanged: (value) {
                    debugPrint('Description Field has been Altered');
                    _updateDescription();
                  },
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle:
                        TextStyle(color: Color(0xFFDBD8E3), fontSize: 14.0),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFF5C5470), width: 1.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Colors.white, width: 1.0),
                    ),
                  ),
                ),
              ),

              // Button Element
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: ElevatedButton(
                        child: Text(
                          'Save Note',
                          textScaleFactor: 1.25,
                          style: TextStyle(
                            color: Color(0xFFDBD8E3),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            if (_formKey.currentState.validate()) {
                              debugPrint("Save Button Tapped");
                              _save();
                            } else {
                              Scaffold.of(context);
                            }
                          });
                        },
                      ),
                    ),
                    Container(
                      width: 5.0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  // Update the title of Note object
  void _updateTitle() {
    note.title = titleController.text;
  }

  // Update the description of Note object
  void _updateDescription() {
    note.description = descriptionController.text;
  }

  // Save data into database
  void _save() async {
    moveToLastScreen();

    note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (note.id != null) {
      // Update operation
      result = await helper.updateNote(note);
    } else {
      // Insert Operation
      result = await helper.insertNote(note);
    }

    if (result != 0) {
      // Success Message
      _showAlertDialog('Status', 'Note Saved');
    } else {
      // Failure Message
      _showAlertDialog('Status', 'Saving Note Unsuccessful');
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      backgroundColor: Color(0xFFDBD8E3),
      title: Text(
        title,
        style: TextStyle(
          color: Color(0xFF2A2438),
        ),
      ),
      content: Text(
        message,
        style: TextStyle(
          color: Color(0xFF352F44),
        ),
      ),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
