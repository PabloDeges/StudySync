// ignore_for_file: prefer_typing_uninitialized_variables, empty_catches, prefer_interpolation_to_compose_strings, sized_box_for_whitespace

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WeekView extends StatelessWidget {
  const WeekView({super.key});

  @override
  Widget build(BuildContext context) {
    return const WeeklySchedule();
  }
}

class WeeklySchedule extends StatelessWidget {
  const WeeklySchedule({super.key});

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

  void abschicken() async {
    //Kommentar speichern
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

    String supplyKursartAusgeschrieben(String kursartShort) {
      switch (kursartShort) {
        case "V":
          return "Vorlesung";
          break;
        case "P":
          return "Praktikum";
          break;
        case "U":
          return "Übung";
          break;
        default:
          "";
      }
      return "";
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
              return Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding: const EdgeInsets.all(10),
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Container(
                          width: double.infinity,
                          height:
                              550, // noch hardcoded, später dynamisch anpassen
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: const Color.fromARGB(255, 232, 247, 255)),
                          padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                          child: Column(
                            children: [
                              Text(
                                supplyDataToCell(
                                        timetable, day, time, 'kursname') +
                                    " (" +
                                    supplyDataToCell(
                                            timetable, day, time, 'kurskuerzel')
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
                                  const Text(
                                    "Kursart: ",
                                    style: TextStyle(
                                        fontSize: 22,
                                        color: Color(0xFF0766AD),
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        5.0, 0, 15.0, 0),
                                    child: Text(
                                      supplyKursartAusgeschrieben(
                                          supplyDataToCell(timetable, day, time,
                                              'terminart')),
                                      style: const TextStyle(
                                          color: Color(0xFF0766AD),
                                          fontSize: 22,
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
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width -
                                                180,
                                        child: TextField(
                                          maxLines: 3,
                                          minLines: 3,
                                          decoration: InputDecoration(
                                            labelText: 'Hier Text eingeben...',
                                            labelStyle: const TextStyle(
                                                color: Color(0xFF0766AD),
                                                fontWeight: FontWeight.bold),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
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
                                height: 20,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  abschicken();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0766AD),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Kommentar speichern',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          )),
                    ],
                  ));
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
                                          supplyDataToCell(timetable, day,
                                                  timeOffset, 'kurskuerzel')
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
