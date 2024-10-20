import 'package:flutter/material.dart';

class EditorView extends StatelessWidget {
  const EditorView({super.key});

  static const fachbereichAuswahl = [
    DropdownMenuEntry(value: "EI", label: "Elektrotechnik / Informatik"),
    DropdownMenuEntry(value: "NE", label: "Nachhaltige Entwicklung"),
    DropdownMenuEntry(value: "BWL", label: "Geldhaben")
  ];

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: DropdownMenu<String>(
          label: const Text("Fachbereich"),
          helperText: 'Fachbereich auswählen',
          enableFilter: true,
          // onSelected: (String value) => , add functionality later
          dropdownMenuEntries: fachbereichAuswahl),
    );
  }
}
