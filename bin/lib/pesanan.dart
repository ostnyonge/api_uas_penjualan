// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

class Pesanan {
  final int? id_pesanan;
  final int? id_pelanggan;
  final int? harga;
  final int? jumlah;
  String? kode_pesanan;
  String? tanggal_pesanan;
  String? tanggal_update;

  Pesanan(
      {required this.id_pesanan,
      required this.kode_pesanan,
      required this.id_pelanggan,
      required this.harga,
      required this.jumlah,
      required this.tanggal_pesanan,
      required this.tanggal_update});

  Map<String, dynamic> toMap() => {
        'id_pesanan': id_pesanan,
        'kode_pesanan': kode_pesanan,
        'id_pelanggan': id_pelanggan,
        'harga': harga,
        'jumlah': jumlah,
        'tanggal_pesanan': tanggal_pesanan,
        'tanggal_update': tanggal_update
      };

  final Controller ctrl = Controller();

  factory Pesanan.fromJson(Map<String, dynamic> json) => Pesanan(
      id_pesanan: json['id_pesanan'],
      kode_pesanan: json['kode_pesanan'],
      id_pelanggan: json['id_pelanggan'],
      harga: json['harga'],
      jumlah: json['jumlah'],
      tanggal_pesanan: json['tanggal_pesanan'],
      tanggal_update: json['tanggal_update']);
}

class Controller {}

Pesanan pesananFromJson(String str) => Pesanan.fromJson(json.decode(str));
