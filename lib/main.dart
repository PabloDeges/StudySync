import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'week.dart';
import 'day.dart';
import 'editor.dart';

void main() async {
  await dotenv.load(fileName: ".env");
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
  bool showWeekView = true;
  Widget _getSelectedView() {
    if (_selectedIndex == 0) {
      return showWeekView ? const WeekView() : const DayView();
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
      resizeToAvoidBottomInset:
          false, // SEHR WICHTIG - Ohne diese Zeile schiebt die Tastatur die gesamte App nach oben und verursacht overflows
      body: SafeArea(
        child: _getSelectedView(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_view_week,
                  color: _selectedIndex == 0
                      ? (showWeekView ? const Color(0xFF0766AD) : Colors.grey)
                      : Colors.grey,
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.today,
                  color: _selectedIndex == 0
                      ? (showWeekView ? Colors.grey : const Color(0xFF0766AD))
                      : Colors.grey,
                ),
              ],
            ),
            label: _selectedIndex == 0
                ? (showWeekView ? 'Week' : 'Day')
                : 'Week/Day',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: 'Editor',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF0766AD),
        unselectedItemColor: Colors.grey,
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
