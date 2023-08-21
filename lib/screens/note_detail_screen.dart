import 'package:flutter/material.dart';
import '../database/helper.dart';
import '../model/note_model.dart';
import 'html_web_view.dart';
import 'note_update_screen.dart';

class NoteDetailScreen extends StatelessWidget {
  const NoteDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final Note note = args['note'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Note Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteUpdateScreen(
                    id: note.id,
                    title: note.title,
                    content: note.content,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              // Show a confirmation dialog before deleting
              bool deleteConfirmed = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Delete Note'),
                    content: Text('Are you sure you want to delete this note?'),
                    actions: [
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                      ),
                      TextButton(
                        child: Text('Delete'),
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                      ),
                    ],
                  );
                },
              );

              if (deleteConfirmed == true) {
                final dbHelper = DatabaseHelper(); // Replace with your database helper instance
                await dbHelper.deleteNote(note.id);

                // Navigate to the home screen and remove all other screens
                Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 550, // Provide a fixed height
              child: HtmlWebView(htmlContent: note.content),
            ),
          ],
        ),
      ),
    );
  }
}
