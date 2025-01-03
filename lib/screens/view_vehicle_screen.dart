import 'package:flutter/material.dart';
import 'package:autovista/services/firebase_service.dart';
import '../models/car_model.dart';

class ViewVehicleScreen extends StatefulWidget {
  final Map<String, dynamic>? vehicleData;
  final String? carId;
  final String userId;

  const ViewVehicleScreen({
    super.key,
    this.vehicleData,
    this.carId,
    required this.userId,
  });

  @override
  State<ViewVehicleScreen> createState() => _ViewVehicleScreenState();
}

class _ViewVehicleScreenState extends State<ViewVehicleScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for required fields
  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _engineTypeController;
  late TextEditingController _mileageController;
  late TextEditingController _regionController;
  late TextEditingController _makeYearController;

  // Controllers for optional fields
  late TextEditingController _engineCapacityController;
  late TextEditingController _licenseStartDateController;
  late TextEditingController _licenseValidityMonthsController;
  late TextEditingController _insuranceStartDateController;
  late TextEditingController _insuranceValidityMonthsController;
  late TextEditingController _lastOilChangeDateController;

  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();

    // Initialize controllers with default or provided data
    _brandController =
        TextEditingController(text: widget.vehicleData?['brand'] ?? '');
    _modelController =
        TextEditingController(text: widget.vehicleData?['model'] ?? '');
    _engineTypeController =
        TextEditingController(text: widget.vehicleData?['engine_type'] ?? '');
    _mileageController = TextEditingController(
        text: widget.vehicleData?['mileage']?.toString() ?? '');
    _regionController =
        TextEditingController(text: widget.vehicleData?['region'] ?? '');
    _makeYearController = TextEditingController(
        text: widget.vehicleData?['make_year']?.toString() ?? '');

    // Optional fields
    _engineCapacityController = TextEditingController(
        text: widget.vehicleData?['engine_capacity']?.toString() ?? '');
    _licenseStartDateController = TextEditingController(
        text: widget.vehicleData?['license_start_date'] ?? '');
    _licenseValidityMonthsController = TextEditingController(
        text: widget.vehicleData?['license_validity_months']?.toString() ?? '');
    _insuranceStartDateController = TextEditingController(
        text: widget.vehicleData?['insurance_start_date'] ?? '');
    _insuranceValidityMonthsController = TextEditingController(
        text:
            widget.vehicleData?['insurance_validity_months']?.toString() ?? '');
    _lastOilChangeDateController = TextEditingController(
        text: widget.vehicleData?['last_oil_change_date'] ?? '');
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _engineTypeController.dispose();
    _mileageController.dispose();
    _regionController.dispose();
    _makeYearController.dispose();

    _engineCapacityController.dispose();
    _licenseStartDateController.dispose();
    _licenseValidityMonthsController.dispose();
    _insuranceStartDateController.dispose();
    _insuranceValidityMonthsController.dispose();
    _lastOilChangeDateController.dispose();

    super.dispose();
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = picked.toIso8601String().split('T').first;
    }
  }

  void _saveVehicleInfo() async {
    if (_formKey.currentState!.validate()) {
      final car = Car(
        brand: _brandController.text,
        model: _modelController.text,
        engineType: _engineTypeController.text,
        mileage: double.tryParse(_mileageController.text) ?? 0,
        region: _regionController.text,
        makeYear: int.tryParse(_makeYearController.text) ?? 0,
        engineCapacity: double.tryParse(_engineCapacityController.text),
        licenseStartDate: _licenseStartDateController.text.isNotEmpty
            ? _licenseStartDateController.text
            : null,
        licenseValidityMonths:
            int.tryParse(_licenseValidityMonthsController.text),
        insuranceStartDate: _insuranceStartDateController.text.isNotEmpty
            ? _insuranceStartDateController.text
            : null,
        insuranceValidityMonths:
            int.tryParse(_insuranceValidityMonthsController.text),
        lastOilChangeDate: _lastOilChangeDateController.text.isNotEmpty
            ? _lastOilChangeDateController.text
            : null,
      );

      try {
        await _firebaseService.registerCar(widget.userId, car);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Vehicle info saved successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error saving vehicle: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("View/Edit Vehicle Info")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(labelText: "Brand"),
                validator: (value) => value == null || value.isEmpty
                    ? "Please enter the brand"
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(labelText: "Model"),
                validator: (value) => value == null || value.isEmpty
                    ? "Please enter the model"
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _engineTypeController,
                decoration: const InputDecoration(labelText: "Engine Type"),
                validator: (value) => value == null || value.isEmpty
                    ? "Please enter the engine type"
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _mileageController,
                decoration: const InputDecoration(labelText: "Mileage (km)"),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty
                    ? "Please enter the mileage"
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _regionController,
                decoration: const InputDecoration(labelText: "Region"),
                validator: (value) => value == null || value.isEmpty
                    ? "Please enter the region"
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _makeYearController,
                decoration: const InputDecoration(labelText: "Make Year"),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty
                    ? "Please enter the make year"
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _engineCapacityController,
                decoration:
                    const InputDecoration(labelText: "Engine Capacity (L)"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _selectDate(context, _licenseStartDateController),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _licenseStartDateController,
                    decoration: const InputDecoration(
                        labelText: "License Start Date (YYYY-MM-DD)"),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _licenseValidityMonthsController,
                decoration: const InputDecoration(
                    labelText: "License Validity (Months)"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () =>
                    _selectDate(context, _insuranceStartDateController),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _insuranceStartDateController,
                    decoration: const InputDecoration(
                        labelText: "Insurance Start Date (YYYY-MM-DD)"),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _insuranceValidityMonthsController,
                decoration: const InputDecoration(
                    labelText: "Insurance Validity (Months)"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _selectDate(context, _lastOilChangeDateController),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _lastOilChangeDateController,
                    decoration: const InputDecoration(
                        labelText: "Last Oil Change Date (YYYY-MM-DD)"),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveVehicleInfo,
                child: const Text("Save Vehicle Info"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
