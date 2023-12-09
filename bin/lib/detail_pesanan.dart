// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

class DetailPesanan {
  String? id_detail_pesanan;
  int? id_pesanan;
  int? id_produk;
  int? jumlah;
  int? subtotal;

  DetailPesanan(
      {required this.id_detail_pesanan,
      required this.id_pesanan,
      required this.id_produk,
      required this.jumlah,
      required this.subtotal});

  Map<String, dynamic> toMap() => {
        'id_detail_pesanan': id_detail_pesanan,
        'id_pesanan': id_pesanan,
        'id_produk': id_produk,
        'jumlah': jumlah,
        'subtotal': subtotal
      };

  final Controller ctrl = Controller();

  factory DetailPesanan.fromJson(Map<String, dynamic> json) => DetailPesanan(
      id_detail_pesanan: json['id_detail_pesanan'],
      id_pesanan: json['id_pesanan'],
      id_produk: json['id_produk'],
      jumlah: json['jumlah'],
      subtotal: json['subtotal']);
}

class Controller {}

DetailPesanan detailPesananFromJson(String str) => DetailPesanan.fromJson(json.decode(str));
