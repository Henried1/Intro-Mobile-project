import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intro_mobile_project/screens/home_screen.dart';
import 'package:intro_mobile_project/service/database.dart';
import 'package:table_calendar/table_calendar.dart';

class BookingPage extends StatefulWidget {
  final String fieldName;
  final String fieldLocation;

  BookingPage({required this.fieldName, this.fieldLocation = ""});

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  String? userEmail = FirebaseAuth.instance.currentUser?.email;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _currentDay = DateTime.now();
  int? _currentIndex;
  bool _isWeekend = false;
  bool _dateSelected = false;
  bool _timeSelected = false;
  int _selectedPlayers = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking a field'),
        backgroundColor: Color.fromARGB(255, 245, 90, 79),
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: Column(
                    children: <Widget>[
                      _buildCalendar(),
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 25),
                        child: Center(
                          child: Text(
                            'Select a time slot',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      DateTime baseTime = DateTime(_focusedDay.year,
                          _focusedDay.month, _focusedDay.day, 10, 0);
                      DateTime slotTime =
                          baseTime.add(Duration(minutes: 90 * index));

                      // Format the time as HH:mm
                      String timeText =
                          '${slotTime.hour.toString().padLeft(2, '0')}:${slotTime.minute.toString().padLeft(2, '0')}';

                      bool isPast = slotTime.isBefore(DateTime.now());

                      return InkWell(
                        splashColor: Colors.transparent,
                        onTap: isPast
                            ? null
                            : () {
                                setState(() {
                                  _currentIndex = index;
                                  _timeSelected = true;
                                });
                              },
                        child: Container(
                          margin: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _currentIndex == index
                                  ? Colors.white
                                  : Color.fromARGB(255, 245, 90, 79),
                            ),
                            borderRadius: BorderRadius.circular(15),
                            color: _currentIndex == index
                                ? Color.fromARGB(255, 245, 90, 79)
                                : (isPast ? Colors.grey : null),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            timeText,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _currentIndex == index || isPast
                                  ? Colors.white
                                  : null,
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: 9, // 9 intervals from 10:00 to 22:30
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 1.5,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    children: <Widget>[
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Center(
                          child: Text(
                            'Select players',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 50, // Adjust this value as needed
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownButton<int>(
                            value: _selectedPlayers,
                            items: <int>[2, 3, 4].map((int value) {
                              return DropdownMenuItem<int>(
                                value: value,
                                child: Text('$value players'),
                              );
                            }).toList(),
                            onChanged: (int? newValue) {
                              setState(() {
                                _selectedPlayers = newValue!;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          FloatingActionButton.extended(
            onPressed: () {
              if (_dateSelected && _timeSelected) {
                DateTime baseTime = DateTime(_focusedDay.year,
                    _focusedDay.month, _focusedDay.day, 10, 0);
                DateTime bookingDateTime =
                    baseTime.add(Duration(minutes: 90 * _currentIndex!));

                if (bookingDateTime.isBefore(DateTime.now())) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Error"),
                        content: Text("Cannot select a time in the past."),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("OK"),
                          ),
                        ],
                      );
                    },
                  );
                  return;
                }

                if (userEmail != null) {
                  FirestoreService()
                      .addBooking(userEmail!, bookingDateTime, _selectedPlayers,
                          widget.fieldName, widget.fieldLocation)
                      .then((_) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Success"),
                          content: Text("Your booking was successful."),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => HomeScreen()),
                                  (route) => false,
                                );
                              },
                              child: Text("OK"),
                            ),
                          ],
                        );
                      },
                    );
                  });
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Error"),
                        content: Text("User email is null."),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("OK"),
                          ),
                        ],
                      );
                    },
                  );
                }
              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Error"),
                      content: Text("Please select both date and time."),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text("OK"),
                        ),
                      ],
                    );
                  },
                );
              }
            },
            label: Text('Book now'),
            icon: Icon(Icons.book),
            backgroundColor: Color.fromARGB(255, 245, 90, 79),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      focusedDay: _focusedDay,
      firstDay: DateTime.now(),
      lastDay: DateTime(2026, 12, 31),
      calendarFormat: _calendarFormat,
      currentDay: _currentDay,
      rowHeight: 48,
      calendarStyle: const CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Color.fromARGB(255, 245, 90, 79),
          shape: BoxShape.circle,
        ),
      ),
      availableCalendarFormats: const {
        CalendarFormat.month: 'Month',
      },
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _currentDay = selectedDay;
          _focusedDay = focusedDay;
          _dateSelected = true;
          if (selectedDay.weekday == 6 || selectedDay.weekday == 7) {
            _isWeekend = true;
            _timeSelected = false;
            _currentIndex = null;
          } else {
            _isWeekend = false;
          }
        });
      },
    );
  }
}
