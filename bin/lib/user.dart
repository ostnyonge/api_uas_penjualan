// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

class User {
  final int id_user;
  final String? nama;
  final String? email;
  String? password;
  final String? jabatan;
  final int role;
  String? tanggal_bergabung;
  String? modified;

  User({
    required this.id_user,
    required this.nama,
    required this.jabatan,
    required this.email,
    required this.password,
    required this.role,
    required this.tanggal_bergabung,
    required this.modified,
  });

  Map<String, dynamic> toMap() => {
        'id_user': id_user,
        'nama': nama,
        'email': email,
        'password': password,
        'jabatan': jabatan,
        'role': role,
        'tanggal_bergabung': tanggal_bergabung,
        'modified': modified
      };

  final Controller ctrl = Controller();

  factory User.fromJson(Map<String, dynamic> json) => User(
        id_user: json['id_user'],
        nama: json['nama'],
        email: json['email'],
        password: json['password'],
        jabatan: json['jabatan'],
        role: json['role'],
        tanggal_bergabung: json['tanggal_bergabung'],
        modified: json['modified'],
      );
}

class Controller {}

User userFromJson(String str) => User.fromJson(json.decode(str));
