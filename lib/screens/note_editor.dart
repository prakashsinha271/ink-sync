import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import '../database/helper.dart';

class NoteEditorScreen extends StatefulWidget {

  const NoteEditorScreen({Key? key,}) : super(key: key);

  @override
  _NoteEditorScreenState createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final HtmlEditorController _contentController = HtmlEditorController();
  final TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Note Editor"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              _saveContent();
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _titleController,
                validator: (value) {
                  if (value == '' || value == "" || value == null) {
                    return "Title is required";
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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

  Future<void> _saveContent() async {
    if (_formKey.currentState != null) {
      if (_formKey.currentState!.validate()) {
        final title = _titleController.text;
        final content = await _contentController.getText();
        final date = DateTime.now().toString().split(".")[0];
        final dbHelper = DatabaseHelper();
        await dbHelper.insertNote(
          title: title,
          content: content,
          date: date,
        );
        Navigator.pop(context);
      }
    }
  }
}
