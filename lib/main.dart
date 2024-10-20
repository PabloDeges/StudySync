import 'package:flutter/material.dart';
import 'week.dart';
import 'day.dart';
import 'editor.dart';

void main() {
  runApp(const StudySyncApp());
}

class StudySyncApp extends StatelessWidget {
  const StudySyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudySync App',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      home: const StudySyncHomePage(),
    );
  }
}

class StudySyncHomePage extends StatefulWidget {
  const StudySyncHomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _StudySyncHomePageState createState() => _StudySyncHomePageState();
}

class _StudySyncHomePageState extends State<StudySyncHomePage> {
  int _selectedIndex = 0;
  bool showWeekView = false;
  Widget _getSelectedView() {
    if (_selectedIndex == 0) {
      return showWeekView ? const DayView() : const WeekView();
    } else {
      return const EditorView();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      if (index == 0) {
        _selectedIndex = index;
      } else if (index == 1) {
        _selectedIndex = index;
      }
    });
  }

  void _toggleWeekDay() {
    setState(() {
      showWeekView = !showWeekView;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _getSelectedView(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(showWeekView ? Icons.calendar_view_week : Icons.today),
            label: showWeekView ? 'Week' : 'Day',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: 'Editor',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.lightBlue[800],
        onTap: (index) {
          if (index == 0 && _selectedIndex == 0) {
            _toggleWeekDay();
          }
          _onItemTapped(index);
        },
      ),
    );
  }
}
