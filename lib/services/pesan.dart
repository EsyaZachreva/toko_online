import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:toko_online/models/response_data_map.dart';
import 'package:toko_online/models/user_login.dart';
import 'package:toko_online/services/url.dart' as url;

class Pesan {
  UserLogin userLogin = UserLogin();

  Future<Map<String, String>> _authHeaders() async {
    var user = await userLogin.getUserLogin();
    if (user.status == false) return {};
    return {
      "Authorization": "Bearer ${user.token}",
      "Content-Type": "application/json",
    };
  }

  Future<ResponseDataMap> saveToDB(dataRequest) async {
    var uri = Uri.parse(url.BaseUrl + "/user/transaksi");
    var user = await userLogin.getUserLogin();

    if (user.status == false) {
      return ResponseDataMap(
        status: false,
        message: 'Anda belum login / token invalid',
      );
    }

    Map<String, String> headers = {
      "Authorization": "Bearer ${user.token}",
      "Content-Type": "application/json",
    };

    try {
      var response = await http.post(
        uri,
        body: json.encode(dataRequest),
        headers: headers,
      );
      var data = json.decode(response.body);
      if (response.statusCode == 200 && data["status"] == true) {
        return ResponseDataMap(status: true, message: "Sukses memproses pesanan", data: data);
      } else {
        return ResponseDataMap(
          status: false,
          message: data["message"]?.toString() ??
              "Gagal transaksi code ${response.statusCode}",
        );
      }
    } catch (e) {
      return ResponseDataMap(status: false, message: e.toString());
    }
  }

  // Ambil riwayat transaksi user
  Future<ResponseDataMap> getHistory() async {
    var uri = Uri.parse(url.BaseUrl + "/user/history_trans");
    var headers = await _authHeaders();

    if (headers.isEmpty) {
      return ResponseDataMap(
          status: false, message: 'Anda belum login / token invalid');
    }

    try {
      var response = await http.get(uri, headers: headers);
      var data = json.decode(response.body);
      print("RESPONSE HISTORY: $data"); // 
      if (response.statusCode == 200 && data["status"] == true) {
        return ResponseDataMap(
          status: true,
          message: "Sukses",
          data: data["data"],
        );
      } else {
        return ResponseDataMap(
          status: false,
          message: data["message"]?.toString() ?? "Gagal memuat riwayat",
        );
      }
    } catch (e) {
      return ResponseDataMap(status: false, message: e.toString());
    }
  }
}