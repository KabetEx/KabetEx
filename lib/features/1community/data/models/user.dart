class UserProfile {
  String? id; // UID from auth
  final String name;
  final String pNumber;
  final String email;
  final String year;
  final String bio;
  final String avatarUrl;
  DateTime? createdAt;
  final bool isVerified;
  final bool isActive;

  UserProfile({
    this.id,
    required this.name,
    required this.pNumber,
    required this.email,
    required this.year,
    required this.bio,
    required this.avatarUrl,
    required this.createdAt,
    required this.isActive,
    required this.isVerified,
  });

  //sending
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'phone_number': pNumber,
    'email': email,
    'year': year,
    'isActive': isActive,
    'isVerified': isVerified,
    'avatar_url': avatarUrl,
  };

  //from supabase
  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
    id: map['id'],
    avatarUrl: map['avatar_url'] ?? '',
    name: map['full_name'] ?? '',
    bio: map['bio'] ?? '',
    pNumber: map['phone_number'] ?? '',
    email: map['email'] ?? '',
    year: map['year'] ?? '',
    isActive: map['isActive'] ?? true,
    isVerified: map['isVerified'] ?? false,
    createdAt: map['created_at'] != null
        ? DateTime.parse(map['created_at'])
        : null,
  );
}
