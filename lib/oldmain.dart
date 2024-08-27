import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'WeekViewObject.dart';

void main() {
  runApp(StudySyncApp());
}

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

  // WeekViewObject _wvo = WeekViewObject();
  Map weekJsonMap = Map();

  Future<Map<String, dynamic>> fetchWeek() async {
    var url = Uri.http('10.0.2.2:3000', 'testdata');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      final dec_response =
          jsonDecode(jsonDecode(response.body)) as Map<String, dynamic>;
      // final week_obj = WeekViewObject.fromJson(dec_response);
      return dec_response;
    } else {
      throw Error();
    }
  }

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
    fetchWeek().then((value) {
      weekJsonMap = value;
    });

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

class WeekView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        WeekdayIndicator(),
        Expanded(child: StudySyncGrid()),
      ],
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
      child: Text(
          "Kommt bald! Bis dahin ist das aber super zum Loggen, Testen und Text ausgeben!"),
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

class StudySyncGrid extends StatelessWidget {
  Map weekJsonMap = Map();

  Future<Map<String, dynamic>> fetchWeek() async {
    var url = Uri.http('10.0.2.2:3000', 'testdata');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      final dec_response =
          jsonDecode(jsonDecode(response.body)) as Map<String, dynamic>;
      // final week_obj = WeekViewObject.fromJson(dec_response);
      return dec_response;
    } else {
      throw Error();
    }
  }

  @override
  Widget build(BuildContext context) {
    fetchWeek().then((value) {
      weekJsonMap = value;
    });
    // Calculate the height of each cell based on the screen height
    final double cellHeight =
        (MediaQuery.of(context).size.height - kBottomNavigationBarHeight - 80) /
            13;

    final dayArray = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'];

    return Column(
      children: List.generate(13, (timeOffset) {
        // change to 13 again
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
                        ("${8 + timeOffset}:00"),
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    Center(
                      child: Column(children: [
                        Text(
                          weekJsonMap['week']['monday']['slots']['slot_8']
                              ['class_name_short'],
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "placeholder",
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
    );
  }
}

class DayStudySync extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                      "placeholder",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "placeholder",
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
