// ignore_for_file: prefer_const_constructors, sort_child_properties_last
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_service.dart';
import 'main.dart';
import 'package:toastification/toastification.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditorView extends StatefulWidget {
  const EditorView({super.key});

  @override
  _EditorViewState createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView> {
  Widget saveButton() {
    return showKursAuswahl == true
        ? ElevatedButton(
            onPressed: () => _checkboxenAuswerten(userselectedKurse, kursListe),
            child: Text(
              "Auswahl Speichern",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              fixedSize: Size(MediaQuery.sizeOf(context).width * 0.75, 60),
              backgroundColor: const Color(0xFF0766AD),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          )
        : Container();
  }

  Future<http.Response> postKursauswahl(
      List<int> anwahlen, List<int> abwahlen) async {
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
    AuthService authService = AuthService();
    String? token = await authService.getToken();
    var url = Uri.http("${dotenv.env['SERVER']}:${dotenv.env['PORT']}",
        '/auswahlmenue/kurse/$semesterId');

    final header = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'apllication/json',
    };

    final response = await http.get(url, headers: header);

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
              icon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.settings,
                  size: 32,
                ),
              ),
              onSelected: (value) {
                if (value == 'theme_select') {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                            backgroundColor: Colors.white,
                            insetPadding: const EdgeInsets.all(10),
                            child: Container(
                              width: 380,
                              height: 550,
                              child:
                                  Stack(alignment: Alignment.center, children: [
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(32.0),
                                      child: Text(
                                        "Wähle das gewünschte Theme:",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 26,
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          fixedSize: Size(320, 54),
                                          backgroundColor: Color(0xFFD91656),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                        ),
                                        onPressed: () {
                                          setColorTheme(1);
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          "Theme 1",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                              color: Color(0xFF640D5F)),
                                        )),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF355F2E),
                                          fixedSize: Size(320, 54),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                        ),
                                        onPressed: () {
                                          setColorTheme(2);
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          "Theme 2",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                              color: Color(0xFFA8CD89)),
                                        )),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFFB3C8CF),
                                          fixedSize: Size(320, 54),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                        ),
                                        onPressed: () {
                                          setColorTheme(3);
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          "Theme 3",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                              color: Color(0xFFE5E1DA)),
                                        )),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFFAB886D),
                                          fixedSize: Size(320, 54),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                        ),
                                        onPressed: () {
                                          setColorTheme(4);
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          "Theme 4",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                              color: Color(0xFFD6C0B3)),
                                        )),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFFFD8B51),
                                          fixedSize: Size(320, 54),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                        ),
                                        onPressed: () {
                                          setColorTheme(5);
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          "Theme 5",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                              color: Color(0xFFF2E5BF)),
                                        )),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF0A5EB0),
                                          fixedSize: Size(320, 54),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                        ),
                                        onPressed: () {
                                          setColorTheme(0);
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          "Default",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                              color: Color(0xFF0A97B0)),
                                        )),
                                  ],
                                ),
                              ]),
                            ));
                      });
                } else if (value == 'logout') {
                  AuthService authService = AuthService();
                  authService.logout();
                  Navigator.pushReplacementNamed(context, '/login');
                } else if (value == 'reset') {
                  // FUNKTIONSAUFRUF UM ALLE KURSE FÜR DEN USER ZU LEEREN
                  // AM BESTEN NOCH EIN PUP UP UM SICHER ZU GEHEN, DASS MAN SICH NICHT VERKLICKT
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: 'theme_select',
                  child: Text('Farbauswahl'),
                ),
                PopupMenuItem(
                  value: 'reset',
                  child: Text('Reset Kurse'),
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
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "Kurseditor",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                    color: Color.fromARGB(255, 25, 25, 25)),
              ),
            ),
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
                      kursListe = jsonDecode(jsonEncode(snapshot.data!));

                      // standardcase
                      return StatefulBuilder(builder:
                          (BuildContext context, StateSetter setState) {
                        return ConstrainedBox(
                            constraints: BoxConstraints(
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.4),
                            child: Scrollbar(
                              thumbVisibility: true,
                              child: SingleChildScrollView(
                                  controller: _scrollController,
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
                                              value: kurs["isChecked"],
                                              onChanged: (val) {
                                                setState(() {
                                                  kurs["isChecked"] = val;
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

  setColorTheme(int selection) async {
    toastification.show(
      context: context,
      type: ToastificationType.success,
      title: Text('Farbauswahl gespeichert!'),
      autoCloseDuration: const Duration(seconds: 3),
    );

    final prefs = await SharedPreferences.getInstance();

    if (selection == 1) {
      // RED - PURPLE
      prefs.setInt('primaryColor', 0xFFD91656);
      prefs.setInt('secondaryColor', 0xFF640D5F);
    } else if (selection == 2) {
      // GREEN
      prefs.setInt('primaryColor', 0xFF355F2E);
      prefs.setInt('secondaryColor', 0xFFA8CD89);
    } else if (selection == 3) {
      // BLUEISH
      prefs.setInt('primaryColor', 0xFFB3C8CF);
      prefs.setInt('secondaryColor', 0xFFE5E1DA);
    } else if (selection == 4) {
      // LIGHT
      prefs.setInt('primaryColor', 0xFFAB886D);
      prefs.setInt('secondaryColor', 0xFFD6C0B3);
    } else if (selection == 5) {
      //
      prefs.setInt('primaryColor', 0xFFFD8B51);
      prefs.setInt('secondaryColor', 0xFFF2E5BF);
    } else {
      // DEFAULT
      prefs.setInt('primaryColor', 0xFF0A5EB0);
      prefs.setInt('secondaryColor', 0xFF0A97B0);
    }
  }
}
