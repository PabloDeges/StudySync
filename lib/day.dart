import 'dart:convert';
import 'package:flutter/material.dart';

String dummyJsonDataString = '''
  {
    "timetable": {
      "Monday": [
        { "name": "MI1", "fullname": "Mathematik für Informatiker 1","room": "C0-07" },
        { "name": "MI1","fullname": "Mathematik für Informatiker 1", "room": "C0-07" },
        { "name": "ENG","fullname": "Englisch für Informatiker", "room": "C5-06" },
        { "name": "ENG","fullname": "Englisch für Informatiker", "room": "C5-06" },
        { "name": "", "fullname": "", "room": "" },
        { "name": "","fullname": "", "room": "" },
        { "name": "JP2","fullname": "Java Programmierung 2", "room": "C0-08" },
        { "name": "JP2","fullname": "Java Programmierung 2", "room": "C0-08" },
        { "name": "JP2","fullname": "Java Programmierung 2", "room": "C0-08" },
        { "name": "JP2","fullname": "Java Programmierung 2", "room": "C0-08" },
        { "name": "","fullname": "", "room": "" },
        { "name": "PY1","fullname": "Programmieren in Python 1", "room": "C6-08" },
        { "name": "PY1","fullname": "Programmieren in Python 1", "room": "C6-08" }
      ],
      "Tuesday": [
        { "name": "", "room": "" },
        { "name": "", "room": "" },
        { "name": "", "room": "" },
        { "name": "", "room": "" },
        { "name": "", "room": "" },
        { "name": "WT2", "room": "C6-07" },
        { "name": "WT2", "room": "C6-07" },
        { "name": "WT2", "room": "C6-07" },
        { "name": "", "room": "" },
        { "name": "JP1", "room": "C0-08" },
        { "name": "JP1", "room": "C0-08" },
        { "name": "", "room": "" },
        { "name": "", "room": "" }
      ],
      "Wednesday": [
        { "name": "RV", "room": "D3-13" },
        { "name": "RV", "room": "D3-13" },
        { "name": "", "room": "" },
        { "name": "", "room": "" },
        { "name": "", "room": "" },
        { "name": "", "room": "" },
        { "name": "", "room": "" },
        { "name": "SK1", "room": "D3-13" },
        { "name": "SK1", "room": "D3-13" },
        { "name": "", "room": "" },
        { "name": "", "room": "" },
        { "name": "", "room": "" },
        { "name": "", "room": "" }
      ],
      "Thursday": [
        { "name": "", "room": "" },
        { "name": "", "room": "" },
        { "name": "ENG", "room": "C5-06" },
        { "name": "ENG", "room": "C5-06" },
        { "name": "", "room": "" },
        { "name": "", "room": "" },
        { "name": "JP2", "room": "C0-08" },
        { "name": "JP2", "room": "C0-08" },
        { "name": "", "room": "" },
        { "name": "", "room": "" },
        { "name": "", "room": "" },
        { "name": "PY2", "room": "C5-08" },
        { "name": "PY2", "room": "C5-08" }
      ],
      "Friday": [
        { "name": "", "room": "" },
        { "name": "", "room": "" },
        { "name": "", "room": "" },
        { "name": "", "room": "" },
        { "name": "", "room": "" },
        { "name": "", "room": "" },
        { "name": "", "room": "" },
        { "name": "", "room": "" },
        { "name": "", "room": "" },
        { "name": "", "room": "" },
        { "name": "", "room": "" },
        { "name": "", "room": "" },
        { "name": "", "room": "" }
      ]
    }
  }
  ''';

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
    return Row(
      children: List.generate(1, (index) {
        return Expanded(
          child: Container(
            padding: const EdgeInsets.all(4.0),
            color: Colors.blue,
            child: Center(
              child: Text(
                ['MO'][index],
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class DayStudySync extends StatelessWidget {
  const DayStudySync({super.key});

  @override
  Widget build(BuildContext context) {
    var stundenplan = jsonDecode(dummyJsonDataString);
    stundenplan = stundenplan["timetable"];
    final double cellHeight =
        (MediaQuery.of(context).size.height - kBottomNavigationBarHeight - 64) /
            13;
    return Column(
      children: List.generate(13, (timeOffset) {
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
                    ("${8 + timeOffset}:00"),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                ),
                Center(
                  child: Column(children: [
                    Text(
                      stundenplan["Monday"][timeOffset]["fullname"],
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      stundenplan["Monday"][timeOffset]["room"],
                      style: TextStyle(
                        color: Colors.grey[800],
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
  }
}
