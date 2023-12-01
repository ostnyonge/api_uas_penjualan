// ignore_for_file: avoid_relative_lib_imports, unused_import, unused_local_variable, non_constant_identifier_names, prefer_interpolation_to_compose_strings

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

import 'lib/user.dart';
import 'lib/produk.dart';

// Configure routes.
final _router = Router()
  ..get('/', _rootHandler)
  ..post('/login', login)
  ..get('/user', _connectSqlHandlerUser)
  ..post('/userFilter', _handlerUserFilter)
  ..post('/postDataUser', postDataUser)
  ..put('/putDataUser', putDataUser)
  ..delete('/deleteUser', deleteUser)
  ..get('/produk', _connectSqlHandlerProduk)
  ..post('/produkFilter', _handlerProdukFilter)
  ..post('/postDataProduk', postDataProduk)
  ..put('/putDataProduk', putDataProduk)
  ..delete('/deleteProduk', deleteProduk)
  ..get('/echo/<message>', _echoHandler);

Future<MySqlConnection> _ConnectSql() async {
  var settings = ConnectionSettings(
      host: 'localhost',
      port: 3306,
      user: 'dart2',
      password: 'password',
      db: 'uas_penjualan');
  var cn = await MySqlConnection.connect(settings);
  return cn;
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

// Fungsi untuk login
Future<Response> login(Request request) async {
  try {
    String body = await request.readAsString();
    Map<String, dynamic> loginData = json.decode(body);
    String email = loginData['email'];
    String password = loginData['password'];
    String hashedPassword = hashPassword(password); // menghashing password agar bisa membandingkannya dengan database.

    var conn = await _ConnectSql();
    var result = await conn.query(
        'SELECT * FROM user WHERE email = ? AND password = ?',
        [email, hashedPassword]);

    if (result.isNotEmpty) {
      // Login berhasil
      return Response.ok('Login berhasil');
    } else {
      // Email atau password salah
      return Response.forbidden('Email atau password salah');
    }
  } catch (e) {
    return Response.internalServerError(body: 'Terjadi kesalahan');
  }
}


// USER Create
Future<Response> postDataUser(Request request) async {
  String body = await request.readAsString();
  User user = userFromJson(body);
  user.tanggal_bergabung = getDateNow();
  user.modified = getDateNow();

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

  var conn = await _ConnectSql();
  var sqlExecute = """
INSERT INTO user (
  id_user, nama,
  email, password, role,
  jabatan, tanggal_bergabung,
  modified
) VALUES (
  '${user.id_user}', '${user.nama}',
  '${user.email}', '${user.password}', '${user.role}',
  '${user.jabatan}', '${user.tanggal_bergabung}',
  '${user.modified}'
)
""";
  var execute = await conn.query(sqlExecute, []);
  var sql = "SELECT * FROM user WHERE nama = ?";
  var userResponse = await conn.query(sql, [user.nama]);
  return Response.ok(userResponse.toString());
}

/* CREATE data User */
// {
//   "nama" : "Balmond",
//   "email" : "blmnd@gmail.com",
//   "password" : "geprekbensu",
//   "jabatan" : "Mahasiswa",
//   "role" : 1 / 2
// }

// User Update
Future<Response> putDataUser(Request request) async {
  String body = await request.readAsString();
  User user = userFromJson(body);
  user.modified = getDateNow();

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

  var conn = await _ConnectSql();
  var sqlExecute = """
UPDATE user SET
nama = '${user.nama}',
email = '${user.email}',
password = '${user.password}',
jabatan = '${user.jabatan}',
role = '${user.role}',
modified = '${user.modified}'
WHERE id_user = '${user.id_user}'
""";

  var execute = await conn.query(sqlExecute, []);

  var sql = "SELECT * FROM user WHERE id_user = ?";
  var userResponse = await conn.query(sql, [user.id_user]);

  return Response.ok(userResponse.toString());
}

/* UPDATE data User */
// {
//   "id_User" : 2,
//   "nama" : "Balmond",
//   "email" : "blmnd@gmail.com",
//   "password" : "geprekbensu",
//   "jabatan" : "Mahasiswa IT"
// }

// User Delete
Future<Response> deleteUser(Request request) async {
  String body = await request.readAsString();
  User user = userFromJson(body);

  var conn = await _ConnectSql();
  var sqlExecute = """
DELETE FROM user WHERE id_user ='${user.id_user}'
""";

  var execute = await conn.query(sqlExecute, []);

  var sql = "SELECT * FROM user WHERE id_user = ?";
  var userResponse = await conn.query(sql, [user.id_user]);

  return Response.ok(userResponse.toString());
}

/* DELETE data User */
// {
//   "id_User" : 10
// }

// User Read
Future<Response> _connectSqlHandlerUser(Request request) async {
  var conn = await _ConnectSql();
  var user = await conn.query('SELECT * FROM user', []);
  return Response.ok(user.toString());
}

Future<Response> _handlerUserFilter(Request request) async {
  String body = await request.readAsString();
  var obj = json.decode(body);
  var nama = "%" + obj['nama'] + "%";

  var conn = await _ConnectSql();
  var user = await conn.query('SELECT * FROM user where nama like ? ', [nama]);

  return Response.ok(user.toString());
}

/* READ data User */
// {
//   "nama" : "ostnyonge"
// }

// Fungsi untuk memeriksa peran admin
bool isAdmin(String userRole) {
  return userRole == 'admin';
}

// PRODUK Create
Future<Response> postDataProduk(Request request, String userRole) async {
  String body = await request.readAsString();
  Produk produk = produkFromJson(body);

  // Pemeriksaan apakah pengguna memiliki peran admin untuk operasi Create
  if (!isAdmin(userRole)) {
    return Response.forbidden('Anda tidak memiliki izin untuk melakukan operasi Create');
  }

  // Fungsi untuk menghasilkan ID produk secara acak
  String generateRandomProductId() {
    final random = Random();
    String result = '';
    for (var i = 0; i < 8; i++) {
      result += random.nextInt(10).toString(); // Menghasilkan angka acak dari 0 hingga 9
    }
    return result;
  }

  // Menghasilkan nilai acak untuk ID produk
  produk.kode_produk = generateRandomProductId();

  var conn = await _ConnectSql();
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
  return Response.ok(produkResponse.toString());
}

/* CREATE data PRODUK */
// {
//   "id_produk" : 2,
//   "nama_produk" : "Teh Hijau",
//   "deskripsi" : "daun teh pilihan",
//   "harga" : "Rp.15000",
//   "stok" : 5
// }

// KARYAWAN Update
Future<Response> putDataProduk(Request request) async {
  String body = await request.readAsString();
  Produk produk = produkFromJson(body);

  var conn = await _ConnectSql();
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

  return Response.ok(produkResponse.toString());
}

/* UPDATE data PRODUK */
// {
//   "id_produk" : 2,
//   "nama_produk" : "Teh Sariwangi Bundar",
//   "deskripsi" : "Bundarnya pas di gelas",
//   "harga" : "Rp. 20.000",
//   "stok" : 3
// }

// KARYAWAN Delete
Future<Response> deleteProduk(Request request) async {
  String body = await request.readAsString();
  Produk produk = produkFromJson(body);

  var conn = await _ConnectSql();
  var sqlExecute = """
DELETE FROM produk WHERE id_produk ='${produk.id_produk}'
""";

  var execute = await conn.query(sqlExecute, []);

  var sql = "SELECT * FROM produk WHERE id_produk = ?";
  var produkResponse = await conn.query(sql, [produk.id_produk]);

  return Response.ok(produkResponse.toString());
}

/* DELETE data PRODUK */
// {
//   "id_produk" : 2
// }

// KARYAWAN Read
Future<Response> _connectSqlHandlerProduk(Request request) async {
  var conn = await _ConnectSql();
  var produk = await conn.query('SELECT * FROM produk', []);
  return Response.ok(produk.toString());
}

Future<Response> _handlerProdukFilter(Request request) async {
  String body = await request.readAsString();
  var obj = json.decode(body);
  var nama = "%" + obj['nama_produk'] + "%";

  var conn = await _ConnectSql();
  var produk = await conn
      .query('SELECT * FROM produk where nama_produk like ? ', [nama]);

  return Response.ok(produk.toString());
}

/* READ data PRODUK */
// {
//   "nama_produk" : "teh bundar"
// }

Response _rootHandler(Request req) {
  return Response.ok('Hello, World!\n');
}

Response _echoHandler(Request request) {
  final message = request.params['message'];
  return Response.ok('$message\n');
}

void main(List<String> args) async {
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  // Configure a pipeline that logs requests.
  final handler =
      Pipeline().addMiddleware(logRequests()).addHandler(_router.call);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}
