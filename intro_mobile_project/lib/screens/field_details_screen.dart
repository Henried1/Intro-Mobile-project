import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intro_mobile_project/screens/booking_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class FieldDetailScreen extends StatelessWidget {
  final String fieldName;
  final String fieldImage;
  final String fieldLocation;
  final String fieldLocationImage;

  const FieldDetailScreen({
    super.key,
    required this.fieldName,
    required this.fieldImage,
    required this.fieldLocation,
    required this.fieldLocationImage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildTopImageSection(context),
          _buildScrollableDetails(context),
        ],
      ),
    );
  }

  Widget _buildTopImageSection(BuildContext context) {
    return InkWell(
      onTap: () async {
        final query = Uri.encodeComponent(fieldName);
        final url =
            Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not launch $url')),
          );
        }
      },
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(fieldLocationImage, fit: BoxFit.cover),
            ),
            _buildBackButton(context),
          ],
        ),
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

  Widget _buildScrollableDetails(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      maxChildSize: 1.0,
      minChildSize: 0.5,
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
                    _buildFieldLocation(context),
                    _buildOpeningHours()
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
      child: Row(
        children: [
          const Icon(Icons.sports_soccer, color: Colors.white, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              fieldName,
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLocation(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () async {
          final query = Uri.encodeComponent(fieldName);
          final url = Uri.parse(
              'https://www.google.com/maps/search/?api=1&query=$query');
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not launch $url')),
            );
          }
        },
        child: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Address: $fieldLocation',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpeningHours() {
    final openingHours = {
      'Monday': '09:30 - 20:00',
      'Tuesday': '09:30 - 20:00',
      'Wednesday': '09:30 - 20:00',
      'Thursday': '09:30 - 20:00',
      'Friday': '09:30 - 20:00',
      'Saturday': '09:30 - 20:00',
      'Sunday': '09:30 - 20:00',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: <Widget>[
              Icon(Icons.access_time, color: Colors.white),
              SizedBox(width: 8.0),
              Text(
                'Opening Hours:',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          ...openingHours.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Text(
                '${entry.key}: ${entry.value}',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          }),
        ],
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
