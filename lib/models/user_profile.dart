class UserProfile {
  final String id;
  final String fullName;
  final String phone;
  final int professionId;
  final int points;
  final String? avatarUrl;

  UserProfile({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.professionId,
    required this.points,
    this.avatarUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      fullName: json['full_name'] ?? '',
      phone: json['phone'] ?? '',
      professionId: json['profession_id'] ?? 0,
      points: json['points'] ?? 0,
      avatarUrl: json['avatar_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'profession_id': professionId,
      'points': points,
      'avatar_url': avatarUrl,
    };
  }
}
