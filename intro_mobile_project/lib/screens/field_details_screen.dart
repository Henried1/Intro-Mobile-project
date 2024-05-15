import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intro_mobile_project/screens/booking_screen.dart';

class FieldDetailScreen extends StatelessWidget {
  final String fieldName;
  final String fieldImage;
  final String fieldLocation;

  const FieldDetailScreen({
    super.key,
    required this.fieldName,
    required this.fieldImage,
    required this.fieldLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(fieldImage, fit: BoxFit.cover),
          ),
          _buildBackButton(context),
          _buildScrollableDetails(),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          clipBehavior: Clip.hardEdge,
          height: 55,
          width: 55,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              height: 55,
              width: 55,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  size: 20, color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScrollableDetails() {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 1.0,
      minChildSize: 0.6,
      builder: (context, scrollController) {
        return Container(
          clipBehavior: Clip.hardEdge,
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 245, 90, 79),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    _buildFieldName(),
                    _buildFieldLocation(),
                  ],
                ),
              ),
              _buildBookingButton(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFieldName() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        'Field: $fieldName',
        style: const TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }

  Widget _buildFieldLocation() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        'Field location: $fieldLocation',
        style: const TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }

  Widget _buildBookingButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookingPage(
                  fieldName: fieldName, fieldLocation: fieldLocation),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.redAccent,
          backgroundColor: Colors.white,
        ),
        child: const Text('Book a field'),
      ),
    );
  }
}
