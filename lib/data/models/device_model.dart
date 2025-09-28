import 'package:cloud_firestore/cloud_firestore.dart';

class DeviceModel {
  final String id;
  final String name;
  final String type;
  final Timestamp firstLogin;
  final Timestamp lastLogin;

  DeviceModel({
    required this.id,
    required this.name,
    required this.type,
    required this.firstLogin,
    required this.lastLogin,
  });

  // Converts a device's data into a map for Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type,
      'firstLogin': firstLogin,
      'lastLogin': lastLogin,
    };
  }
}