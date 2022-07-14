class Place {
  String id;
  final String descryption;
  final String name;
  final String type;
  final double x;
  final double y;
  final String number;

  Place({
    this.id = '',
    required this.descryption,
    required this.name,
    required this.type,
    required this.x,
    required this.y,
    required this.number,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'descryption': descryption,
        'name': name,
        'type': type,
        'x': x,
        'y': y,
        'number': number,
      };

  static Place fromJson(Map<String, dynamic> json) => Place(
        id: json['id'],
        descryption: json['descryption'],
        name: json['name'],
        type: json['type'],
        x: json['x'],
        y: json['y'],
        number: json['number'],
      );
}
