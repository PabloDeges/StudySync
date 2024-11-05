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
      tempList.add(DropdownMenuEntry(
          value: x['id'].toString(), label: x['semesterkennung']));
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
        '/auswahlmenue/semester/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {});
      showSemesterAuswahl = true;
      return jsonDecode(response.body);
    } else {
      throw Exception('Fehler beim Aufruf entstanden (Fetch Semester)');
    }
  }

  Future<List<dynamic>> fetchKurseVonSemester(var semesterId) async {
    var url = Uri.http("${dotenv.env['SERVER']}:${dotenv.env['PORT']}",
        '/auswahlmenue/kurse/$semesterId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Fehler beim Aufruf entstanden (Fetch Kurse)');
    }
  }

  late Future<List<dynamic>> _studiengangAuswahl;
  late Future<List<dynamic>> _semesterAuswahl = Future.value([
    {"id": 0, "semesterkennung": "-"}
  ]);
  late Future<List<dynamic>> _kursAuswahl = Future.value([
    {"id": 1, "kursname": "-"}
  ]);

  bool showSemesterAuswahl = false;
  bool showKursAuswahl = false;

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
      SizedBox(height: 50),
      FutureBuilder<List<dynamic>>(
          future: _semesterAuswahl,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return const Text(
                    "SEMESTERAUSWAHL BUILDER HATTE  EINEN FEHLER");
              }
              if (snapshot.hasData &&
                  snapshot.data != null &&
                  !showSemesterAuswahl) {
                // zustand bevor ein studiengang ausgewählt wurde

                return DropdownMenu<String>(
                  menuHeight: 200,
                  width: 320,
                  label: const Text("Semester"),
                  enableFilter: true,
                  dropdownMenuEntries: [],
                  helperText: "Wähle zuerst einen Studiengang aus",
                );
              }
              if (snapshot.hasData &&
                  snapshot.data != null &&
                  showSemesterAuswahl) {
                // standardcase

                List<DropdownMenuEntry<String>> semester =
                    convertSemesterToDropdowns(snapshot.data!);

                return DropdownMenu<String>(
                    menuHeight: 200,
                    width: 320,
                    label: const Text("Semester"),
                    enableFilter: true,
                    onSelected: (value) =>
                        {_semesterAuswahl = fetchKurseVonSemester(value)},
                    dropdownMenuEntries: semester);
              }
            }
            return const CircularProgressIndicator();
          }),
      SizedBox(height: 50),
      FutureBuilder<List<dynamic>>(
          future: _kursAuswahl,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return const Text("KURSAUSWAHL BUILDER HATTE  EINEN FEHLER");
              }
              if (snapshot.hasData &&
                  snapshot.data != null &&
                  !showKursAuswahl) {
                // zustand bevor ein semester ausgewählt wurde
                return const Text("wähle zunächst ein Semester aus");
              }
              if (snapshot.hasData &&
                  snapshot.data != null &&
                  showKursAuswahl) {
                // standardcase
                return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: kurse.map((kurs) {
            return SizedBox(
                width: 300,
                child: CheckboxListTile(
                    title: Text(kurs["name"]),
                    value: kurs["isChecked"],
                    onChanged: (val) {
                      setState(() {
                        kurs["isChecked"] = val;
                      });
                    }));
          }).toList()),
      TextButton(
        style: ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(Colors.lightBlue),
            foregroundColor:
                MaterialStatePropertyAll<Color>(Color(0xffffffff))),
        onPressed: _kursAuswahlSpeichern,
        child: Text("Auswahl Speichern"),
      )
              }
            }
            return const CircularProgressIndicator();
          }),
    ]));
  }
}
