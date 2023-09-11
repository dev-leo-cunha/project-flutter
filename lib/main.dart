import 'package:projeto/myApp.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class PhotoInfo {
  final int id;
  final String filePath;
  final double compassHeading;
  final double latitude;
  final double longitude;

  PhotoInfo({
    required this.id,
    required this.filePath,
    required this.compassHeading,
    required this.latitude,
    required this.longitude,
  });
}
