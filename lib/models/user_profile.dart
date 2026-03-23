class UserProfile {
  final String name;
  final String email;
  final String? photoUrl;
  final String? gender;
  final DateTime? dob;
  final String? language;

  const UserProfile({
    required this.name,
    required this.email,
    this.photoUrl,
    this.gender,
    this.dob,
    this.language,
  });

  UserProfile copyWith({
    String? name,
    String? email,
    String? photoUrl,
    String? gender,
    DateTime? dob,
    String? language,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      language: language ?? this.language,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'photoUrl': photoUrl,
    'gender': gender,
    'dob': dob?.toIso8601String(),
    'language': language,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'] as String,
    email: json['email'] as String,
    photoUrl: json['photoUrl'] as String?,
    gender: json['gender'] as String?,
    dob: json['dob'] != null ? DateTime.parse(json['dob'] as String) : null,
    language: json['language'] as String?,
  );
}
