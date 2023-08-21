import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';

import '../database/helper.dart';

class NoteUpdateScreen extends StatefulWidget {
  final int id;
  final String title;
  final String content;

  const NoteUpdateScreen(
      {super.key,
      required this.id,
      required this.title,
      required this.content});

  @override
  _NoteUpdateScreenState createState() => _NoteUpdateScreenState();
}

class _NoteUpdateScreenState extends State<NoteUpdateScreen> {
  late TextEditingController _titleController;
  late HtmlEditorController _contentController;

  @override
  void initState() {
    super.initState();
    print("Prakash");
    print(widget.title);
    print(widget.content);
    _titleController = TextEditingController(text: widget.title);
    _contentController = HtmlEditorController();
    Future.delayed(Duration(milliseconds: 500), () {
      _contentController.setText(widget.content);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              await _updateData();
              Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: HtmlEditor(
                    controller: _contentController,
                    // callbacks: onChangeContent.,
                    htmlEditorOptions: const HtmlEditorOptions(
                      shouldEnsureVisible: true,
                      hint: "Your Text",
                      spellCheck: true,
                      autoAdjustHeight: false,
                      adjustHeightForKeyboard: false,
                    ),
                    htmlToolbarOptions: const HtmlToolbarOptions(
                      defaultToolbarButtons: [
                        FontButtons(
                          bold: true,
                          italic: true,
                          underline: false,
                          clearAll: false,
                          strikethrough: false,
                          superscript: false,
                          subscript: false,
                        ),
                        ListButtons(
                          ul: true,
                          listStyles: false,
                          ol: false,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateData() async {
    final updatedTitle = _titleController.text;
    final updatedContent = await _contentController.getText();
    final date = DateTime.now().toString().split(".")[0];

    // Update note in the database using your database helper
    final dbHelper =
    DatabaseHelper(); // Replace with your database helper instance
    await dbHelper.updateNote(
      id: widget.id,
      title: updatedTitle,
      content: updatedContent,
      date: date,
    );
  }
}
