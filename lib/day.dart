import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DayView extends StatelessWidget {
  const DayView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        FocussedWeekdayIndicator(),
        Expanded(child: DayStudySync()),
      ],
    );
  }
}

class FocussedWeekdayIndicator extends StatelessWidget {
  const FocussedWeekdayIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    int day = now.day;
    int month = now.month;
    int year = now.year;
    String dateShow = "$day.$month.$year";
    double widthDisplay = MediaQuery.sizeOf(context).width;
    int weekday = now.weekday;
    List<String> wochentageShort = ['Mo', 'Di', 'Mi', 'Do', 'Fr'];
    if (weekday > 5) {
      weekday = 1;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(1, (index) {
        return Container(
          width: widthDisplay - 20,
          padding: const EdgeInsets.all(4.0),
          margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
          decoration: BoxDecoration(
            color:const Color(0xFFC5E898),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Center(
            child: Text(
              "${[wochentageShort[weekday - 1]][index]} - $dateShow",
              style: const TextStyle(color: Colors.white, fontSize: 22),

            ),
          ),
        );
      }),
    );
  }
}

class DayStudySync extends StatelessWidget {
  const DayStudySync({super.key});

  Future<Map<String, dynamic>> fetchStundenplan() async {
    var url = Uri.http("${dotenv.env['SERVER']}:${dotenv.env['PORT']}");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Fehler beim Aufruf entstanden (Fetch DayView)');
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    int weekday = now.weekday;

    List<String> wochentage = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday'
    ];

    if (weekday > 5) {
      weekday = 1;
    }

    final double cellHeight =
        (MediaQuery.of(context).size.height - kBottomNavigationBarHeight - 64) /
            13;
        double widthDisplay = MediaQuery.sizeOf(context).width;

    return FutureBuilder<Map<String, dynamic>>(
      future: fetchStundenplan(),
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
        } else if (!snapshot.hasData || snapshot.data!["timetable"] == null) {
          return const Center(child: Text('Keine Daten verfügbar'));
        }

        var stundenplan = snapshot.data!["timetable"];

        return Column(
          children: List.generate(13, (timeOffset) {
            return Expanded(
              child: Container(
                height: cellHeight,
                width: widthDisplay - 20,
                color: timeOffset % 2 == 0
                    ? const Color(0xFF29ADB2)
                    : const Color(0xFF0766AD),
                child: Stack(
                  children: [
                    Positioned(
                      top: 5,
                      left: 5,
                      child: Text(
                        ("${8 + timeOffset}:00"),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Center(
                      child: Column(children: [
                        Text(
                          stundenplan[wochentage[weekday - 1]][timeOffset]
                                  ?["fullname"] ??
                              'Fehler beim Laden',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          stundenplan[wochentage[weekday - 1]][timeOffset]
                                  ?["room"] ??
                              'Fehler beim Laden',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
