import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:table_calendar/table_calendar.dart';

class BookingPage extends StatefulWidget {
  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _currentDay = DateTime.now();
  int? _currentIndex;
  bool _isWeekend = false;
  bool _dateSelected = false;
  bool _timeSelected = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking a field'),
        backgroundColor: Color.fromARGB(255, 245, 90, 79),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Column(
              children: <Widget>[
                _buildCalendar(),
                const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 25),
                    child: Center(
                        child: Text('Select a time slot',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ))))
              ],
            ),
          ),
          SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return InkWell(
                      splashColor: Colors.transparent,
                      onTap: () {
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
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${index + 10}:00 ${index + 10 > 11 ? "PM" : "AM"}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  _currentIndex == index ? Colors.white : null,
                            ),
                          )));
                },
                childCount: 8,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, childAspectRatio: 1.5))
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Theme(
          data: Theme.of(context).copyWith(
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              foregroundColor: Colors.white, // Change text color here
            ),
          ),
          child: FloatingActionButton.extended(
            onPressed: () {},
            label: Text('Book now'),
            icon: Icon(Icons.book),
            backgroundColor: Color.fromARGB(255, 245, 90, 79),
          ),
        ),
      ),
    );
  }

  //the calendar
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
              color: Color.fromARGB(255, 245, 90, 79), shape: BoxShape.circle),
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
        });
  }
}
