import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ink_sync/database/helper.dart';
import 'package:ink_sync/model/note_model.dart';
import 'package:ink_sync/screens/home_screen.dart';

void main() {
  testWidgets('Create and delete note', (WidgetTester tester) async {
    // Initialize the app
    await tester.pumpWidget(MaterialApp(home: HomeScreen()));

    // Create a new note
    final dbHelper = DatabaseHelper();
    final initialNotesCount = await dbHelper.getNotesCount();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text('Note Editor'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'Test Note Title');
    await tester.tap(find.byIcon(Icons.done_outline));
    await tester.pumpAndSettle();

    // Verify note creation
    final updatedNotesCount = await dbHelper.getNotesCount();
    expect(updatedNotesCount, initialNotesCount + 1);

    // Delete the note
    await tester.tap(find.byIcon(Icons.delete).first);
    await tester.pumpAndSettle();

    // Verify note deletion
    final finalNotesCount = await dbHelper.getNotesCount();
    expect(finalNotesCount, initialNotesCount);

    // Ensure the note editor screen is closed
    expect(find.text('Note Editor'), findsNothing);
  });

  testWidgets('Search for a note', (WidgetTester tester) async {
    // Initialize the app
    final dbHelper = DatabaseHelper();
    final testNote = Note(
      id: 1,
      title: 'Test Note',
      content: 'This is a test note.',
      date: '2023-08-01',
    );
    await dbHelper.insertNote(
      title: testNote.title,
      content: testNote.content,
      date: testNote.date,
    );
    await tester.pumpWidget(MaterialApp(home: HomeScreen()));

    // Perform a search
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Test Note');
    await tester.pumpAndSettle();
    expect(find.text('Test Note'), findsOneWidget);

    // Verify search results
    await tester.tap(find.text('Test Note'));
    await tester.pumpAndSettle();
    expect(find.text('Note Detail'), findsOneWidget);
  });
}
