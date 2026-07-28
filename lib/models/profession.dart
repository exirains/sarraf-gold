class Profession {
  final int id;
  final String name;

  Profession({required this.id, required this.name});

  factory Profession.fromJson(Map<String, dynamic> json) {
    return Profession(
      id: json['id'],
      name: json['name'],
    );
  }
}
