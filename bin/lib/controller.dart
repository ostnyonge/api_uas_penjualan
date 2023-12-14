// ignore_for_file: avoid_relative_lib_imports, unused_import, unused_local_variable, non_constant_identifier_names, prefer_interpolation_to_compose_strings, unused_element, unnecessary_string_interpolations

import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';
import 'package:mysql1/mysql1.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:string_validator/string_validator.dart';
import 'detail_pesanan.dart';
import 'pelanggan.dart';
import 'pesanan.dart';
import 'user.dart';
import 'produk.dart';

class Controller {
  Future<MySqlConnection> connectSql() async {
    var settings = ConnectionSettings(
        host: 'localhost',
        port: 3306,
        user: 'dart2',
        password: 'password',
        db: 'uas_penjualan');
    var cn = await MySqlConnection.connect(settings);
    return cn;
  }

  Map<String, dynamic> _responseSuccessMsg(dynamic msg) {
    return {'status': 200, '\nsuccess': true, '\ndata': msg};
  }

  Map<String, dynamic> _responseErrorMsg(dynamic msg) {
    return {'status': 400, '\nsuccess': false, '\ndata': msg};
  }

// fungsi mendapatkan tanggal
  String getDateNow() {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd hh:mm:ss');
    final String dateNow = formatter.format(now);
    return dateNow;
  }

// fungsi hashing password
  String hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);

    return digest.toString();
  }

// USER Create
  Future<Response> postDataUser(Request request) async {
    String body = await request.readAsString();
    User user = userFromJson(body);
    user.tanggal_bergabung = getDateNow();
    user.tanggal_update = getDateNow();

    // Validasi email
    if (user.email != null && !isEmail(user.email!)) {
      return Response.badRequest(body: 'Format email tidak valid');
    }

    // Validasi password (misalnya, minimal 8 karakter)
    if (user.password!.length < 8) {
      return Response.badRequest(
          body: 'Password harus memiliki minimal 8 karakter');
    }

    String hashedPassword = hashPassword(user.password!);
    user.password = hashedPassword;

    var conn = await connectSql();
    var sqlExecute = """ 
INSERT INTO user (
  id_user, nama,
  email, password, role,
  jabatan, tanggal_bergabung,
  tanggal_update
) VALUES (
  '${user.id_user}', '${user.nama}',
  '${user.email}', '${user.password}', '${user.role}',
  '${user.jabatan}', '${user.tanggal_bergabung}',
  '${user.tanggal_update}'
)
""";
    var execute = await conn.query(sqlExecute, []);

    // merelasikan role.id dengan user.role menggunakan INNER JOIN
    var sql =
        "SELECT * FROM user INNER JOIN role ON user.role = role.id WHERE nama = ?";
    var userResponse = await conn.query(sql, [user.nama]);
    return Response.ok("""
Berhasil Membuat User !
info :
  >> ${userResponse.toString()}""");
  }

/* CREATE data User */
// {
//   "id_user" : 4,
//   "nama" : "Balmond",
//   "email" : "blmnd@gmail.com",
//   "password" : "geprekbensu",
//   "jabatan" : "Mahasiswa",
//   "role" : 2
// }

// User Update
  Future<Response> putDataUser(Request request) async {
    String body = await request.readAsString();
    User user = userFromJson(body);
    user.tanggal_update = getDateNow();

    // Validasi email
    if (user.email != null && !isEmail(user.email!)) {
      return Response.badRequest(body: 'Format email tidak valid');
    }

    // Validasi password (misalnya, minimal 8 karakter)
    if (user.password!.length < 8) {
      return Response.badRequest(
          body: 'Password harus memiliki minimal 8 karakter');
    }

    String hashedPassword = hashPassword(user.password!);
    user.password = hashedPassword;

    var conn = await connectSql();
    var sqlExecute = """
UPDATE user SET
nama = '${user.nama}',
email = '${user.email}',
password = '${user.password}',
jabatan = '${user.jabatan}',
role = '${user.role}',
tanggal_update = '${user.tanggal_update}'
WHERE id_user = '${user.id_user}'
""";

    var execute = await conn.query(sqlExecute, []);

    var sql = "SELECT * FROM user WHERE id_user = ?";
    var userResponse = await conn.query(sql, [user.id_user]);

    return Response.ok("""
Berhasil Mengubah User !
info :
  >>  ${userResponse.toString()}""");
  }

/* UPDATE data User */
// {
//   "id_User" : 2,
//   "nama" : "Balmond",
//   "email" : "blmnd@gmail.com",
//   "password" : "geprekbensu",
//   "jabatan" : "Mahasiswa IT",
//   "role" : 2
// }

// User Delete
  Future<Response> deleteUser(Request request) async {
    String body = await request.readAsString();
    User user = userFromJson(body);

    var conn = await connectSql();
    var sqlExecute = """
DELETE FROM user WHERE id_user ='${user.id_user}'
""";

    var execute = await conn.query(sqlExecute, []);

    var sql = "SELECT * FROM user WHERE id_user = ?";
    var userResponse = await conn.query(sql, [user.id_user]);

    return Response.ok("""
Berhasil Menghapus User !
info :
  >> ${userResponse.toString()}""");
  }

/* DELETE data User */
// {
//   "id_User" : 10
// }

// User Read
  Future<Response> getUser(Request request) async {
    var conn = await connectSql();
    var user = await conn.query('SELECT * FROM user', []);
    var response = _responseSuccessMsg(user.toString());
    return Response.ok(response.toString());
  }

  Future<Response> getUserFilter(Request request) async {
    String body = await request.readAsString();
    var obj = json.decode(body);
    var nama = "%" + obj['nama'] + "%";

    var conn = await connectSql();
    var user =
        await conn.query('SELECT * FROM user where nama like ? ', [nama]);

    var response = _responseSuccessMsg(user.toString());
    return Response.ok(response.toString());
  }

/* READ data User */
// {
//   "nama" : "ostnyonge"
// }

// PRODUK Create
  Future<Response> postDataProduk(Request request) async {
    String body = await request.readAsString();
    Produk produk = produkFromJson(body);

    // Fungsi untuk menghasilkan ID produk secara acak
    String generateRandomProductId() {
      final random = Random();
      String result = '';
      for (var i = 0; i < 8; i++) {
        result += random
            .nextInt(10)
            .toString(); // Menghasilkan angka acak dari 0 hingga 9
      }
      return result;
    }

    // Menghasilkan nilai acak untuk ID produk
    produk.kode_produk = generateRandomProductId();

    var conn = await connectSql();
    var sqlExecute = """
INSERT INTO produk (
  id_produk, kode_produk,
  nama_produk, deskripsi,
  harga, stok
) VALUES (
  '${produk.id_produk}', '${produk.kode_produk}',
  '${produk.nama_produk}', '${produk.deskripsi}',
  '${produk.harga}', '${produk.stok}'
)
""";
    var execute = await conn.query(sqlExecute, []);
    var sql = "SELECT * FROM produk WHERE nama_produk = ?";
    var produkResponse = await conn.query(sql, [produk.nama_produk]);
    return Response.ok("""
Berhasil Membuat Produk !
info :
  >> ${produkResponse.toString()}""");
  }

/* CREATE data PRODUK */
// {
//   "id_produk" : 4,
//   "nama_produk" : "Rosy Moonlight",
//   "deskripsi" : "Silver Needle White Tea + Rose + Jasmine",
//   "harga" : 127000,
//   "stok" : 23
// }

// PRODUK Update
  Future<Response> putDataProduk(Request request) async {
    String body = await request.readAsString();
    Produk produk = produkFromJson(body);

    var conn = await connectSql();
    var sqlExecute = """
UPDATE produk SET
nama_produk = '${produk.nama_produk}',
deskripsi = '${produk.deskripsi}',
harga = '${produk.harga}',
stok = '${produk.stok}'
WHERE id_produk = '${produk.id_produk}'
""";

    var execute = await conn.query(sqlExecute, []);

    var sql = "SELECT * FROM produk WHERE id_produk = ?";
    var produkResponse = await conn.query(sql, [produk.id_produk]);

    return Response.ok("""
Berhasil Mengubah Produk !
info :
  >> ${produkResponse.toString()}""");
  }

/* UPDATE data PRODUK */
// {
//   "id_produk" : 4,
//   "nama_produk" : "Rosy Moonlight",
//   "deskripsi" : "Silver Needle White Tea + Rose + Jasmine",
//   "harga" : 187000,
//   "stok" : 15
// }

// PRODUK Delete
  Future<Response> deleteProduk(Request request) async {
    String body = await request.readAsString();
    Produk produk = produkFromJson(body);

    var conn = await connectSql();
    var sqlExecute = """
DELETE FROM produk WHERE id_produk ='${produk.id_produk}'
""";

    var execute = await conn.query(sqlExecute, []);

    var sql = "SELECT * FROM produk WHERE id_produk = ?";
    var produkResponse = await conn.query(sql, [produk.id_produk]);

    return Response.ok("""
Berhasil Menghapus Produk !
info :
  >> ${produkResponse.toString()}""");
  }

/* DELETE data PRODUK */
// {
//   "id_produk" : 4
// }

// PRODUK Read
  Future<Response> getProduk(Request request) async {
    var conn = await connectSql();
    var produk = await conn.query('SELECT * FROM produk', []);
    return Response.ok(produk.toString());
  }

  Future<Response> getProdukFilter(Request request) async {
    String body = await request.readAsString();
    var obj = json.decode(body);
    var nama = "%" + obj['nama_produk'] + "%";

    var conn = await connectSql();
    var produk = await conn
        .query('SELECT * FROM produk where nama_produk like ? ', [nama]);

    var response = _responseSuccessMsg(produk.toString());
    return Response.ok(response.toString());
  }

/* READ data PRODUK */
// {
//   "nama_produk" : "bery"
// }

// PELANGGAN Create
  Future<Response> postDataPelanggan(Request request) async {
    String body = await request.readAsString();
    Pelanggan pelanggan = pelangganFromJson(body);
    pelanggan.tanggal_input = getDateNow();
    pelanggan.tanggal_update = getDateNow();

    // Validasi email
    if (pelanggan.email != null && !isEmail(pelanggan.email!)) {
      return Response.badRequest(body: 'Format email tidak valid');
    }

    var conn = await connectSql();
    var sqlExecute = """
INSERT INTO pelanggan (
  nama, alamat, email,
  no_telepon, tanggal_input,
  tanggal_update
) VALUES (
  '${pelanggan.nama}',
  '${pelanggan.alamat}', '${pelanggan.email}',
  '${pelanggan.no_telepon}', '${pelanggan.tanggal_input}',
  '${pelanggan.tanggal_update}'
)
""";
    var execute = await conn.query(sqlExecute, []);
    var sql = "SELECT * FROM pelanggan WHERE nama = ?";
    var pelangganResponse = await conn.query(sql, [pelanggan.nama]);
    return Response.ok("""
Berhasil Membuat Pelanggan Baru !
info :
  >> ${pelangganResponse.toString()}""");
  }

/* CREATE data Pelanggan */
// {
//   "id_pelanggan": 1,
//   "nama": "ali mustolih",
//   "alamat": "sawangan",
//   "email": "alimustolih@gmail.com",
//   "no_telepon": "081343238812"
// }

// PELANGGAN Update
  Future<Response> putDataPelanggan(Request request) async {
    String body = await request.readAsString();
    Pelanggan pelanggan = pelangganFromJson(body);
    pelanggan.tanggal_update = getDateNow();

    // Validasi email
    if (pelanggan.email != null && !isEmail(pelanggan.email!)) {
      return Response.badRequest(body: 'Format email tidak valid');
    }

    var conn = await connectSql();
    var sqlExecute = """
UPDATE pelanggan SET
nama = '${pelanggan.nama}',
email = '${pelanggan.email}',
no_telepon = '${pelanggan.no_telepon}',
tanggal_update = '${pelanggan.tanggal_update}'
WHERE id_pelanggan = '${pelanggan.id_pelanggan}'
""";

    var execute = await conn.query(sqlExecute, []);

    var sql = "SELECT * FROM pelanggan WHERE id_pelanggan = ?";
    var pelangganResponse = await conn.query(sql, [pelanggan.id_pelanggan]);

    return Response.ok("""
Berhasil Mengubah Data Pelanggan !
info :
  >> ${pelangganResponse.toString()}""");
  }

/* UPDATE data PELANGGAN */
// {
//   "id_pelanggan": 1,
//   "nama": "ali",
//   "alamat": "gg. haji imron",
//   "email": "alimustolih@gmail.com",
//   "no_telepon": "081343238812"
// }

// PELANGGAN Delete
  Future<Response> deletePelanggan(Request request) async {
    String body = await request.readAsString();
    Pelanggan pelanggan = pelangganFromJson(body);

    var conn = await connectSql();
    var sqlExecute = """
DELETE FROM pelanggan WHERE id_pelanggan ='${pelanggan.id_pelanggan}'
""";

    var execute = await conn.query(sqlExecute, []);

    var sql = "SELECT * FROM pelanggan WHERE id_pelanggan = ?";
    var pelangganResponse = await conn.query(sql, [pelanggan.id_pelanggan]);

    return Response.ok("""
Berhasil Menghapus Pelanggan !
info :
  >> ${pelangganResponse.toString()}""");
  }

/* DELETE data Pelanggan */
// {
//   "id_pelanggan" : 1
// }

// PELANGGAN Read
  Future<Response> getPelanggan(Request request) async {
    var conn = await connectSql();
    var pelanggan = await conn.query('SELECT * FROM pelanggan', []);
    var response = _responseSuccessMsg(pelanggan.toString());
    return Response.ok(response.toString());
  }

  Future<Response> getPelangganFilter(Request request) async {
    String body = await request.readAsString();
    var obj = json.decode(body);
    var nama = "%" + obj['nama'] + "%";

    var conn = await connectSql();
    var pelanggan =
        await conn.query('SELECT * FROM pelanggan where nama like ? ', [nama]);

    var response = _responseSuccessMsg(pelanggan.toString());
    return Response.ok(response.toString());
  }

/* READ data PELANGGAN */
// {
//   "nama" : "wisnu"
// }

// PESANAN Create
  Future<Response> postDataPesanan(Request request) async {
    String body = await request.readAsString();
    Pesanan pesanan = pesananFromJson(body);
    pesanan.tanggal_pesanan = getDateNow();
    pesanan.tanggal_update = getDateNow();

    // Fungsi untuk menghasilkan kode_pesanan secara acak
    String generateRandomKodePesanan() {
      final random = Random();
      String result = '';
      for (var i = 0; i < 8; i++) {
        result += random
            .nextInt(10)
            .toString(); // Menghasilkan angka acak dari 0 hingga 9
      }
      return result;
    }

    // Membuat nilai acak untuk kode_pesanan
    pesanan.kode_pesanan = generateRandomKodePesanan();

    var conn = await connectSql();

    // mendapatkan data harga dari tabel produk dengan harga pada tabel pesanan
    var produkId = await conn
        .query('SELECT id_produk FROM produk WHERE harga = ?', [pesanan.harga]);

    // mendapatkan data stok dari tabel produk dengan jumlah pada tabel pesanan
    var produkStokResult = await conn.query(
        'SELECT stok FROM produk WHERE id_produk = ?',
        [produkId.first['id_produk']]);

    var produkStok = produkStokResult.first['stok'];

    if (pesanan.jumlah! > produkStok) {
      return Response.forbidden('Maaf, stok tidak mencukupi untuk pesanan ini');
    }

    /* CREATE DETAIL PESANAN */
    DetailPesanan detailPesanan = detailPesananFromJson(body);

    // mendapatkan id_produk
    if (produkId.isNotEmpty) {
      detailPesanan.id_produk = produkId.first['id_produk'];

      var sqlExecute = """
INSERT INTO pesanan (
  id_pesanan, kode_pesanan,
  id_pelanggan, harga, jumlah,
  tanggal_pesanan, tanggal_update
) VALUES (
  '${pesanan.id_pesanan}', '${pesanan.kode_pesanan}', '${pesanan.id_pelanggan}',
  '${pesanan.harga}', '${pesanan.jumlah}',
  '${pesanan.tanggal_pesanan}', '${pesanan.tanggal_update}'
)
""";

      var execute = await conn.query(sqlExecute, []);
      var sql = "SELECT * FROM pesanan WHERE kode_pesanan = ?";
      var pesananResponse = await conn.query(sql, [pesanan.kode_pesanan]);

      detailPesanan.id_pesanan = pesanan.id_pesanan;
      detailPesanan.jumlah = pesanan.jumlah;
      detailPesanan.subtotal = (pesanan.harga! * pesanan.jumlah!);

      // Simpan detail pesanan ke dalam database
      var conn_dp = await connectSql();
      var sqlExecute_dp = """
      INSERT INTO detail_pesanan (
          id_pesanan, id_produk, jumlah, subtotal
      ) VALUES (
          '${detailPesanan.id_pesanan}', '${detailPesanan.id_produk}',
          '${detailPesanan.jumlah}', '${detailPesanan.subtotal}'
      )
  """;

      var execute_dp = await conn_dp.query(sqlExecute_dp, []);

      return Response.ok("""
Transaksi Pesanan Berhasil !
info :
  >> ${pesananResponse.toString()}
""");
    } else {
      // Jika tidak ada produk dengan harga yang diberikan
      return Response.notFound("""
Transaksi Pesanan Gagal !
info :
  >> Produk dengan harga tersebut tidak ditemukan
""");
    }
  }

/* CREATE data PESANAN */
// {
//   "id_pesanan": 2,
//   "id_pelanggan": 1,
//   "harga": 127000,
//   "jumlah" : 2
// }

// PESANAN Update
  Future<Response> putDataPesanan(Request request) async {
    String body = await request.readAsString();
    Pesanan pesanan = pesananFromJson(body);
    pesanan.tanggal_update = getDateNow();

    var conn = await connectSql();

    // mengambil data harga dari tabel produk
    var produkId = await conn
        .query('SELECT id_produk FROM produk WHERE harga = ?', [pesanan.harga]);

    // mendapatkan data stok dari tabel produk dengan jumlah pada tabel pesanan
    var produkStokResult = await conn.query(
        'SELECT stok FROM produk WHERE id_produk = ?',
        [produkId.first['id_produk']]);

    var produkStok = produkStokResult.first['stok'];

    if (pesanan.jumlah! > produkStok) {
      return Response.forbidden('Maaf, stok tidak mencukupi untuk pesanan ini');
    }

    // UPDATE DETAIL PENJUALAN
    DetailPesanan detailPesanan = detailPesananFromJson(body);

    // mendapatkan id_produk
    if (produkId.isNotEmpty) {
      detailPesanan.id_produk = produkId.first['id_produk'];
      var sqlExecute = """
UPDATE pesanan SET
id_pesanan = '${pesanan.id_pesanan}',
harga = '${pesanan.harga}',
jumlah = '${pesanan.jumlah}',
tanggal_update = '${pesanan.tanggal_update}'
WHERE id_pesanan = '${pesanan.id_pesanan}'
""";

      var execute = await conn.query(sqlExecute, []);

      var sql = "SELECT * FROM pesanan WHERE id_pesanan = ?";
      var pesananResponse = await conn.query(sql, [pesanan.id_pesanan]);

      detailPesanan.id_pesanan = pesanan.id_pesanan;
      detailPesanan.subtotal = (pesanan.harga! * pesanan.jumlah!);
      detailPesanan.jumlah = pesanan.jumlah;

      var conn_dp = await connectSql();
      var sqlExecute_dp = """
UPDATE detail_pesanan SET
id_pesanan = '${detailPesanan.id_pesanan}',
id_produk = '${detailPesanan.id_produk}',
jumlah = '${detailPesanan.jumlah}',
subtotal = '${detailPesanan.subtotal}'
WHERE id_pesanan = '${detailPesanan.id_pesanan}'
""";

      var execute_dp = await conn_dp.query(sqlExecute_dp, []);

      return Response.ok("""
Berhasil Mengubah Pesanan !
info :
  >> ${pesananResponse.toString()}
""");
    } else {
      // Jika tidak ada produk dengan harga yang diberikan
      return Response.notFound("""
Gagal Mengubah Pesanan !
info :
  >> Produk dengan harga tersebut tidak ditemukan
""");
    }
  }

/* UPDATE data PESANAN */
// {
//   "id_pesanan" : 2,
//   "harga" : 149000,
//   "jumlah" : 5
// }

// PESANAN Delete
  Future<Response> deletePesanan(Request request) async {
    String body = await request.readAsString();
    Pesanan pesanan = pesananFromJson(body);

    var conn = await connectSql();
    var sqlExecute = """
DELETE FROM pesanan WHERE id_pesanan ='${pesanan.id_pesanan}'
""";

    var execute = await conn.query(sqlExecute, []);

    var sql = "SELECT * FROM pesanan WHERE id_pesanan = ?";
    var pesananResponse = await conn.query(sql, [pesanan.id_pesanan]);

    return Response.ok("""
Berhasil Menghapus Pesanan !
info :
  >> ${pesananResponse.toString()}
""");
  }

/* DELETE Pesanan */
// {
//   "id_pesanan" : 3
// }

// PESANAN Read
  Future<Response> getPesanan(Request request) async {
    var conn = await connectSql();
    var pesanan = await conn.query('SELECT * FROM pesanan', []);
    var response = _responseSuccessMsg(pesanan.toString());
    return Response.ok(response.toString());
  }

  Future<Response> getPesananFilter(Request request) async {
    String body = await request.readAsString();
    var obj = json.decode(body);
    var nama_pelanggan = "%" + obj['nama'] + "%";

    var conn = await connectSql();

    // menampilkan data dengan (INNER JOIN) dari tabel pesanan.id_pelanggan --> untuk mendapatkan pesanan a/n pelanggan
    var pesanan = await conn.query(
        'SELECT * FROM pesanan INNER JOIN pelanggan ON pesanan.id_pelanggan = pelanggan.id_pelanggan where nama like ? ',
        [nama_pelanggan]);

    var response = _responseSuccessMsg(pesanan.toString());
    return Response.ok(response.toString());
  }

/* READ Pesanan */
// {
//   "nama" : "ali"
// }

// detail_pesanan Read
  Future<Response> getDetailPesanan(Request request) async {
    var conn = await connectSql();
    var detail_pesanan = await conn.query("""SELECT * FROM detail_pesanan
  """, []);
    var response = _responseSuccessMsg(detail_pesanan.toString());
    return Response.ok(response.toString());
  }

  Future<Response> getDetailPesananFilter(Request request) async {
    String body = await request.readAsString();
    DetailPesanan detail_pesanan = detailPesananFromJson(body);

    var conn = await connectSql();

    var pelanggan = await conn.query(
        'SELECT * FROM detail_pesanan where id_detail_pesanan like ? ',
        [detail_pesanan.id_detail_pesanan]);

    var response = _responseSuccessMsg(pelanggan.toString());
    return Response.ok(response.toString());
  }

/* READ Detail_penjualan */
// {
//   "id_detail_pesanan": "2"
// }
}
