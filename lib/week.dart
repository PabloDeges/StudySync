import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeekView extends StatefulWidget {
  const WeekView({super.key});

  @override
  // ignore: library_private_types_in_public_apiF
  _WeekViewState createState() => _WeekViewState();
}

class _WeekViewState extends State<WeekView> {
  late Future<Map<String, dynamic>> _weekJsonMap;

  Future<Map<String, dynamic>> fetchWeek() async {
    try {
      var url = Uri.http('10.0.2.2:3000'); // oder 127.0.0.1:3000
      var response = await http.get(url);
      if (response.statusCode == 200) {
        final decResponse = jsonDecode(response.body) as Map<String, dynamic>;
        return decResponse;
      } else {
        throw Error();
      }
    } catch (error) {
      throw Error();
    }
  }

  @override
  void initState() {
    super.initState();
    _weekJsonMap = fetchWeek();
  }

  @override
  Widget build(BuildContext context) {
    final double cellHeight =
        (MediaQuery.of(context).size.height - kBottomNavigationBarHeight - 80) /
            13;

    final List weekdays = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday"
    ];
    return FutureBuilder<Map<String, dynamic>>(
      future: _weekJsonMap,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
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
          }
          if (snapshot.hasData && snapshot.data != null) {
            final timetable = snapshot.data!['timetable'];

            return Column(
              children: [
                const WeekdayIndicator(),
                Column(
                  children: List.generate(13, (timeOffset) {
                    return Row(
                      children: List.generate(5, (day) {
                        var dayData = timetable[weekdays[day]];
                        var timeData =
                            dayData != null && dayData.length > timeOffset
                                ? dayData[timeOffset]
                                : null;

                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.all(1.0),
                            height: cellHeight,
                            color: Colors.grey[((timeOffset % 2) * 100) + 300],
                            child: Stack(
                              children: [
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  child: Text(
                                    "${8 + timeOffset}:00",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Column(
                                    children: [
                                      Text(
                                        timeData?["name"] ?? "No Data",
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        timeData?["room"] ?? "No Room",
                                        style: TextStyle(
                                          color: Colors.grey[800],
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
                    );
                  }),
                )
              ],
            );
          }
          return const Text("Keine Daten verfügbar.");
        }
        return const CircularProgressIndicator();
      },
    );
  }
}

class WeekdayIndicator extends StatelessWidget {
  const WeekdayIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        return Expanded(
          child: Container(
            padding: const EdgeInsets.all(4.0),
            color: Colors.blue,
            child: Center(
              child: Text(
                ['MO', 'DI', 'MI', 'DO', 'FR'][index],
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
      }),
    );
  }
}
