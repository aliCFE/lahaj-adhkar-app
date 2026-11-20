import 'package:flutter/material.dart';

IconData iconForName(String name) {
  switch (name) {
    case 'wb_sunny':
      return Icons.wb_sunny_rounded;
    case 'bedtime':
      return Icons.bedtime_rounded;
    case 'home':
      return Icons.home_rounded;
    case 'mosque':
      return Icons.mosque_rounded;
    case 'flight':
      return Icons.flight_rounded;
    case 'shield':
      return Icons.shield_rounded;
    case 'self_improvement':
      return Icons.self_improvement_rounded;
    case 'favorite':
      return Icons.favorite_rounded;
    case 'healing':
      return Icons.healing_rounded;
    case 'people':
      return Icons.people_alt_rounded;
    case 'celebration':
      return Icons.celebration_rounded;
    case 'cloud':
      return Icons.cloud_rounded;
    case 'park':
      return Icons.park_rounded;
    case 'nights_stay':
      return Icons.nights_stay_rounded;
    case 'terrain':
      return Icons.terrain_rounded;
    case 'kaaba':
      return Icons.mosque_rounded;
    case 'umrah':
      return Icons.directions_walk_rounded;
    case 'moon':
      return Icons.nightlight_round;
    case 'book':
      return Icons.menu_book_rounded;
    case 'gavel':
      return Icons.gavel_rounded;
    case 'work':
      return Icons.work_rounded;
    case 'school':
      return Icons.school_rounded;
    default:
      return Icons.menu_book_rounded;
  }
}
