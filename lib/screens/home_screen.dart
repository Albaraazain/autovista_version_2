import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../models/car_model.dart';

class HomeScreen extends StatefulWidget {
  final String userId;

  const HomeScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  late Future<List<Car>> _carsFuture;

  @override
  void initState() {
    super.initState();
    _carsFuture = _supabaseService.getUserCars(widget.userId);
  }

  Future<void> _signOut() async {
    try {
      await _supabaseService.signOut();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing out: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Welcome to AutoVista!",
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                "Your one-stop solution for managing your vehicles.",
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.directions_car,
                            size: 40, color: Colors.teal),
                        tooltip: "Edit Vehicle Information",
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/viewVehicle',
                            arguments: widget.userId,
                          );
                        },
                      ),
                      const Text("Vehicle"),
                    ],
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.event,
                            size: 40, color: Colors.teal),
                        tooltip: "Event Manager",
                        onPressed: () {
                          Navigator.pushNamed(context, '/eventManager');
                        },
                      ),
                      const Text("Events"),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.scanner,
                            size: 40, color: Colors.teal),
                        tooltip: "Document Scanner",
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/document_screen',
                            arguments: widget.userId,
                          );
                        },
                      ),
                      const Text("Scanner"),
                    ],
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.location_on,
                            size: 40, color: Colors.teal),
                        tooltip: "Track Parking Location",
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/parking_screen',
                            arguments: widget.userId,
                          );
                        },
                      ),
                      const Text("Parking"),
                    ],
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.info,
                            size: 40, color: Colors.teal),
                        tooltip: "View Vehicle Info",
                        onPressed: () async {
                          final cars = await _carsFuture;
                          if (cars.isNotEmpty) {
                            if (!context.mounted) return;
                            Navigator.pushNamed(
                              context,
                              '/added_vehicle_screen',
                              arguments: cars.first.toJson(),
                            );
                          } else {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    "No vehicles found. Please add a vehicle first."),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        },
                      ),
                      const Text("Vehicle Info"),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              TextButton(
                onPressed: _signOut,
                child: const Text(
                  "Log Out",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
