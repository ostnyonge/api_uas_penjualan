// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

class Pelanggan {
  final int? id_pelanggan;
  final String? nama;
  final String? alamat;
  final String? email;
  final String? no_telepon;
  String? tanggal_input;
  String? tanggal_update;

  Pelanggan({
    required this.id_pelanggan,
    required this.nama,
    required this.alamat,
    required this.email,
    required this.no_telepon,
    required this.tanggal_input,
    required this.tanggal_update
  });

  Map<String, dynamic> toMap() => {
        'id_pelanggan': id_pelanggan,
        'nama': nama,
        'alamat': alamat,
        'email': email,
        'no_telepon': no_telepon,
        'tanggal_input': tanggal_input,
        'tanggal_update': tanggal_update
      };

  final Controller ctrl = Controller();

  factory Pelanggan.fromJson(Map<String, dynamic> json) => Pelanggan(
        id_pelanggan: json['id_pelanggan'],
        nama: json['nama'],
        alamat: json['alamat'],
        email: json['email'],
        no_telepon: json['no_telepon'],
        tanggal_input: json['tanggal_input'],
        tanggal_update: json['tanggal_update']
      );
}

class Controller {}

Pelanggan pelangganFromJson(String str) => Pelanggan.fromJson(json.decode(str));
