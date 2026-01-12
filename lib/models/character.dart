import 'package:hive/hive.dart';

part 'character.g.dart';

@HiveType(typeId: 0)
class Character {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String status;

  @HiveField(3)
  final String species;

  @HiveField(4)
  final String image;

  @HiveField(5)
  final String location;

  @HiveField(6)
  final String gender;

  @HiveField(7)
  final String origin;

  @HiveField(8)
  final String type;

  @HiveField(9)
  final int episodeCount;

  Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.image,
    required this.location,
    required this.gender,
    required this.origin,
    required this.type,
    required this.episodeCount,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'],
      name: json['name'],
      status: json['status'],
      species: json['species'],
      image: json['image'],
      location: json['location']['name'],
      gender: json['gender'],
      origin: json['origin']['name'],
      type: json['type'].isEmpty ? 'Unknown' : json['type'],
      episodeCount: (json['episode'] as List).length,
    );
  }
}