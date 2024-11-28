// ignore_for_file: prefer_const_constructors, sort_child_properties_last
import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_service.dart';
import 'main.dart';
import 'package:toastification/toastification.dart';

class EditorView extends StatefulWidget {
  const EditorView({super.key});

  @override
  _EditorViewState createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView> {
  Widget saveButton() {
    return showKursAuswahl == true
        ? TextButton(
            onPressed: () => _checkboxenAuswerten(userselectedKurse, kursListe),
            child: Text(
              "Auswahl Speichern",
              style: TextStyle(color: Colors.white),
            ),
            style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.blue)),
          )
        : Container();
  }

  Future<http.Response> postKursauswahl(List<int> anwahlen, List<int> abwahlen) async {
    toastification.show(
      context: context,
      type: ToastificationType.success,
      title: Text('Kursauswahl gespeichert!'),
      autoCloseDuration: const Duration(seconds: 5),
    );
    AuthService authService = AuthService();
    String? token = await authService.getToken();
    http.Response response = await http.post(
      Uri.http("${dotenv.env['SERVER']}:${dotenv.env['PORT']}",
          '/auswahlmenue/kurse'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'semesterid': currentSemesterid,
        'newkursids': anwahlen,
        'delkursids': abwahlen,
      }),
    );
    if (response.statusCode == 401) {
        authService.logout();
        navigatorKey.currentState?.pushReplacementNamed('/login');
    }

    return response;
  }

  void _checkboxenAuswerten(
      List<dynamic> neueAuswahlen, List<dynamic> vorherigerStand) {
    List<int> anwahlen = [];
    List<int> abwahlen = [];
    List<int> neueAuswahlenIDs = [];
    List<int> vorherigerStandIDs = [];

    for (var kurs in neueAuswahlen) {
      if (kurs["isChecked"]) {
        neueAuswahlenIDs.add(kurs["id"]);
      }
    }

    for (var kurs in vorherigerStand) {
      if (kurs["isChecked"]) {
        vorherigerStandIDs.add(kurs["id"]);
      }
    }

    Set<int> originalSet = vorherigerStandIDs.toSet();

    Set<int> modifiedSet = neueAuswahlenIDs.toSet();

    anwahlen = modifiedSet.difference(originalSet).toList();

    abwahlen = originalSet.difference(modifiedSet).toList();

    if (neueAuswahlen.isNotEmpty && currentSemesterid.isNotEmpty) {
      postKursauswahl(anwahlen, abwahlen);
    }
  }

  List<dynamic> userselectedKurse = [];
  List<dynamic> kursListe = [];

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
      showKursAuswahl = false;
      return jsonDecode(response.body);
    } else {
      throw Exception('Fehler beim Aufruf entstanden (Fetch Semester)');
    }
  }

  Future<List<dynamic>> fetchKurseVonSemester(var semesterId) async {
    var url = Uri.http("${dotenv.env['SERVER']}:${dotenv.env['PORT']}",
        '/auswahlmenue/kurse/$semesterId', {
      'userid': '1',
    });

    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {});
      showKursAuswahl = true;
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
  late String currentSemesterid;

  @override
  void initState() {
    super.initState();
    _studiengangAuswahl = fetchStudiengaenge();
  }

final ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            PopupMenuButton<String>(
              icon: Icon(Icons.settings),
              onSelected: (value) {
                if (value == 'Option 1') {
                  print("Farbe gewählt");
                } else if (value == 'logout') {
                  AuthService authService = AuthService();
                  authService.logout();
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: 'Option 1',
                  child: Text('Farbi X'),
                ),
                PopupMenuItem(
                  value: 'logout',
                  child: Text('Abmelden'),
                ),
              ],
            ),
          ],
        ),
        body: Center(
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
                                    fetchSemesterVonStudiengaenge(value),
                                currentSemesterid =
                                    "", // bei neuauswahl clearen, damit keine falschen posts und datenbankfehler entstehen
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
                          onSelected: (value) => {
                                _kursAuswahl = fetchKurseVonSemester(value),
                                currentSemesterid = value!,
                              },
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
                      return const Text(
                          "KURSAUSWAHL BUILDER HATTE  EINEN FEHLER");
                    }
                    if (snapshot.hasData &&
                        snapshot.data != null &&
                        !showKursAuswahl) {
                      // zustand bevor ein semester ausgewählt wurde
                      return SizedBox();
                    }
                    if (snapshot.hasData &&
                        snapshot.data != null &&
                        showKursAuswahl) {
                      userselectedKurse = snapshot.data!;
                      for (var x in userselectedKurse) {
                        x["checked"] =
                            false; //fügt das feld checked hinzu, damit nachher ausgewertet werden kann
                      }
                      // standardcase
                      return StatefulBuilder(builder:
                          (BuildContext context, StateSetter setState) {
                        return ConstrainedBox(
                            constraints: BoxConstraints(
                                maxHeight:
                                    MediaQuery.of(context).size.height / 2),
                            child: Scrollbar(
                              thumbVisibility: true,
                              child: SingleChildScrollView(
                                  clipBehavior: Clip.antiAlias,
                                  padding: EdgeInsets.all(8),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: userselectedKurse.map((kurs) {
                                        return SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              40,
                                          child: CheckboxListTile(
                                              // shape: RoundedRectangleBorder(
                                              //   side: BorderSide(
                                              //       color: Colors.black,
                                              //       width: 2),
                                              //   borderRadius:
                                              //       BorderRadius.circular(10),

                                              title: Text(kurs["kursname"]),
                                              value: kurs["checked"],
                                              onChanged: (val) {
                                                setState(() {
                                                  kurs["checked"] = val;
                                                });
                                              }),
                                        );
                                      }).toList())),
                            ));
                      });
                    }
                  }
                  return const CircularProgressIndicator();
                }),
            saveButton()
          ]),
        ));
  }
}
