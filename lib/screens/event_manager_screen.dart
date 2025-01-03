import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/firebase_service.dart';
import '../models/event_model.dart';
import './select_location_screen.dart';

class CalendarFuelScreen extends StatefulWidget {
  final String? userId;

  const CalendarFuelScreen({super.key, this.userId});

  @override
  _CalendarFuelScreenState createState() => _CalendarFuelScreenState();
}

class _CalendarFuelScreenState extends State<CalendarFuelScreen> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Event>> _events = {};
  final FirebaseService _firebaseService = FirebaseService();

  String _selectedEventType = "Trip";
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _fuelLevelController = TextEditingController();
  LatLng? _startLocation;
  LatLng? _endLocation;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    if (widget.userId == null) return;

    try {
      final events = await _firebaseService.getUserEvents(widget.userId!);
      setState(() {
        _events = {};
        for (var event in events) {
          final date = DateTime(
            event.date.year,
            event.date.month,
            event.date.day,
          );
          if (_events[date] == null) _events[date] = [];
          _events[date]!.add(event);
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error loading events: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _fuelLevelController.dispose();
    super.dispose();
  }

  void _showAddEventDialog() {
    if (widget.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please log in to add events"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _startLocation = null;
    _endLocation = null;
    _fuelLevelController.clear();
    _descriptionController.clear();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Add Event",
              style: TextStyle(color: Colors.teal, fontSize: 20)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedEventType,
                  decoration: const InputDecoration(labelText: "Event Type"),
                  items: [
                    "Trip",
                    "Insurance Update",
                    "Maintenance Checkup",
                    "Others"
                  ].map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) =>
                      setState(() => _selectedEventType = value!),
                ),
                if (_selectedEventType == "Trip") ...[
                  ElevatedButton(
                    onPressed: () => _showSelectLocationScreen(setState),
                    child: const Text("Select Start & End Locations"),
                  ),
                  TextField(
                    controller: _fuelLevelController,
                    decoration:
                        const InputDecoration(labelText: "Fuel Level (0-1)"),
                    keyboardType: TextInputType.number,
                  ),
                ],
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: "Description"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.teal)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              onPressed: _saveEvent,
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveEvent() async {
    if (_selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a date first."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    String title = _selectedEventType;
    String description = _descriptionController.text;
    double? fuelNeeded;

    if (_selectedEventType == "Trip" &&
        _startLocation != null &&
        _endLocation != null) {
      double fuelLevel = double.tryParse(_fuelLevelController.text) ?? 0.0;
      double distance = _calculateDistance(_startLocation!, _endLocation!);
      double engineCapacity = 50.0; // Default engine capacity
      double averageConsumption = _getAverageConsumption(engineCapacity);
      fuelNeeded = distance * averageConsumption;
      double fuelRemaining = fuelLevel * engineCapacity;
      double additionalFuel = max(0, fuelNeeded - fuelRemaining);

      title = "Trip - ${distance.toStringAsFixed(2)} km";
      description = """
Distance: ${distance.toStringAsFixed(2)} km
Fuel Needed: ${fuelNeeded.toStringAsFixed(2)} liters
Fuel Remaining: ${fuelRemaining.toStringAsFixed(2)} liters
Additional Fuel Required: ${additionalFuel.toStringAsFixed(2)} liters
""";
    }

    final newEvent = Event(
      title: title,
      description: description,
      date: _selectedDay!,
      fuelNeeded: fuelNeeded,
      userId: widget.userId!,
    );

    try {
      await _firebaseService.createEvent(widget.userId!, newEvent);
      await _loadEvents();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Event saved successfully!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error saving event: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  double _calculateDistance(LatLng start, LatLng end) {
    const double R = 6371; // Earth's radius in km
    double dLat = _degToRad(end.latitude - start.latitude);
    double dLon = _degToRad(end.longitude - start.longitude);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(start.latitude)) *
            cos(_degToRad(end.latitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _degToRad(double deg) => deg * (pi / 180);

  double _getAverageConsumption(double engineCapacity) {
    if (engineCapacity <= 1.5) return 0.05; // Small engine
    if (engineCapacity <= 2.5) return 0.067; // Medium engine
    return 0.1; // Large engine
  }

  void _showSelectLocationScreen(StateSetter dialogSetState) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SelectLocationScreen()),
    );
    if (result != null && result is List<LatLng>) {
      dialogSetState(() {
        _startLocation = result[0];
        _endLocation = result[1];
      });
    }
  }

  void _showEventDetails(List<Event> events) {
    showModalBottomSheet(
      context: context,
      builder: (_) => ListView(
        padding: const EdgeInsets.all(10),
        children: events.map((event) {
          return ListTile(
            title: Text(
              event.title,
              style: const TextStyle(
                color: Colors.teal,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(event.description),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                try {
                  await _firebaseService.deleteEvent(widget.userId!, event.id!);
                  await _loadEvents();
                  if (!mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Event deleted successfully"),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error deleting event: ${e.toString()}"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calendar & Events"),
        backgroundColor: Colors.teal,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              if (_events[selectedDay] != null) {
                _showEventDetails(_events[selectedDay]!);
              }
            },
            eventLoader: (day) => _events[day] ?? [],
          ),
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.teal, size: 50),
            onPressed: _showAddEventDialog,
          ),
        ],
      ),
    );
  }
}
