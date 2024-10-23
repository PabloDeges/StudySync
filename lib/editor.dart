// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class EditorView extends StatefulWidget {
  const EditorView({super.key});

  @override
  _EditorViewState createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView> {
  void _kursAuswahlSpeichern() {}

  static const fachbereichAuswahl = [
    DropdownMenuEntry(value: "EI", label: "Elektrotechnik / Informatik"),
    DropdownMenuEntry(value: "NE", label: "Nachhaltige Entwicklung"),
    DropdownMenuEntry(value: "BWL", label: "Geldhaben")
  ];

  static const semesterAuswahl = [
    DropdownMenuEntry(value: "IB1", label: "Informatik 1. Semester"),
    DropdownMenuEntry(value: "IB3", label: "Informatik 3. Semester"),
    DropdownMenuEntry(value: "IB5", label: "Informatik 5. Semester")
  ];

  static List<Map> kurse = [
    {"name": "Mathe 1", "isChecked": false},
    {"name": "Java 1", "isChecked": false},
    {"name": "Elektotechnik", "isChecked": false},
    {"name": "Schlüsselkompetenzen", "isChecked": false},
    {"name": "Englisch 1", "isChecked": false},
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      // ignore: prefer_const_constructors
      DropdownMenu<String>(
          width: 320,
          label: const Text("Fachbereich"),
          helperText: 'Fachbereich auswählen',
          enableFilter: true,
          // onSelected: (String value) => , add functionality later
          dropdownMenuEntries: fachbereichAuswahl),
      DropdownMenu<String>(
          width: 320,
          label: const Text("Semester"),
          helperText: 'Semester auswählen',
          enableFilter: true,
          // onSelected: (String value) => , add functionality later
          dropdownMenuEntries: semesterAuswahl),
      Column(
          children: kurse.map((kurs) {
        return CheckboxListTile(
            title: Text(kurs["name"]),
            value: kurs["isChecked"],
            onChanged: (val) {
              setState(() {
                kurs["isChecked"] = val;
              });
            });
      }).toList()),
      TextButton(
        style: ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(Colors.lightBlue),
            foregroundColor:
                MaterialStatePropertyAll<Color>(Color(0xffffffff))),
        onPressed: _kursAuswahlSpeichern,
        child: Text("Auswahl Speichern"),
      )
    ]));
  }
}
