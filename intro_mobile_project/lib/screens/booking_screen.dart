import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intro_mobile_project/screens/home_screen.dart';
import 'package:intro_mobile_project/service/database.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color primaryColor = Color.fromARGB(255, 245, 90, 79);

class BookingPage extends StatefulWidget {
  final String fieldName;
  final String fieldLocation;

  const BookingPage(
      {super.key, required this.fieldName, this.fieldLocation = ""});

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final String? userEmail = FirebaseAuth.instance.currentUser?.email;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  int? _selectedTimeSlotIndex;
  bool _isWeekend = false;
  bool _dateSelected = false;
  bool _timeSelected = false;
  int _selectedPlayers = 2;
  bool _isPrivateMatch = false;
  List<String> _bookedSlots = [];

  @override
  void initState() {
    super.initState();
    _fetchBookedSlots();
  }

  void _fetchBookedSlots() {
    FirestoreService().getBookedSlots().listen((QuerySnapshot snapshot) {
      setState(() {
        _bookedSlots = snapshot.docs.map((doc) => doc.id).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking a field'),
        backgroundColor: primaryColor,
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
                _buildTimeSlotsGrid(),
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
                      SizedBox(
                        height: 50,
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
                      SwitchListTile(
                        title: const Text('Private Match'),
                        value: _isPrivateMatch,
                        activeColor:
                            primaryColor, // Primary color for the thumb
                        activeTrackColor: primaryColor.withOpacity(
                            0.5), // Lighter primary color for the track
                        onChanged: (bool value) {
                          setState(() {
                            _isPrivateMatch = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildBookingButton(),
          const SizedBox(height: 16),
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
      currentDay: _selectedDay,
      rowHeight: 48,
      calendarStyle: const CalendarStyle(
        todayDecoration: BoxDecoration(
          color: primaryColor,
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
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
          _dateSelected = true;
          if (selectedDay.weekday == DateTime.saturday ||
              selectedDay.weekday == DateTime.sunday) {
            _isWeekend = true;
            _timeSelected = false;
            _selectedTimeSlotIndex = null;
          } else {
            _isWeekend = false;
          }
        });
      },
    );
  }

  Widget _buildTimeSlotsGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreService().getBookedSlots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const SliverToBoxAdapter(
            child: Text('Something went wrong'),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        _bookedSlots = snapshot.data!.docs.map((doc) => doc.id).toList();
        return SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              DateTime baseTime = DateTime(
                  _focusedDay.year, _focusedDay.month, _focusedDay.day, 10, 0);
              DateTime slotTime = baseTime.add(Duration(minutes: 30 * index));
              String timeText =
                  '${slotTime.hour.toString().padLeft(2, '0')}:${slotTime.minute.toString().padLeft(2, '0')}';
              bool isPast = slotTime.isBefore(DateTime.now());
              String slotId =
                  "${slotTime.year.toString().padLeft(4, '0')}-${slotTime.month.toString().padLeft(2, '0')}-${slotTime.day.toString().padLeft(2, '0')}T${slotTime.hour.toString().padLeft(2, '0')}:${slotTime.minute.toString().padLeft(2, '0')}_$index";
              bool isBooked = _bookedSlots.contains(slotId);
              bool isGreyedOut = _selectedTimeSlotIndex != null &&
                  index >= _selectedTimeSlotIndex! &&
                  index <= _selectedTimeSlotIndex! + 2;
              return InkWell(
                splashColor: Colors.transparent,
                onTap: isPast || isGreyedOut || isBooked
                    ? null
                    : () {
                        setState(() {
                          _selectedTimeSlotIndex = index;
                          _timeSelected = true;
                        });
                      },
                child: Container(
                  margin: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _selectedTimeSlotIndex == index
                          ? Colors.white
                          : primaryColor,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    color: _selectedTimeSlotIndex == index
                        ? primaryColor
                        : (isPast || isGreyedOut || isBooked
                            ? Colors.grey
                            : null),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    timeText,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _selectedTimeSlotIndex == index ||
                              isPast ||
                              isGreyedOut ||
                              isBooked
                          ? Colors.white
                          : null,
                    ),
                  ),
                ),
              );
            },
            childCount: 20,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 1.5,
          ),
        );
      },
    );
  }

  Widget _buildBookingButton() {
    return FloatingActionButton.extended(
      onPressed: _onBookingButtonPressed,
      label: const Text('Book now'),
      icon: const Icon(Icons.book),
      backgroundColor: primaryColor,
    );
  }

  void _onBookingButtonPressed() {
    if (!_dateSelected || !_timeSelected) {
      _showErrorDialog("Please select both date and time.");
      return;
    }
    DateTime baseTime =
        DateTime(_focusedDay.year, _focusedDay.month, _focusedDay.day, 10, 0);
    DateTime bookingDateTime =
        baseTime.add(Duration(minutes: 30 * _selectedTimeSlotIndex!));
    if (bookingDateTime.isBefore(DateTime.now())) {
      _showErrorDialog("Cannot select a time in the past.");
      return;
    }
    if (userEmail == null) {
      _showErrorDialog("User email is null.");
      return;
    }
    FirestoreService()
        .addBooking(
            userEmail!,
            bookingDateTime,
            _selectedPlayers,
            widget.fieldName,
            widget.fieldLocation,
            _selectedTimeSlotIndex!,
            _isPrivateMatch)
        .then((success) {
      if (success) {
        setState(() {
          _bookedSlots.add(
              "${bookingDateTime.year.toString().padLeft(4, '0')}-${bookingDateTime.month.toString().padLeft(2, '0')}-${bookingDateTime.day.toString().padLeft(2, '0')}T${bookingDateTime.hour.toString().padLeft(2, '0')}:${bookingDateTime.minute.toString().padLeft(2, '0')}_$_selectedTimeSlotIndex");
        });
        _showSuccessDialog("Your booking was successful.");
      } else {
        _showErrorDialog("This slot is already booked.");
      }
    }).catchError((error) {
      _showErrorDialog("Failed to book the field: $error");
    });
  }

  void _showErrorDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
