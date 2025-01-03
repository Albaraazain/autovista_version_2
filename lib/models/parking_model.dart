class Parking {
  final double latitude;
  final double longitude;
  final String timestamp;
  final String userId;
  final Map<String, dynamic>? photoData;

  Parking({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.userId,
    this.photoData,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp,
      'user_id': userId,
      'photo_data': photoData,
    };
  }

  factory Parking.fromJson(Map<String, dynamic> json) {
    return Parking(
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      timestamp: json['timestamp'],
      userId: json['user_id'],
      photoData: json['photo_data'],
    );
  }
}
