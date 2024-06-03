import 'dart:async';

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
  late StreamSubscription<QuerySnapshot> _bookedSlotsSubscription;

  @override
  void initState() {
    super.initState();
    _fetchBookedSlots();
  }

  void _fetchBookedSlots() {
    _bookedSlotsSubscription = FirestoreService()
        .getBookedSlots(_selectedDay)
        .listen((QuerySnapshot snapshot) {
      final bookedSlots = snapshot.docs.map((doc) => doc.id).toList();
      print("Fetched booked slots: $bookedSlots");
      if (mounted) {
        setState(() {
          _bookedSlots = bookedSlots;
        });
      }
    });
  }

  @override
  void dispose() {
    _bookedSlotsSubscription.cancel();
    super.dispose();
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
                              if (mounted) {
                                setState(() {
                                  _selectedPlayers = newValue!;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      SwitchListTile(
                        title: const Text('Private Match'),
                        value: _isPrivateMatch,
                        activeColor: primaryColor,
                        activeTrackColor: primaryColor.withOpacity(0.5),
                        onChanged: (bool value) {
                          if (mounted) {
                            setState(() {
                              _isPrivateMatch = value;
                            });
                          }
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
        if (mounted) {
          setState(() {
            _calendarFormat = format;
          });
        }
      },
      onDaySelected: (selectedDay, focusedDay) {
        if (mounted) {
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
          _fetchBookedSlots(); // Update booked slots on date change
        }
      },
    );
  }

  Widget _buildTimeSlotsGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreService().getBookedSlots(_selectedDay),
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
        print("Booked slots in stream builder: $_bookedSlots");

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
                  "${slotTime.toIso8601String()}_$index${widget.fieldName}";
              bool isBooked = _bookedSlots.contains(slotId);

              bool isGreyedOut = _selectedTimeSlotIndex != null &&
                  ((index >= _selectedTimeSlotIndex! &&
                          index < _selectedTimeSlotIndex! + 3) ||
                      _bookedSlots.any((bookedSlot) {
                        final bookedSlotParts = bookedSlot.split('_');
                        if (bookedSlotParts.length < 2) return false;
                        final bookedIndex = int.tryParse(bookedSlotParts[1]
                            .replaceAll(widget.fieldName, ''));
                        return bookedIndex != null &&
                            ((index >= bookedIndex &&
                                    index < bookedIndex + 3) ||
                                (bookedIndex < index &&
                                    index < bookedIndex + 3));
                      }));

              if (_selectedTimeSlotIndex != null &&
                  (index >= _selectedTimeSlotIndex! &&
                      index < _selectedTimeSlotIndex! + 2)) {
                isBooked = true;
              }

              print(
                  "Slot ID: $slotId, isBooked: $isBooked, isGreyedOut: $isGreyedOut");

              return InkWell(
                splashColor: Colors.transparent,
                onTap: isPast || isGreyedOut || isBooked
                    ? null
                    : () {
                        if (mounted) {
                          setState(() {
                            _selectedTimeSlotIndex = index;
                            _timeSelected = true;
                          });
                        }
                      },
                child: Container(
                  margin: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _selectedTimeSlotIndex == index
                          ? Colors.white
                          : Colors.black,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    color: _selectedTimeSlotIndex == index
                        ? primaryColor
                        : isPast || isGreyedOut || isBooked
                            ? Colors.grey
                            : Colors.white,
                  ),
                  child: Center(
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
      _showErrorDialog("User is not logged in.");
      return;
    }

    String bookingId =
        "${bookingDateTime.toIso8601String()}_$_selectedTimeSlotIndex${widget.fieldName}";

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
      if (mounted) {
        setState(() {
          if (success) {
            _bookedSlots.add(bookingId);
            _selectedTimeSlotIndex = null;
            _timeSelected = false;
          }
        });

        if (success) {
          _showSuccessDialog("Your booking was successful.");
        } else {
          _showErrorDialog("This slot is already booked.");
        }
      }
    }).catchError((error) {
      if (mounted) {
        _showErrorDialog("Failed to book the field: $error");
      }
    });
  }

  void _showErrorDialog(String message) {
    if (!mounted) return; // Check before showing dialog
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
    if (!mounted) return; // Check before showing dialog
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
