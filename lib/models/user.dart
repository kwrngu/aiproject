class AppUser {
  String id;
  String name;
  String email;
  String role; // 'admin' or 'user'
  String? profilePictureUrl;

  AppUser({required this.id, required this.name, required this.email, required this.role, this.profilePictureUrl});

  factory AppUser.fromMap(Map<String, dynamic> data) {
    return AppUser(
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
