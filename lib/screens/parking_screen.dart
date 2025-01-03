import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/firebase_service.dart';
import '../models/parking_model.dart';

class ParkingScreen extends StatelessWidget {
  final String userId;
  final FirebaseService _firebaseService = FirebaseService();

  ParkingScreen({super.key, required this.userId});

  Future<void> saveParking(BuildContext context) async {
    File? selectedImage;

    final addPicture = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Picture"),
          content: const Text(
              "Would you like to add a picture of the parking location?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );

    if (addPicture == true) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        selectedImage = File(pickedFile.path);
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      String currentDate = DateTime.now().toIso8601String().split('T').first;

      final parking = Parking(
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: currentDate,
        userId: userId,
        photoData:
            selectedImage != null ? {"file_path": selectedImage.path} : null,
      );

      await _firebaseService.saveParking(userId, parking);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Your parking location has been saved!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error saving parking: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Save Parking Location"),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Save Your Parking Location",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                  shadows: [
                    Shadow(
                        blurRadius: 10,
                        color: Colors.black26,
                        offset: Offset(2, 2)),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => saveParking(context),
                icon: const Icon(Icons.location_on, size: 40),
                label: const Text(
                  "Save Current Location",
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(300, 80),
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
