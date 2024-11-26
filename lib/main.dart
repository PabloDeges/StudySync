import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:study_sync/login.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'register.dart';
import 'week.dart';
import 'day.dart';
import 'editor.dart';
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<bool> checkTokenValidity() async {
  AuthService authService = AuthService();
  String? token = await authService.getToken();

  final response = await http.get(
      Uri.http("${dotenv.env['SERVER']}:${dotenv.env['PORT']}",
          '/auth/authToken'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

  if (response.statusCode == 200) {
    return true;
  } else {
    return false;
  }
}
void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  bool isTokenValid = await checkTokenValidity();
  runApp(StudySyncApp(isTokenValid: isTokenValid));
}

class StudySyncApp extends StatelessWidget {
  final bool isTokenValid;
  const StudySyncApp({super.key, required this.isTokenValid});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'StudySync App',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      initialRoute: isTokenValid ? '/home' : '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const StudySyncHomePage(),
      },
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
