// ignore_for_file: avoid_relative_lib_imports, unused_import, unused_local_variable, non_constant_identifier_names, prefer_interpolation_to_compose_strings, unused_element, unnecessary_string_interpolations, no_leading_underscores_for_local_identifiers

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
import 'lib/controller.dart';

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

  final Controller ctrl = Controller();
  ctrl.connectSql();

// Configure routes.
  final _router = Router()
    ..get('/', _rootHandler)
    ..get('/user', ctrl.getUser)
    ..post('/userFilter', ctrl.getUserFilter)
    ..post('/postDataUser', ctrl.postDataUser)
    ..put('/putDataUser', ctrl.putDataUser)
    ..delete('/deleteUser', ctrl.deleteUser)
    ..get('/produk', ctrl.getProduk)
    ..post('/produkFilter', ctrl.getProdukFilter)
    ..post('/postDataProduk', ctrl.postDataProduk)
    ..put('/putDataProduk', ctrl.putDataProduk)
    ..delete('/deleteProduk', ctrl.deleteProduk)
    ..get('/pelanggan', ctrl.getPelanggan)
    ..post('/pelangganFilter', ctrl.getPelangganFilter)
    ..post('/postDataPelanggan', ctrl.postDataPelanggan)
    ..put('/putDataPelanggan', ctrl.putDataPelanggan)
    ..delete('/deletePelanggan', ctrl.deletePelanggan)
    ..get('/pesanan', ctrl.getPesanan)
    ..post('/pesananFilter', ctrl.getPesananFilter)
    ..post('/postDataPesanan', ctrl.postDataPesanan)
    ..put('/putDataPesanan', ctrl.putDataPesanan)
    ..delete('/deletePesanan', ctrl.deletePesanan)
    ..get('/detailPesanan', ctrl.getDetailPesanan)
    ..post('/detailPesananFilter', ctrl.getDetailPesananFilter)
    ..get('/echo/<message>', _echoHandler);

  // Configure a pipeline that logs requests.
  final handler =
      Pipeline().addMiddleware(logRequests()).addHandler(_router.call);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}
