import 'package:flutter/material.dart';
import '../../../models/trip.dart';
import 'book_thumbnail.dart';

class TripCard extends StatelessWidget {
  final Trip trip;
  final VoidCallback onTap;

  const TripCard({super.key, required this.trip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BookThumbnail(trip: trip, onTap: onTap);
  }
}
