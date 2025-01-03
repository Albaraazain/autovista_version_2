import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart' as app_user;
import '../models/car_model.dart';
import '../models/document_model.dart';
import '../models/parking_model.dart';
import '../models/event_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Authentication methods
  Future<String> registerUser(
    String name,
    String email,
    String password,
    String location, {
    String? licenseStartDate,
    int? licenseValidityMonths,
  }) async {
    try {
      // Create user in Firebase Auth
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'location': location,
        'license_start_date': licenseStartDate,
        'license_validity_months': licenseValidityMonths,
        'created_at': FieldValue.serverTimestamp(),
      });

      return userCredential.user!.uid;
    } catch (e) {
      throw Exception('Failed to register user: $e');
    }
  }

  Future<String> loginUser(String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user!.uid;
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Car management methods
  Future<void> registerCar(String userId, Car car) async {
    try {
      await _firestore.collection('users').doc(userId).collection('cars').add({
        'brand': car.brand,
        'model': car.model,
        'engine_type': car.engineType,
        'mileage': car.mileage,
        'region': car.region,
        'make_year': car.makeYear,
        'engine_capacity': car.engineCapacity,
        'license_start_date': car.licenseStartDate,
        'license_validity_months': car.licenseValidityMonths,
        'insurance_start_date': car.insuranceStartDate,
        'insurance_validity_months': car.insuranceValidityMonths,
        'last_oil_change_date': car.lastOilChangeDate,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to register car: $e');
    }
  }

  Future<List<Car>> getUserCars(String userId) async {
    try {
      final QuerySnapshot carsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cars')
          .get();

      return carsSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Car.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch cars: $e');
    }
  }

  // Document management methods
  Future<void> uploadDocument(String userId, Document document) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('documents')
          .add({
        'category': document.category,
        'description': document.description,
        'file_data': document.fileData,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to upload document: $e');
    }
  }

  Future<List<Document>> getUserDocuments(String userId) async {
    try {
      final QuerySnapshot documentsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('documents')
          .get();

      return documentsSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Document.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch documents: $e');
    }
  }

  // User profile methods
  Future<app_user.User> getUserProfile(String userId) async {
    try {
      final DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        throw Exception('User not found');
      }

      final data = userDoc.data() as Map<String, dynamic>;
      return app_user.User.fromJson({...data, 'id': userDoc.id});
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  // Parking management methods
  Future<void> saveParking(String userId, Parking parking) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('parking')
          .add({
        'latitude': parking.latitude,
        'longitude': parking.longitude,
        'timestamp': parking.timestamp,
        'photo_data': parking.photoData,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to save parking location: $e');
    }
  }

  Future<List<Parking>> getUserParkingLocations(String userId) async {
    try {
      final QuerySnapshot parkingSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('parking')
          .orderBy('created_at', descending: true)
          .get();

      return parkingSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Parking.fromJson({...data, 'user_id': userId});
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch parking locations: $e');
    }
  }

  // Event management methods
  Future<void> createEvent(String userId, Event event) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('events')
          .add(event.toJson());
    } catch (e) {
      throw Exception('Failed to create event: $e');
    }
  }

  Future<List<Event>> getUserEvents(String userId) async {
    try {
      final QuerySnapshot eventsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('events')
          .orderBy('date', descending: false)
          .get();

      return eventsSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Event.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch events: $e');
    }
  }

  Future<void> updateEvent(String userId, Event event) async {
    try {
      if (event.id == null) {
        throw Exception('Event ID is required for update');
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('events')
          .doc(event.id)
          .update(event.toJson());
    } catch (e) {
      throw Exception('Failed to update event: $e');
    }
  }

  Future<void> deleteEvent(String userId, String eventId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('events')
          .doc(eventId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }
}
