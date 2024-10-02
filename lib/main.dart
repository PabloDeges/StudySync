import 'dart:ffi';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

void main() {
  runApp(StudySyncApp());
}

//temporär, wenn backend feststeht als Object umsetzen

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

// final dataJson = json.decode(dummyJsonDataString) as Map<String, dynamic>;

class StudySyncApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudySync App',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      home: StudySyncHomePage(),
    );
  }
}

class StudySyncHomePage extends StatefulWidget {
  @override
  _StudySyncHomePageState createState() => _StudySyncHomePageState();
}

class _StudySyncHomePageState extends State<StudySyncHomePage> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    WeekView(),
    DayView(),
    EditorView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_view_week),
            label: 'Week',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.today),
            label: 'Day',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: 'Editor',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.lightBlue[800],
        onTap: _onItemTapped,
      ),
    );
  }
}

class WeekView extends StatefulWidget {
  @override
  _WeekViewState createState() => _WeekViewState();
}

class _WeekViewState extends State<WeekView> {
  late Future<Map<String, dynamic>> weekJsonMap; // dynamic value

  Future<Map<String, dynamic>> fetchWeek() async {
    var url = Uri.http('10.0.2.2:3000');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      final dec_response =
          jsonDecode(jsonDecode(response.body)) as Map<String, dynamic>;
      return dec_response;
    } else {
      throw Error();
    }
  }

  @override
  void initState() {
    super.initState();
    weekJsonMap = fetchWeek();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the height of each cell based on the screen height
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
      future: weekJsonMap,
      builder: (context, snapshot) {
        if ((snapshot.connectionState == ConnectionState.done)) {
          if (snapshot.hasError) {
            return Column(
              children: [
                WeekdayIndicator(),
                Column(
                  children: List.generate(13, (timeOffset) {
                    return Row(
                      children: List.generate(5, (day) {
                        return Expanded(
                          child: Container(
                            margin: EdgeInsets.all(1.0),
                            height: cellHeight,
                            color: Colors.grey[((timeOffset % 2) * 100) + 300],
                            child: Stack(
                              children: [
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  child: Text(
                                    ((8 + timeOffset).toString() + ":00"),
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Column(children: [
                                    Text(
                                      "ERR",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "---",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 10,
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
                  }),
                )
              ],
            );
          } else {
            return Column(
              children: [
                WeekdayIndicator(),
                Column(
                  children: List.generate(13, (timeOffset) {
                    return Row(
                      children: List.generate(5, (day) {
                        return Expanded(
                          child: Container(
                            margin: EdgeInsets.all(1.0),
                            height: cellHeight,
                            color: Colors.grey[((timeOffset % 2) * 100) + 300],
                            child: Stack(
                              children: [
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  child: Text(
                                    ((8 + timeOffset).toString() + ":00"),
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Column(children: [
                                    Text(
                                      snapshot.data?[weekdays[day]][timeOffset]
                                          ["name"],
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      snapshot.data?[weekdays[day]][timeOffset]
                                          ["room"],
                                      style: TextStyle(
                                        color: Colors.grey[800],
                                        fontSize: 10,
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
                  }),
                )
              ],
            );
          }
        } else {
          // By default, show a loading spinner.
          return const CircularProgressIndicator();
        }
      },
    );
  }
}

class DayView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FocussedWeekdayIndicator(),
        Expanded(child: DayStudySync()),
      ],
    );
  }
}

class EditorView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("//coming soon"),
    );
  }
}

class WeekdayIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        return Expanded(
          child: Container(
            padding: EdgeInsets.all(4.0),
            color: Colors.blue,
            child: Center(
              child: Text(
                ['MO', 'DI', 'MI', 'DO', 'FR'][index],
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class FocussedWeekdayIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(1, (index) {
        return Expanded(
          child: Container(
            padding: EdgeInsets.all(4.0),
            color: Colors.blue,
            child: Center(
              child: Text(
                ['MO'][index], // make dynamic based on current day
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class DayStudySync extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var stundenplan = jsonDecode(dummyJsonDataString);
    stundenplan = stundenplan["timetable"];
    // Calculate the height of each cell based on the screen height
    final double cellHeight =
        (MediaQuery.of(context).size.height - kBottomNavigationBarHeight - 64) /
            13;
    return Column(
      children: List.generate(13, (timeOffset) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.all(1.0),
            height: cellHeight,
            color: Colors.grey[((timeOffset % 2) * 100) + 300],
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  child: Text(
                    ((8 + timeOffset).toString() + ":00"),
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                ),
                Center(
                  child: Column(children: [
                    Text(
                      stundenplan["Monday"][timeOffset]["fullname"],
                      style: TextStyle(
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
