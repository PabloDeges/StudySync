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
    final List<String> weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"];
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
        } else if (!snapshot.hasData || snapshot.data!["timetable"] == null) {
          return const Center(child: Text('Keine Daten verfügbar.'));
        }

        final timetable = snapshot.data!["timetable"];

        return Column(
          children: [
            const WeekdayIndicator(),
            Expanded(
              child: Column(
                children: List.generate(13, (timeOffset) {
                  return Expanded(
                    child: Row(
                      children: List.generate(5, (day) {
                        var dayData = timetable[weekdays[day]];
                        var timeData = dayData != null && dayData.length > timeOffset ? dayData[timeOffset] : null;

                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.all(1.0),
                            color: timeOffset % 2 == 0 ? const Color(0xFF29ADB2) : const Color(0xFF0766AD),
                            child: Stack(
                              children: [
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  child: Text(
                                    "${8 + timeOffset}:00",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        timeData?["name"] ?? "No Data",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        timeData?["room"] ?? "No Room",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
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
