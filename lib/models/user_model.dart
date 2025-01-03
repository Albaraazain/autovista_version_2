class User {
  final int? id; // Nullable ID
  final String name;
  final String email;
  final String location;
  final String? licenseStartDate; // Nullable start date
  final int? licenseValidityMonths; // Nullable validity months

  User({
    this.id, // Optional
    required this.name,
    required this.email,
    required this.location,
    this.licenseStartDate,
    this.licenseValidityMonths,
  });

  // Factory constructor to create User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int?,
      name: json['name'] ?? '', // Default to empty string if null
      email: json['email'] ?? '',
      location: json['location'] ?? '',
      licenseStartDate: json['license_start_date'] as String?,
      licenseValidityMonths: json['license_validity_months'] as int?,
    );
  }

  // Convert User to JSON (useful for sending data to API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'location': location,
      'license_start_date': licenseStartDate,
      'license_validity_months': licenseValidityMonths,
    };
  }
}
