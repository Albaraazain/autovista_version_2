class Car {
  final String brand;
  final String model;
  final String engineType;
  final double mileage;
  final String region;
  final int makeYear;

  // Optional fields
  final double? engineCapacity; // Engine capacity in liters
  final String? licenseStartDate; // License start date in YYYY-MM-DD format
  final int? licenseValidityMonths; // License validity period in months
  final String? insuranceStartDate; // Insurance start date in YYYY-MM-DD format
  final int? insuranceValidityMonths; // Insurance validity period in months
  final String? lastOilChangeDate; // Last oil change date in YYYY-MM-DD format

  Car({
    required this.brand,
    required this.model,
    required this.engineType,
    required this.mileage,
    required this.region,
    required this.makeYear,
    this.engineCapacity,
    this.licenseStartDate,
    this.licenseValidityMonths,
    this.insuranceStartDate,
    this.insuranceValidityMonths,
    this.lastOilChangeDate,
  });

  // Factory constructor to create a Car object from JSON
  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      brand: json['brand'],
      model: json['model'],
      engineType: json['engine_type'],
      mileage: json['mileage'].toDouble(),
      region: json['region'],
      makeYear: json['make_year'],
      engineCapacity: json['engine_capacity']?.toDouble(),
      licenseStartDate: json['license_start_date'],
      licenseValidityMonths: json['license_validity_months'],
      insuranceStartDate: json['insurance_start_date'],
      insuranceValidityMonths: json['insurance_validity_months'],
      lastOilChangeDate: json['last_oil_change_date'],
    );
  }

  // Convert a Car object into a JSON-serializable Map
  Map<String, dynamic> toJson() {
    return {
      'brand': brand,
      'model': model,
      'engine_type': engineType,
      'mileage': mileage,
      'region': region,
      'make_year': makeYear,
      'engine_capacity': engineCapacity,
      'license_start_date': licenseStartDate,
      'license_validity_months': licenseValidityMonths,
      'insurance_start_date': insuranceStartDate,
      'insurance_validity_months': insuranceValidityMonths,
      'last_oil_change_date': lastOilChangeDate,
    };
  }
}
