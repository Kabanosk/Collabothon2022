import 'dart:convert';

class Place {
  final String id;
  final String descryption;
  final String name;
  final String type;
  final List<String> tags;
  final double x;
  final double y;
  final String number;
  final String uid;

  Place({
    required this.id,
    required this.descryption,
    required this.name,
    required this.type,
    required this.tags,
    required this.x,
    required this.y,
    required this.number,
    required this.uid,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'descryption': descryption,
        'name': name,
        'type': type,
        'tags': tags,
        'x': x,
        'y': y,
        'number': number,
        'uid': uid,
      };

  static Place fromJson(Map<String, dynamic> json) => Place(
        id: json['id'],
        descryption: json['descryption'],
        name: json['name'],
        type: json['type'],
        tags: List.from(json['tags']),
        x: json['x'],
        y: json['y'],
        number: json['number'],
        uid: json['uid'],
      );
}
