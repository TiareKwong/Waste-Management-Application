class Report {
  final String description;
  final double latitude;
  final double longitude;
  final String imageUrl;

  Report({
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
  });

  // Factory method to create a Report from JSON data
  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      description: json['description'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      imageUrl: json['image_url'],
    );  
  }

  // Method to convert a Report to JSON format
  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'image_url': imageUrl,
    };
  }
}
