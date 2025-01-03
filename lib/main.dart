import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/view_vehicle_screen.dart';
import 'screens/event_manager_screen.dart';
import 'screens/document_screen.dart'; // Import the document screen
import 'screens/parking_screen.dart'; // Import the parking screen
import 'screens/added_vehicle.dart'; // Import the added vehicle screen
import 'screens/uploadeddocuments.dart'; // Import the uploaded documents screen
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AutoVistaApp());
}

class AutoVistaApp extends StatelessWidget {
  const AutoVistaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AutoVista',
      theme: AppTheme.lightTheme,
      initialRoute: '/login',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/signup':
            return MaterialPageRoute(builder: (_) => const SignupScreen());
          case '/home':
            final userId = settings.arguments as String;
            return MaterialPageRoute(
                builder: (_) => HomeScreen(userId: userId));
          case '/profile_screen':
            final userId = settings.arguments as String;
            return MaterialPageRoute(
                builder: (_) => ProfileScreen(userId: userId));
          case '/viewVehicle':
            final userId = settings.arguments as String;
            return MaterialPageRoute(
                builder: (_) => ViewVehicleScreen(userId: userId));
          case '/eventManager':
            return MaterialPageRoute(
                builder: (_) => const CalendarFuelScreen());
          case '/document_screen':
            final userId = settings.arguments as String;
            return MaterialPageRoute(
                builder: (_) => ScanDocumentScreen(userId: userId));
          case '/parking_screen':
            final userId = settings.arguments as String;
            return MaterialPageRoute(
                builder: (_) => ParkingScreen(userId: userId));
          case '/added_vehicle_screen':
            final vehicleData = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
                builder: (_) => AddedVehicleScreen(vehicleData: vehicleData));
          case '/uploaded_documents':
            final userId = settings.arguments as String;
            return MaterialPageRoute(
                builder: (_) => ViewDocumentsScreen(userId: userId));
          default:
            return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
      },
    );
  }
}
