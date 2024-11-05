// ignore_for_file: prefer_const_constructors
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EditorView extends StatefulWidget {
  const EditorView({super.key});

  @override
  _EditorViewState createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView> {
  void _kursAuswahlSpeichern() {}

  List<DropdownMenuEntry<String>> convertStudiengaengeToDropdowns(
      List<dynamic> data) {
    List<DropdownMenuEntry<String>> tempList = [];
    for (var x in data) {
      tempList.add(DropdownMenuEntry(
          value: x['id'].toString(), label: x['studiengang']));
    }
    return tempList;
  }

  List<DropdownMenuEntry<String>> convertSemesterToDropdowns(
      List<dynamic> data) {
    List<DropdownMenuEntry<String>> tempList = [];
    for (var x in data) {
      tempList
          .add(DropdownMenuEntry(value: x['id'], label: x['semesterkennung']));
    }
    return tempList;
  }

  Future<List<dynamic>> fetchStudiengaenge() async {
    var url = Uri.http("${dotenv.env['SERVER']}:${dotenv.env['PORT']}",
        '/auswahlmenue/studiengaenge');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Fehler beim Aufruf entstanden (Fetch Studiengaenge)');
    }
  }

  Future<List<dynamic>> fetchSemesterVonStudiengaenge(var id) async {
    var url = Uri.http("${dotenv.env['SERVER']}:${dotenv.env['PORT']}",
        '/auswahlmenue/semester/{$id}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Fehler beim Aufruf entstanden (Fetch Semester)');
    }
  }

  Future<List<dynamic>> fetchKurseVonSemester(var semesterId) async {
    var url = Uri.http("${dotenv.env['SERVER']}:${dotenv.env['PORT']}",
        '/auswahlmenue/kurse/{$semesterId}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Fehler beim Aufruf entstanden (Fetch Kurse)');
    }
  }

  late Future<List<dynamic>> _studiengangAuswahl;
  late Future<List<dynamic>> _semesterAuswahl = Future.value([
    {""}
  ]);

  @override
  void initState() {
    super.initState();
    _studiengangAuswahl = fetchStudiengaenge();
  }

  Widget build(BuildContext context) {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      FutureBuilder<List<dynamic>>(
          future: _studiengangAuswahl,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return const Text("Fehler");
              }
              if (snapshot.hasData && snapshot.data != null) {
                // standardcase

                List<DropdownMenuEntry<String>> studiengaenge =
                    convertStudiengaengeToDropdowns(snapshot.data!);

                return DropdownMenu<String>(
                    menuHeight: 200,
                    width: 320,
                    label: const Text("Studiengang"),
                    helperText: 'Studiengang auswählen',
                    enableFilter: true,
                    onSelected: (value) => {
                          _semesterAuswahl =
                              fetchSemesterVonStudiengaenge(value)
                        },
                    dropdownMenuEntries: studiengaenge);
              }
            }
            return const CircularProgressIndicator();
          }),
      FutureBuilder<List<dynamic>>(
          future: _semesterAuswahl,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(height: 200);
            }
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return const Text("Fehler");
              }
              if (snapshot.hasData && snapshot.data != null) {
                // standardcase

                List<DropdownMenuEntry<String>> semester =
                    convertSemesterToDropdowns(snapshot.data!);

                return DropdownMenu<String>(
                    menuHeight: 200,
                    width: 320,
                    label: const Text("Semester"),
                    helperText: 'Semester auswählen',
                    enableFilter: true,
                    onSelected: (value) =>
                        {_semesterAuswahl = fetchKurseVonSemester(value)},
                    dropdownMenuEntries: semester);
              }
            }
            return const CircularProgressIndicator();
          }),
    ]));
  }
}
