// ignore_for_file: prefer_typing_uninitialized_variables, empty_catches, prefer_interpolation_to_compose_strings, sized_box_for_whitespace

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

class WeekView extends StatefulWidget {
  const WeekView({super.key});

  @override
  _WeekViewState createState() => _WeekViewState();
}

class _WeekViewState extends State<WeekView> {
  final commentController = TextEditingController();
  final linkController = TextEditingController();
  final mailController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    commentController.dispose();
    linkController.dispose();
    mailController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> fetchWeek() async {
    try {
      var params = {'userid': '1'};
      var url = Uri.http("${dotenv.env['SERVER']}:${dotenv.env['PORT']}",
          '/stundenplan', params);
      var response = await http.get(url);
      if (response.statusCode == 200) {
        final decResponse = jsonDecode(response.body) as Map<String, dynamic>;
        return decResponse;
      } else {
        throw ErrorDescription("responsecode != 200");
      }
    } catch (error) {
      throw Exception("Fehler beim Laden der Woche");
    }
  }

  Future<http.Response> aenderungenSpeichern(
      // NACH MERGE FEEDBACK NOTIFICATION ADDEN BEI SPEICHERN
      String kommentar,
      String email,
      String link) async {
    return http.post(
      Uri.http(
          "${dotenv.env['SERVER']}:${dotenv.env['PORT']}", '/editKommentar'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'kommentar': kommentar,
        // 'email': email,
        // 'link': link,
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

    void collisionSelection(id, day, time) {
      print(
          "Es wurde der Kurs mit der ID: $id am $day um $time als beizubehaltendes fach ausgewählt.");

      // WENN BACKEND ROUTE STEHT => Parameter ans Backend Senden mit Post
    }

    void showCollisionPopUp(List doppelungen, day, time) {
      var formattedDay = weekdays[day];
      var formattedTime = ((8 + time));

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              child: Container(
                height: 500,
                width: 500,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      "Doppelung erkannt!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Bitte wähle aus welchen Kurs du am $formattedDay ab $formattedTime Uhr belegen möchtest:",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                    Column(
                        children: doppelungen.map((kurs) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            collisionSelection(kurs["id"], day, time);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0766AD),
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
          showCollisionPopUp(kurseInSlot, day, time);
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

    void displayEditPopUp(timetable, time, day) {
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
      mailController.text = supplyDataToCell(timetable, day, time, 'email');
      linkController.text = supplyDataToCell(timetable, day, time, 'link');

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
                            height: MediaQuery.sizeOf(context).height *
                                0.75, // noch hardcoded, später dynamisch anpassen
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color:
                                    const Color.fromARGB(255, 232, 247, 255)),
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "BEARBEITEN VON: ",
                                      style: TextStyle(
                                          color: Color(0xFF0766AD),
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
                                  style: const TextStyle(
                                      color: Color(0xFF0766AD),
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
                                  style: const TextStyle(
                                      fontSize: 24,
                                      color: Color(0xFF0766AD),
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                const SizedBox(
                                  height: 20,
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
                                                borderSide: const BorderSide(
                                                    color: Color(0xFF0766AD)),
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
                                        linkController.text);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0766AD),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 12.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  child: const Text(
                                    'Änderungen speichern',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
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

    void displayPopUp(timetable, time, day) {
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
                            height: MediaQuery.sizeOf(context).height * 0.75,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color:
                                    const Color.fromARGB(255, 232, 247, 255)),
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
                                                  timetable, time, day)
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
                                  style: const TextStyle(
                                      color: Color(0xFF0766AD),
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
                                  style: const TextStyle(
                                      fontSize: 24,
                                      color: Color(0xFF0766AD),
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.room,
                                      size: 50,
                                      color: Color(0xFF29ADB2),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          25.0, 0, 15.0, 0),
                                      child: Text(
                                        supplyDataToCell(
                                            timetable, day, time, 'raum'),
                                        style: const TextStyle(
                                            color: Color(0xFF0766AD),
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
                                    const Icon(
                                      Icons.school,
                                      size: 50,
                                      color: Color(0xFF29ADB2),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          25.0, 0, 15.0, 0),
                                      child: Text(
                                        supplyDataToCell(
                                            timetable, day, time, 'dozname'),
                                        style: const TextStyle(
                                            color: Color(0xFF0766AD),
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
                                    const Icon(
                                      Icons.comment,
                                      size: 50,
                                      color: Color(0xFF29ADB2),
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
                                          style: const TextStyle(
                                              color: Color(0xFF0766AD),
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
                                    backgroundColor: Colors.blue,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 12.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  onPressed: () async {
                                    String url =
                                        "https://moodle.hs-bochum.de/course/view.php?id=6987";
                                    // String url = supplyDataToCell(timetable, day, time, 'moodle_link');

                                    final parsedLink = Uri.parse(url);
                                    if (await canLaunchUrl(parsedLink)) {
                                      await launchUrl(parsedLink);
                                    } else {
                                      throw 'Could not launch $url';
                                    }
                                  },
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.link,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 8),
                                      // Text
                                      Text(
                                        'Moodle Kurs öffnen',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16),
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
                                    backgroundColor: Colors.blue,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 12.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  onPressed: () async {
                                    String url = "max.mustermann@hs-bochum.de";
                                    // String url = supplyDataToCell(timetable, day, time, 'email');

                                    var mailUri =
                                        Uri(scheme: 'mailto', path: url);

                                    if (await canLaunchUrl(mailUri)) {
                                      await launchUrl(mailUri);
                                    } else {
                                      throw 'Could not launch $url';
                                    }
                                  },
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.mail,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 8),
                                      // Text
                                      Text(
                                        'Email an Kursleitende',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16),
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
                            onTap: () =>
                                {displayPopUp(timetable, timeOffset, day)},
                            child: Container(
                              margin: const EdgeInsets.all(1.0),
                              color: timeOffset % 2 == 0
                                  ? const Color(0xFF29ADB2)
                                  : const Color(0xFF0766AD),
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
