// lib/models/work_post.dart
class WorkPost {
  final String id;
  final String title;
  final String vehicle;
  final String postedBy;      // garage name (display)
  final String garageId;      // Firestore uid of the garage owner
  final double distanceKm;
  final String amount;
  final String time;
  final String category;
  final String location;
  final String? notes;
  bool isAccepted;
  final String? acceptedBy;       // uid
  final String? acceptedByName;   // name for display
  final bool isDeleted;
  final DateTime? createdAt;
  final DateTime? acceptedAt;

  WorkPost({
    required this.id,
    required this.title,
    required this.vehicle,
    required this.postedBy,
    this.garageId = '',
    required this.distanceKm,
    required this.amount,
    required this.time,
    required this.category,
    required this.location,
    this.notes,
    this.isAccepted = false,
    this.acceptedBy,
    this.acceptedByName,
    this.isDeleted = false,
    this.createdAt,
    this.acceptedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'vehicle': vehicle,
      'postedBy': postedBy,
      'garageId': garageId,
      'distanceKm': distanceKm,
      'amount': amount,
      'time': time,
      'category': category,
      'location': location,
      'notes': notes ?? '',
      'isAccepted': isAccepted,
      'acceptedBy': acceptedBy,
      'acceptedByName': acceptedByName,
      'isDeleted': isDeleted,
    };
  }

  factory WorkPost.fromMap(Map<String, dynamic> map, String id) {
    return WorkPost(
      id: id,
      title: map['title'] ?? '',
      vehicle: map['vehicle'] ?? '',
      postedBy: map['postedBy'] ?? '',
      garageId: map['garageId'] ?? '',
      distanceKm: (map['distanceKm'] ?? 0.0).toDouble(),
      amount: map['amount'] ?? '',
      time: map['time'] ?? '',
      category: map['category'] ?? '',
      location: map['location'] ?? '',
      notes: map['notes'],
      isAccepted: map['isAccepted'] ?? false,
      acceptedBy: map['acceptedBy'],
      acceptedByName: map['acceptedByName'],
      isDeleted: map['isDeleted'] ?? false,
      createdAt: (map['createdAt'] as dynamic)?.toDate(),
      acceptedAt: (map['acceptedAt'] as dynamic)?.toDate(),
    );
  }

  WorkPost copyWith({
    bool? isAccepted,
    String? acceptedBy,
    String? acceptedByName,
    bool? isDeleted,
  }) {
    return WorkPost(
      id: id,
      title: title,
      vehicle: vehicle,
      postedBy: postedBy,
      garageId: garageId,
      distanceKm: distanceKm,
      amount: amount,
      time: time,
      category: category,
      location: location,
      notes: notes,
      isAccepted: isAccepted ?? this.isAccepted,
      acceptedBy: acceptedBy ?? this.acceptedBy,
      acceptedByName: acceptedByName ?? this.acceptedByName,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt,
      acceptedAt: acceptedAt,
    );
  }
}