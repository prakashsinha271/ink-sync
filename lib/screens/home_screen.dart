// home_screen.dart
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import '../database/helper.dart';
import '../model/note_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Note> notes = [];
  bool ascendingTitle = true;
  bool ascendingDate = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Retrieve notes and update the notes list
    retrieveNotes();
    updateNotesList();
  }

  void retrieveNotes() {
    final dbHelper = DatabaseHelper();
    dbHelper.getNotes().then((noteData) {
      setState(() {
        notes = noteData
            .map((noteMap) => Note(
                  id: noteMap['id'],
                  title: noteMap['title'],
                  content: noteMap['content'],
                  date: noteMap['date'],
                ))
            .toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ink Sync"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: NoteSearchDelegate(notes));
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text("Sort by Title"),
                onTap: () {
                  setState(() {
                    ascendingTitle = !ascendingTitle;
                    _sortNotesByTitle();
                  });
                },
              ),
              PopupMenuItem(
                child: const Text("Sort by Modified Date"),
                onTap: () {
                  setState(() {
                    ascendingDate = !ascendingDate;
                    _sortNotesByDate();
                  });
                },
              ),
            ],
          ),
        ],
      ),
      body: notes.isNotEmpty
          ? ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                final parsedContent = parse(note.content);
                final contentWithoutHtml =
                    parsedContent.documentElement?.text ?? '';
                return Dismissible(
                    key: Key(note.id.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      color: Colors.red,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) async {
                      // Delete the note from the database
                      final dbHelper = DatabaseHelper();
                      await dbHelper.deleteNote(note.id);

                      // Update the notes list
                      await updateNotesList();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Note '${note.title}' deleted"),
                        ),
                      );
                    },
                    child: ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: Text(
                              note.title,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(note.date.toString().split(" ")[0]),
                        ],
                      ),
                      subtitle: Row(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.6,
                            child: Text(
                              contentWithoutHtml,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(note.date!.toString().split(" ")[1]),
                          // Text(note.date),
                        ],
                      ),
                      onTap: () async {
                        Navigator.pushNamed(
                          context,
                          '/note_detail',
                          arguments: {'note': note},
                        );
                      },
                    ));
              },
            )
          : const Center(
              child: Text(
                  "No notes available.\nYou can add your notes by taping \"+\" icon."),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/note_editor');
          updateNotesList();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> updateNotesList() async {
    final dbHelper = DatabaseHelper();
    final newNotes = await dbHelper.getNotes();
    setState(() {
      notes = newNotes
          .map((noteMap) => Note(
                id: noteMap['id'],
                title: noteMap['title'],
                content: noteMap['content'],
                date: noteMap['date'],
              ))
          .toList();
    });
  }

  void _sortNotesByTitle() {
    notes.sort((a, b) {
      final comparison = a.title.compareTo(b.title);
      return ascendingTitle ? comparison : -comparison;
    });
  }

  void _sortNotesByDate() {
    notes.sort((a, b) {
      final comparison = a.date.compareTo(b.date);
      return ascendingDate ? comparison : -comparison;
    });
  }
}

class NoteSearchDelegate extends SearchDelegate<Note> {
  final List<Note> notes;

  NoteSearchDelegate(this.notes);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, Note(id: 0, title: '', content: '', date: '')); // Return an empty Note object
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final filteredNotes = notes.where((note) {
      final queryLowerCase = query.toLowerCase();
      return note.title.toLowerCase().contains(queryLowerCase) ||
          note.content.toLowerCase().contains(queryLowerCase);
    }).toList();

    return ListView.builder(
      itemCount: filteredNotes.length,
      itemBuilder: (context, index) {
        final note = filteredNotes[index];
        return ListTile(
          title: Text(note.title),
          subtitle: Text(note.content),
          onTap: () async {
              Navigator.pushNamed(
                context,
                '/note_detail',
                arguments: {'note': note},
              );
            },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filteredNotes = notes.where((note) {
      final queryLowerCase = query.toLowerCase();
      return note.title.toLowerCase().contains(queryLowerCase) ||
          note.content.toLowerCase().contains(queryLowerCase);
    }).toList();

    return ListView.builder(
      itemCount: filteredNotes.length,
      itemBuilder: (context, index) {
        final note = filteredNotes[index];
        final parsedContent = parse(note.content);
        final contentWithoutHtml =
            parsedContent.documentElement?.text ?? '';
        return ListTile(
          title: Text(note.title),
          subtitle: Text(contentWithoutHtml),
          onTap: () async {
            Navigator.pushNamed(
              context,
              '/note_detail',
              arguments: {'note': note},
            );
          },
        );
      },
    );
  }
}


