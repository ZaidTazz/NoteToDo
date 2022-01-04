import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:notetodo_flutter_application/data/models/note.dart';
import 'package:notetodo_flutter_application/UI/note_detail.dart';
import 'package:notetodo_flutter_application/domain/utilities/database_helper.dart';

class NoteList extends StatefulWidget {
  const NoteList({Key key}) : super(key: key);

  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();

  List<Note> noteList;

  int count = 0;

  @override
  Widget build(BuildContext context) {
    if (noteList == null) {
      noteList = [];
      updateListView();
    }
    return Scaffold(
      backgroundColor: Color(0xFF2A2438),
      appBar: AppBar(
        title: Text('NoteToDo'),
        centerTitle: true,
        backgroundColor: Color(0xFF352F44),
      ),
      body: getNoteListView(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF352F44),
        onPressed: () {
          debugPrint('Floating Action Button Tapped');
          navigateToDetail(Note('', ''), 'Add Note');
        },
        tooltip: 'Add Note',
        child: Icon(Icons.add),
      ),
    );
  }

  ListView getNoteListView() {
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int location) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 4.0),
          child: Card(
            color: Color(0xFFDBD8E3),
            elevation: 2.5,
            child: ListTile(
              title: Text(
                this.noteList[location].title,
                style: TextStyle(color: Color(0xFF2A2438), fontSize: 18.0),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    this.noteList[location].description,
                    style: TextStyle(
                      color: Color(0xFF5C5470),
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    this.noteList[location].date,
                    style: TextStyle(
                      color: Color(0xFF5C5470),
                    ),
                  ),
                ],
              ),
              trailing: GestureDetector(
                child: Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                onTap: () {
                  _delete(context, noteList[location]);
                },
              ),
              onTap: () {
                debugPrint('ListTile was Tapped');
                navigateToDetail(this.noteList[location], 'Edit Note');
              },
            ),
          ),
        );
      },
    );
  }

  void _delete(BuildContext context, Note note) async {
    int result = await databaseHelper.deleteNote(note.id);
    if (result != 0) {
      _displayMessage(context, 'Deletion Successful');
      updateListView();
    }
  }

  void _displayMessage(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    // ignore: deprecated_member_use
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void navigateToDetail(Note note, String title) async {
    bool result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return NoteDetail(note, title);
        },
      ),
    );

    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then(
      (database) {
        Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
        noteListFuture.then(
          (noteList) {
            setState(
              () {
                this.noteList = noteList;
                this.count = noteList.length;
              },
            );
          },
        );
      },
    );
  }
}
