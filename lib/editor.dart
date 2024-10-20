import 'dart:nativewrappers/_internal/vm/lib/internal_patch.dart';

import 'package:flutter/material.dart';

class EditorView extends StatelessWidget {
  const EditorView({super.key});

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

  @override
  Widget build(BuildContext context) {
    return const Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      DropdownMenu<String>(
          width: 320,
          menuStyle: MenuStyle(
              // surfaceTintColor: WidgetStatePropertyAll(Colors.green),
              // shadowColor: WidgetStatePropertyAll(Colors.red),
              // haben irgendwie keinen effekt....
              backgroundColor: WidgetStatePropertyAll(Colors.blue)),
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
      // ADD RADIO BUTTONS
    ]));
  }
}
