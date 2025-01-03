import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String? id;
  final String title;
  final String description;
  final DateTime date;
  final double? fuelNeeded;
  final String userId;

  Event({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    this.fuelNeeded,
    required this.userId,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String,
      date: (json['date'] is DateTime)
          ? json['date'] as DateTime
          : DateTime.parse(json['date'].toString()),
      fuelNeeded: json['fuel_needed'] != null
          ? (json['fuel_needed'] as num).toDouble()
          : null,
      userId: json['user_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'fuel_needed': fuelNeeded,
      'user_id': userId,
      'created_at': FieldValue.serverTimestamp(),
    };
  }

  @override
  String toString() {
    return '''
Event:
  ID: $id
  Title: $title
  Description: $description
  Date: ${date.toIso8601String()}
  Fuel Needed: ${fuelNeeded?.toStringAsFixed(2) ?? 'N/A'}
  User ID: $userId
''';
  }
}
