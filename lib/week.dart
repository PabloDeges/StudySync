import 'dart:convert';
import 'package:flutter/material.dart';
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
            .toList()[0][data]
            .toUpperCase();
      } catch (x) {}

      return kuerzel;
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment
                                        .center,
                                    children: [
                                      Text(
                                        supplyDataToCell(timetable, day,
                                            timeOffset, 'kurskuerzel'),
                                        textAlign: TextAlign
                                            .center,
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
                                          supplyDataToCell(
                                              timetable, day, timeOffset, 'raum'),
                                          textAlign: TextAlign
                                              .center,
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
