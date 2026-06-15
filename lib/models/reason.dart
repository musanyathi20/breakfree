import 'package:uuid/uuid.dart';

class Reason {
  final String id;
  String text;
  String icon;
  DateTime createdAt;

  Reason({
    String? id,
    required this.text,
    required this.icon,
    required this.createdAt,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'icon': icon,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Reason.fromJson(Map<String, dynamic> json) {
    return Reason(
      id: json['id'],
      text: json['text'],
      icon: json['icon'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
