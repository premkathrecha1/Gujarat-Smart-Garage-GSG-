enum UserRole { 
  carOwner,
  garageOwner,
  admin   
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String? garageName;
  final String? city;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.garageName,
    this.city,
  });

  // Helper getters
  bool get isCarOwner => role == UserRole.carOwner;
  bool get isGarageOwner => role == UserRole.garageOwner;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.index,
      'garageName': garageName,
      'city': city,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: UserRole.values[map['role'] ?? 0],
      garageName: map['garageName'],
      city: map['city'],
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, role: ${role == UserRole.carOwner ? "Car Owner" : "Garage Owner"})';
  }
}