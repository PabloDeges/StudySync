// ignore_for_file: prefer_typing_uninitialized_variables, empty_catches, prefer_interpolation_to_compose_strings, sized_box_for_whitespace

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';
import 'main.dart';
import 'auth_service.dart';

class WeekView extends StatefulWidget {
  const WeekView({super.key});

  @override
  _WeekViewState createState() => _WeekViewState();
}

class _WeekViewState extends State<WeekView> {
  final commentController = TextEditingController();
  final linkController = TextEditingController();
  final mailController = TextEditingController();

  int primaryColor = 0xFF29ADB2;
  int secondaryColor = 0xFF0766AD;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    commentController.dispose();
    linkController.dispose();
    mailController.dispose();
    super.dispose();
  }

  void removeKurs(terminid) async {
    AuthService authService = AuthService();
    String? token = await authService.getToken();
    http.Response response = await http.delete(
        Uri.http("${dotenv.env['SERVER']}:${dotenv.env['PORT']}",
            '/terminEntfernen'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'terminid': terminid,
        }));
    if (response.statusCode == 200) {
      toastification.show(
        context: context,
        type: ToastificationType.success,
        title: Text('Kurs wurde entfernt'),
        autoCloseDuration: const Duration(seconds: 3),
      );
    }
  }

  Future<Map<String, dynamic>> fetchWeek() async {
    final prefs = await SharedPreferences.getInstance();

    primaryColor = prefs.getInt('primaryColor') ?? 0xFF29ADB2;
    secondaryColor = prefs.getInt('secondaryColor') ?? 0xFF0766AD;

    try {
      AuthService authService = AuthService();
      var url = Uri.http(
        "${dotenv.env['SERVER']}:${dotenv.env['PORT']}",
        '/stundenplan',
      );
      String? token = await authService.getToken();
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
      var response = await http.get(url, headers: headers);

      if (response.statusCode == 401) {
        authService.logout();
        navigatorKey.currentState?.pushReplacementNamed('/login');
      }

      if (response.statusCode == 200) {
        final decResponse = jsonDecode(response.body) as Map<String, dynamic>;
        return decResponse;
      } else {
        throw ErrorDescription("responsecode != 200: ${response.statusCode}");
      }
    } catch (error) {
      throw Exception("Fehler beim Laden der Woche: $error");
    }
  }

  Future<http.Response> aenderungenSpeichern(
      String kommentar, String email, String link, String terminID) async {
    toastification.show(
      context: context,
      type: ToastificationType.success,
      title: Text('Änderungen gespeichert'),
      autoCloseDuration: const Duration(seconds: 5),
    );
    AuthService authService = AuthService();
    String? token = await authService.getToken();
    return http.post(
      Uri.http("${dotenv.env['SERVER']}:${dotenv.env['PORT']}",
          '/editor/customStrings'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'comment': kommentar,
        'mail': email,
        'link': link,
        'terminid': terminID,
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> weekdays = [
      "Montag",
      "Dienstag",
      "Mittwoch",
      "Donnerstag",
      "Freitag"
    ];

    void collisionSelection(id, day, time) async {
      AuthService authService = AuthService();
      String? token = await authService.getToken();
      http.Response response = await http.delete(
        Uri.http("${dotenv.env['SERVER']}:${dotenv.env['PORT']}",
            '/editor/kollisionen'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'terminid': id,
          'day': day,
          'time': time,
        }),
      );
      if (response.statusCode == 200) {
        toastification.show(
          context: context,
          type: ToastificationType.success,
          title: Text('Doppelung behoben!'),
          autoCloseDuration: const Duration(seconds: 3),
        );
      }
    }

    void showCollisionPopUp(
        List doppelungen, day, time, primaryColor, secondaryColor) {
      var formattedDay = weekdays[day];
      var formattedTime = ((8 + time));

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              child: Container(
                height: 500,
                width: 500,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: const Color.fromARGB(255, 255, 245, 245),
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Doppelung erkannt!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(primaryColor),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Bitte wähle aus welchen Kurs du am $formattedDay um $formattedTime Uhr belegen möchtest:",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                    Column(
                        children: doppelungen.map((kurs) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            collisionSelection(kurs['terminid'], weekdays[day],
                                ((8 + time) * 100));
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(primaryColor),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 12.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: Text(
                            kurs["kursname"],
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    }).toList()),
                  ],
                ),
              ),
            );
          });
    }

    void hasCollision(timetable, day, time) {
      try {
        List kurseInSlot = timetable
            .where((x) =>
                x['wochentag'] == weekdays[day] &&
                x['startzeit'] == (8 + time) * 100)
            .toList();

        if (kurseInSlot.length <= 1) {
        } else {
          showCollisionPopUp(
              kurseInSlot, day, time, primaryColor, secondaryColor);
        }
      } catch (x) {}
    }

    String supplyDataToCell(timetable, day, time, data) {
      String kuerzel = "";

      try {
        kuerzel = timetable
            .where((x) =>
                x['wochentag'] == weekdays[day] &&
                x['startzeit'] == (8 + time) * 100)
            .toList()[0][data];
      } catch (x) {}

      return kuerzel;
    }

    String supplyDataToCellWithCheck(timetable, day, time, data) {
      String kuerzel = "";

      Future.delayed(Duration.zero, () async {
        hasCollision(timetable, day, time);
      });

      try {
        kuerzel = timetable
            .where((x) =>
                x['wochentag'] == weekdays[day] &&
                x['startzeit'] == (8 + time) * 100)
            .toList()[0][data];
      } catch (x) {}

      return kuerzel;
    }

    String supplyKursartAusgeschrieben(String kursartShort) {
      switch (kursartShort) {
        case "V":
          return "Vorlesung";
        case "P":
          return "Praktikum";
        case "U":
          return "Übung";
        default:
          "";
      }
      return "";
    }

    void displayEditPopUp(timetable, time, day, primaryColor, secondaryColor) {
      var selectedCell;
      try {
        selectedCell = timetable
            .where((x) =>
                x['wochentag'] == weekdays[day] &&
                x['startzeit'] == (8 + time) * 100)
            .toList()[0];
      } catch (x) {}

      //TEXTFELDER BEFÜLLEN
      commentController.text =
          supplyDataToCell(timetable, day, time, 'kommentar');
      mailController.text = supplyDataToCell(timetable, day, time, 'mail');
      linkController.text = supplyDataToCell(timetable, day, time, 'kurslink');

      if (selectedCell != null) {
        // falls die angeklickte Zelle einen Inhalt hat, zeige ein Pop Up an
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return SingleChildScrollView(
                child: Dialog(
                    backgroundColor: Colors.transparent,
                    insetPadding: const EdgeInsets.all(10),
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Container(
                            width: double.infinity,
                            height: MediaQuery.sizeOf(context).height * 0.86,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Color.fromARGB(255, 239, 239, 239)),
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "BEARBEITEN VON: ",
                                      style: TextStyle(
                                          color: Color(primaryColor),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                    ),
                                    ElevatedButton.icon(
                                        style: const ButtonStyle(
                                            backgroundColor:
                                                WidgetStatePropertyAll(
                                                    Color.fromARGB(
                                                        255, 194, 42, 31))),
                                        onPressed: () =>
                                            {Navigator.pop(context)},
                                        label: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                        )),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  supplyKursartAusgeschrieben(supplyDataToCell(
                                      timetable, day, time, 'terminart')),
                                  style: TextStyle(
                                      color: Color(primaryColor),
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  supplyDataToCell(
                                          timetable, day, time, 'kursname') +
                                      " (" +
                                      supplyDataToCell(timetable, day, time,
                                              'kurskuerzel')
                                          .toUpperCase() +
                                      ")",
                                  style: TextStyle(
                                      fontSize: 24,
                                      color: Color(primaryColor),
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(
                                  height: 40,
                                ),
                                Row(
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              70,
                                          child: TextField(
                                            key: const Key("commentInput"),
                                            maxLines: 6,
                                            minLines: 6,
                                            decoration: InputDecoration(
                                              labelText: 'Kommentar bearbeiten',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                borderSide: BorderSide(
                                                    color: Color(primaryColor)),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                TextField(
                                  // TEXT FIELD EMAIL
                                  decoration: InputDecoration(
                                      labelText: "Doz. Email bearbeiten"),

                                  controller: mailController,
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                TextField(
                                  // TEXT FIELD MOODLE LINK
                                  decoration: InputDecoration(
                                      labelText: "Moodle Link bearbeiten"),

                                  controller: linkController,
                                ),
                                const SizedBox(
                                  height: 40,
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    aenderungenSpeichern(
                                        commentController.text,
                                        mailController.text,
                                        linkController.text,
                                        supplyDataToCell(
                                            timetable, day, time, 'terminid'));

                                    toastification.show(
                                      context: context,
                                      type: ToastificationType.success,
                                      title: Text('Änderungen gespeichert!'),
                                      autoCloseDuration:
                                          const Duration(seconds: 5),
                                    );
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(primaryColor),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 12.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  child: Text(
                                    'Änderungen speichern',
                                    style: TextStyle(
                                      color: Color(secondaryColor),
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                ElevatedButton(
                                  // TERMIN LÖSCHEN BUTTON
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  'Möchtest du ' +
                                                      supplyDataToCell(
                                                          timetable,
                                                          day,
                                                          time,
                                                          'kursname') +
                                                      ' aus deinem Stundenplan entfernen?',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 20),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Text(
                                                      'Abbrechen',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                    style: ButtonStyle(
                                                        shape: WidgetStatePropertyAll(
                                                            RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20))),
                                                        backgroundColor:
                                                            WidgetStatePropertyAll(
                                                                Colors.grey)),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      removeKurs(
                                                          supplyDataToCell(
                                                              timetable,
                                                              day,
                                                              time,
                                                              'terminid'));
                                                      Navigator.of(context)
                                                          .pop();
                                                      Navigator.of(context)
                                                          .pop();
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Text(
                                                      'Termin entfernen',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    style: ButtonStyle(
                                                        shape: WidgetStatePropertyAll(
                                                            RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20))),
                                                        backgroundColor:
                                                            WidgetStatePropertyAll(
                                                                Colors.red)),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 12.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  child: Text(
                                    'Termin löschen',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            )),
                      ],
                    )),
              );
            });
      }
    }

    void displayPopUp(timetable, time, day, primaryColor, secondaryColor) {
      var selectedCell;
      try {
        selectedCell = timetable
            .where((x) =>
                x['wochentag'] == weekdays[day] &&
                x['startzeit'] == (8 + time) * 100)
            .toList()[0];
      } catch (x) {}

      if (selectedCell != null) {
        // falls die angeklickte Zelle einen Inhalt hat, zeige ein Pop Up an
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return SingleChildScrollView(
                child: Dialog(
                    backgroundColor: Colors.transparent,
                    insetPadding: const EdgeInsets.all(10),
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Container(
                            width: double.infinity,
                            height: MediaQuery.sizeOf(context).height * 0.8,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Color.fromARGB(255, 239, 239, 239)),
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton.icon(
                                        style: const ButtonStyle(
                                            backgroundColor:
                                                WidgetStatePropertyAll(
                                                    Color(0xFF0766AD))),
                                        onPressed: () => {
                                              displayEditPopUp(
                                                  timetable,
                                                  time,
                                                  day,
                                                  primaryColor,
                                                  secondaryColor)
                                            },
                                        label: const Icon(
                                          Icons.edit,
                                          color: Colors.white,
                                        )),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    ElevatedButton.icon(
                                        style: const ButtonStyle(
                                            backgroundColor:
                                                WidgetStatePropertyAll(
                                                    Color.fromARGB(
                                                        255, 194, 42, 31))),
                                        onPressed: () =>
                                            {Navigator.pop(context)},
                                        label: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                        )),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  supplyKursartAusgeschrieben(supplyDataToCell(
                                      timetable, day, time, 'terminart')),
                                  style: TextStyle(
                                      color: Color(primaryColor),
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  supplyDataToCell(
                                          timetable, day, time, 'kursname') +
                                      " (" +
                                      supplyDataToCell(timetable, day, time,
                                              'kurskuerzel')
                                          .toUpperCase() +
                                      ")",
                                  style: TextStyle(
                                      fontSize: 24,
                                      color: Color(primaryColor),
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.room,
                                      size: 50,
                                      color: Color(secondaryColor),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          25.0, 0, 15.0, 0),
                                      child: Text(
                                        supplyDataToCell(
                                            timetable, day, time, 'raum'),
                                        style: TextStyle(
                                            color: Color(primaryColor),
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.school,
                                      size: 50,
                                      color: Color(secondaryColor),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          25.0, 0, 15.0, 0),
                                      child: Text(
                                        supplyDataToCell(
                                            timetable, day, time, 'dozname'),
                                        style: TextStyle(
                                            color: Color(primaryColor),
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.comment,
                                      size: 50,
                                      color: Color(secondaryColor),
                                    ),
                                    Container(
                                      width:
                                          ((MediaQuery.sizeOf(context).width) *
                                              0.7),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            25.0, 0, 15.0, 0),
                                        child: Text(
                                          supplyDataToCell(timetable, day, time,
                                                      'kommentar')
                                                  .isEmpty
                                              ? "Kein Kommentar hinzugefügt "
                                              : supplyDataToCell(timetable, day,
                                                  time, 'kommentar'),
                                          style: TextStyle(
                                              color: Color(primaryColor),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                          softWrap: true,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 100,
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    fixedSize: Size(
                                        MediaQuery.sizeOf(context).width * 0.75,
                                        60),
                                    backgroundColor: Color(primaryColor),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  onPressed: () async {
                                    String url = supplyDataToCell(
                                        timetable, day, time, 'kurslink');

                                    final parsedLink = Uri.parse(url);
                                    if (await canLaunchUrl(parsedLink)) {
                                      await launchUrl(parsedLink);
                                    } else {
                                      print("url launch fehlgeschlagen");
                                    }
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.link,
                                        color: Color(secondaryColor),
                                      ),
                                      SizedBox(width: 8),
                                      // Text
                                      Text(
                                        'Moodle Kurs öffnen',
                                        style: TextStyle(
                                            color: Color(secondaryColor),
                                            fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    fixedSize: Size(
                                        MediaQuery.sizeOf(context).width * 0.75,
                                        60),
                                    backgroundColor: Color(primaryColor),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  onPressed: () async {
                                    String url = supplyDataToCell(
                                        timetable, day, time, 'mail');

                                    var mailUri =
                                        Uri(scheme: 'mailto', path: url);

                                    if (await canLaunchUrl(mailUri)) {
                                      await launchUrl(mailUri);
                                    } else {
                                      throw 'Could not launch $url';
                                    }
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.mail,
                                        color: Color(secondaryColor),
                                      ),
                                      SizedBox(width: 8),
                                      // Text
                                      Text(
                                        'Email an Kursleitende',
                                        style: TextStyle(
                                            color: Color(secondaryColor),
                                            fontSize: 16),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            )),
                      ],
                    )),
              );
            });
      }
    }

    return FutureBuilder<Map<String, dynamic>>(
      future: fetchWeek(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Da ist ein Fehler aufgetreten. Probieren Sie es später erneut.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          );
        } else if (!snapshot.hasData) {
          return const Center(child: Text('Keine Daten verfügbar.'));
        }

        final timetable = snapshot.data!["data"];

        return Column(
          children: [
            const WeekdayIndicator(),
            Expanded(
              child: Column(
                children: List.generate(13, (timeOffset) {
                  return Expanded(
                    child: Row(
                      children: List.generate(5, (day) {
                        return Expanded(
                          child:
                              InkWell // sorgt dafür dass man bei Klick auf einer Zelle eine Funktion ausführen kann
                                  (
                            onTap: () => {
                              displayPopUp(timetable, timeOffset, day,
                                  primaryColor, secondaryColor)
                            },
                            child: Container(
                              margin: const EdgeInsets.all(1.0),
                              color: timeOffset % 2 == 0
                                  ? Color(primaryColor)
                                  : Color(secondaryColor),
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: 1,
                                    left: 1,
                                    child: Text(
                                      "${8 + timeOffset}:00",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          supplyDataToCellWithCheck(
                                                  timetable,
                                                  day,
                                                  timeOffset,
                                                  'kurskuerzel')
                                              .toUpperCase(),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(
                                              maxWidth: 90),
                                          child: Text(
                                            supplyDataToCell(timetable, day,
                                                    timeOffset, 'raum')
                                                .toUpperCase(),
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 8,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }
}

class WeekdayIndicator extends StatelessWidget {
  const WeekdayIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    int currentDayIndex = DateTime.now().weekday - 1;
    return Row(
      children: List.generate(5, (index) {
        return Expanded(
          child: Container(
            padding: const EdgeInsets.all(4.0),
            margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 3.0),
            decoration: BoxDecoration(
              color: index == currentDayIndex
                  ? const Color(0xFFC5E898)
                  : Colors.grey,
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Center(
              child: Text(
                ['MO', 'DI', 'MI', 'DO', 'FR'][index],
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
