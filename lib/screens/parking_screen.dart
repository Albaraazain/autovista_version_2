import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../services/supabase_service.dart';
import '../models/parking_model.dart';

class ParkingScreen extends StatefulWidget {
  final String? userId;

  const ParkingScreen({Key? key, this.userId}) : super(key: key);

  @override
  State<ParkingScreen> createState() => _ParkingScreenState();
}

class _ParkingScreenState extends State<ParkingScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  LatLng? _currentLocation;
  LatLng? _parkedLocation;
  bool _isLoading = true;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadParkedLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting location: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadParkedLocation() async {
    if (widget.userId == null) return;

    try {
      final parking = await _supabaseService.getLatestParking(widget.userId!);
      if (parking != null) {
        setState(() {
          _parkedLocation = LatLng(parking.latitude, parking.longitude);
          _photoUrl = parking.photoUrl;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading parked location: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveParkedLocation() async {
    if (widget.userId == null || _currentLocation == null) return;

    try {
      await _supabaseService.saveParking(
        widget.userId!,
        _currentLocation!.latitude,
        _currentLocation!.longitude,
      );
      setState(() {
        _parkedLocation = _currentLocation;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Parking location saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving parking location: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _clearParkedLocation() async {
    if (widget.userId == null) return;

    try {
      await _supabaseService.clearParking(widget.userId!);
      setState(() {
        _parkedLocation = null;
        _photoUrl = null;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Parking location cleared successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error clearing parking location: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parking Location'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                center: _currentLocation ?? const LatLng(0, 0),
                zoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    if (_currentLocation != null)
                      Marker(
                        point: _currentLocation!,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.blue,
                          size: 40.0,
                        ),
                        width: 40.0,
                        height: 40.0,
                      ),
                    if (_parkedLocation != null)
                      Marker(
                        point: _parkedLocation!,
                        child: const Icon(
                          Icons.local_parking,
                          color: Colors.red,
                          size: 40.0,
                        ),
                        width: 40.0,
                        height: 40.0,
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (_photoUrl != null)
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(_photoUrl!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _saveParkedLocation,
                  child: const Text('Save Location'),
                ),
                if (_parkedLocation != null)
                  ElevatedButton(
                    onPressed: _clearParkedLocation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Clear Location'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
