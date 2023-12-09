// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

class Role {
  final int? id;
  final String? role;

  Role(
      {required this.id,
      required this.role,}
  );
  Map<String, dynamic> toMap() => {
        'id_role': id,
        'role': role
      };

  final Controller ctrl = Controller();

  factory Role.fromJson(Map<String, dynamic> json) => Role(
      id: json['id'],
      role: json['role']
  );
}

class Controller {}

Role roleFromJson(String str) => Role.fromJson(json.decode(str));