import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../models/car_model.dart';
import 'package:logger/logger.dart';

class HomeScreen extends StatefulWidget {
  final String userId;

  const HomeScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );
  late Future<List<Car>> _carsFuture;

  @override
  void initState() {
    super.initState();
    _refreshCars();
  }

  Future<void> _refreshCars() async {
    logger.i('Refreshing cars for user: ${widget.userId}');
    setState(() {
      _carsFuture = _supabaseService.getUserCars(widget.userId);
    });
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

  Widget _buildVehicleInfoButton() {
    return Column(
      children: [
        IconButton(
          icon: const Icon(Icons.info, size: 40, color: Colors.teal),
          tooltip: "View Vehicle Info",
          onPressed: () async {
            try {
              logger.i('Fetching cars for vehicle info display');
              final cars = await _carsFuture;
              logger.d('Found ${cars.length} cars');

              if (!mounted) return;

              if (cars.isNotEmpty) {
                logger.i(
                    'Displaying info for car: ${cars.first.brand} ${cars.first.model}');
                Navigator.pushNamed(
                  context,
                  '/added_vehicle_screen',
                  arguments: cars.first.toJson(),
                );
              } else {
                logger.w('No vehicles found for user');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text("No vehicles found. Please add a vehicle first."),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            } catch (e) {
              logger.e('Error displaying vehicle info: $e');
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error loading vehicle info: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
        const Text("Vehicle Info"),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshCars,
            tooltip: "Refresh vehicle data",
          ),
        ],
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
                          Navigator.pushNamed(
                            context,
                            '/eventManager',
                            arguments: widget.userId,
                          );
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
                        icon: const Icon(Icons.local_parking,
                            size: 40, color: Colors.teal),
                        tooltip: "Parking",
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
                ],
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.person,
                            size: 40, color: Colors.teal),
                        tooltip: "Profile",
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/profile_screen',
                            arguments: widget.userId,
                          );
                        },
                      ),
                      const Text("Profile"),
                    ],
                  ),
                  _buildVehicleInfoButton(),
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
