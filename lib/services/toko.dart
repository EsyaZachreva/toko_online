import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:toko_online/models/response_data_list.dart';
import 'package:toko_online/models/response_data_map.dart';
import 'package:toko_online/models/toko_model.dart';
import 'package:toko_online/models/user_login.dart';
import 'package:toko_online/services/url.dart' as url;

class TokoService {
  Future<Map<String, String>?> _getAuthHeader() async {
    UserLogin userLogin = UserLogin();
    var user = await userLogin.getUserLogin();
    if (user.status == false) return null;
    return {'Authorization': 'Bearer ${user.token}'};
  }

  // ── GET ALL ──────────────────────────────────────────────────────────────
  Future<ResponseDataList> getBarang() async {
    final headers = await _getAuthHeader();
    if (headers == null) {
      return ResponseDataList(status: false, message: 'User not logged in');
    }

    try {
      var uri = Uri.parse('${url.BaseUrl}/admin/getbarang');
      var res = await http.get(uri, headers: headers);

      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        if (data['status'] == true) {
          List barang = data['data'].map((r) => TokoModel.fromJson(r)).toList();
          return ResponseDataList(
            status: true,
            message: 'success load data',
            data: barang,
          );
        }
        return ResponseDataList(status: false, message: 'Failed load data');
      }
      return ResponseDataList(
        status: false,
        message: 'Error code ${res.statusCode}',
      );
    } catch (e) {
      return ResponseDataList(status: false, message: e.toString());
    }
  }

  // ── CREATE (multipart, support web & mobile) ─────────────────────────────
  Future<ResponseDataMap> insertBarang(
    TokoModel barang,
    XFile imageFile,
  ) async {
    final headers = await _getAuthHeader();
    if (headers == null) {
      return ResponseDataMap(status: false, message: 'User not logged in');
    }

    try {
      var uri = Uri.parse('${url.BaseUrl}/admin/insertbarang');
      var request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);

      request.fields['nama_barang'] = barang.nama_barang ?? '';
      request.fields['deskripsi'] = barang.deskripsi ?? '';
      request.fields['stok'] = barang.stok?.toString() ?? '0';
      request.fields['harga'] = barang.harga?.toString() ?? '0';

      // Pakai fromBytes supaya works di web & mobile
      final bytes = await imageFile.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes('image', bytes, filename: imageFile.name),
      );

      var streamedRes = await request.send();
      var res = await http.Response.fromStream(streamedRes);

      print('INSERT STATUS: ${res.statusCode}');
      print('INSERT RESPONSE: ${res.body}');

      var data = json.decode(res.body);
      return ResponseDataMap(
        status: data['status'] == true,
        message: data['message']?.toString() ?? '',
      );
    } catch (e) {
      print('INSERT ERROR: $e');
      return ResponseDataMap(status: false, message: e.toString());
    }
  }

  // ── UPDATE (multipart, support web & mobile) ─────────────────────────────
  Future<ResponseDataMap> updateBarang(
    TokoModel barang, {
    XFile? pickedFile,
  }) async {
    final headers = await _getAuthHeader();
    if (headers == null) {
      return ResponseDataMap(status: false, message: 'User not logged in');
    }

    try {
      var uri = Uri.parse('${url.BaseUrl}/admin/updatebarang/${barang.id}');
      var request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);

      request.fields['nama_barang'] = barang.nama_barang ?? '';
      request.fields['deskripsi'] = barang.deskripsi ?? '';
      request.fields['stok'] = barang.stok?.toString() ?? '0';
      request.fields['harga'] = barang.harga?.toString() ?? '0';

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            bytes,
            filename: pickedFile.name,
          ),
        );
      }

      var streamedRes = await request.send();
      var res = await http.Response.fromStream(streamedRes);

      print('UPDATE STATUS: ${res.statusCode}');
      print('UPDATE RESPONSE: ${res.body}');

      var data = json.decode(res.body);
      return ResponseDataMap(
        status: data['status'] == true,
        message: data['message']?.toString() ?? '',
      );
    } catch (e) {
      print('UPDATE ERROR: $e');
      return ResponseDataMap(status: false, message: e.toString());
    }
  }

  // ── DELETE ───────────────────────────────────────────────────────────────
  Future<ResponseDataMap> deleteBarang(int id) async {
    final headers = await _getAuthHeader();
    if (headers == null) {
      return ResponseDataMap(status: false, message: 'User not logged in');
    }

    try {
      var uri = Uri.parse('${url.BaseUrl}/admin/hapusbarang/$id');
      var res = await http.delete(uri, headers: headers);

      print('DELETE STATUS: ${res.statusCode}');
      print('DELETE RESPONSE: ${res.body}');

      var data = json.decode(res.body);
      return ResponseDataMap(
        status: data['status'] == true,
        message: data['message']?.toString() ?? '',
      );
    } catch (e) {
      print('DELETE ERROR: $e');
      return ResponseDataMap(status: false, message: e.toString());
    }
  }

  Future<ResponseDataList> getBarangUser() async {
    final headers = await _getAuthHeader();
    if (headers == null) {
      return ResponseDataList(status: false, message: 'User not logged in');
    }

    try {
      var uri = Uri.parse('${url.BaseUrl}/user/getbarang');
      var res = await http.get(uri, headers: headers);

      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        if (data['status'] == true) {
          List barang = data['data'].map((r) => TokoModel.fromJson(r)).toList();
          return ResponseDataList(
            status: true,
            message: 'success load data',
            data: barang,
          );
        }
        return ResponseDataList(status: false, message: 'Failed load data');
      }
      return ResponseDataList(
        status: false,
        message: 'Error code ${res.statusCode}',
      );
    } catch (e) {
      return ResponseDataList(status: false, message: e.toString());
    }
  }
}
