class CollectionSchedule {
  final String location;
  final DateTime collectionDate;

  CollectionSchedule({required this.location, required this.collectionDate});

  factory CollectionSchedule.fromJson(Map<String, dynamic> json) {
    return CollectionSchedule(
      location: json['location'],
      collectionDate: DateTime.parse(json['collection_date']),
    );
  }
}
