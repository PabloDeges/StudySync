import 'package:flutter/material.dart';

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
      body: _widgetOptions.elementAt(_selectedIndex),
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
        WeekdayIndicator(),
        Expanded(child: DayStudySync()),
      ],
    );
  }
}

class EditorView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Editor View'),
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
            padding: EdgeInsets.all(8.0),
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

class StudySyncGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Calculate the height of each cell based on the screen height
    final double cellHeight =
        (MediaQuery.of(context).size.height - kBottomNavigationBarHeight - 64) /
            13;

    return Column(
      children: List.generate(13, (row) {
        return Row(
          children: List.generate(5, (col) {
            return Expanded(
              child: Container(
                margin: EdgeInsets.all(1.0),
                height: cellHeight,
                color: Colors.grey[300],
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
      children: List.generate(13, (index) {
        return Container(
          margin: EdgeInsets.all(1.0),
          height: cellHeight,
          color: Colors.grey[300],
        );
      }),
    );
  }
}
