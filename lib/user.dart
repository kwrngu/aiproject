class User {
  String id;
  String name;
  String email;
  String role; // 'admin' or 'user'
  String? profilePictureUrl;

  User({required this.id, required this.name, required this.email, required this.role, this.profilePictureUrl});

  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      id: data['id'],
      name: data['name'],
      email: data['email'],
      role: data['role'],
      profilePictureUrl: data['profilePictureUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'profilePictureUrl': profilePictureUrl,
    };
  }
}
