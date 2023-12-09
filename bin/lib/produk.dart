// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

class Produk {
  int? id_produk;
  String? kode_produk;
  final String? nama_produk;
  final String? deskripsi;
  final int? harga;
  final int? stok;

  Produk(
      {required this.id_produk,
      required this.kode_produk,
      required this.nama_produk,
      required this.deskripsi,
      required this.harga,
      required this.stok});

  Map<String, dynamic> toMap() => {
        'id_produk': id_produk,
        'kode_produk': kode_produk,
        'nama_produk': nama_produk,
        'deskripsi': deskripsi,
        'harga': harga,
        'stok': stok
      };

  final Controller ctrl = Controller();

  factory Produk.fromJson(Map<String, dynamic> json) => Produk(
      id_produk: json['id_produk'],
      kode_produk: json['kode_produk'],
      nama_produk: json['nama_produk'],
      deskripsi: json['deskripsi'],
      harga: json['harga'],
      stok: json['stok']);
}

class Controller {}

Produk produkFromJson(String str) => Produk.fromJson(json.decode(str));
