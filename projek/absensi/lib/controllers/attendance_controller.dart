import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:absensi/config/config.dart';

class AttendanceController {

  Future<void> simpanData({

    required String checkIn,
    required String checkOut,
    required String status,
    required String totalKerja,
    required String lembur,

  })
   async {

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
        "checkIn", checkIn);

    await prefs.setString(
        "checkOut", checkOut);

    await prefs.setString(
        "status", status);

    await prefs.setString(
        "totalKerja",
        totalKerja);

    await prefs.setString(
        "lembur",
        lembur);
    await prefs.setString(
      "attendanceDate",
      "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}",
    );
  }

  Future<Map<String, String>> getData() async {
      final prefs = await SharedPreferences.getInstance();

      int employeeId = prefs.getInt("employee_id") ?? 0;

      print("Employee ID = $employeeId");

      final response = await http.get(
        Uri.parse(
          "${ApiConfig.baseUrl}/attendance/$employeeId",
        ),
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode != 200) {
        return {
          "checkIn": "--:--",
          "checkOut": "--:--",
          "status": "Belum Absen",
          "totalKerja": "-",
          "lembur": "0 Jam",
        };
      }

      if (response.body.isEmpty || response.body == "[]") {
        return {
          "checkIn": "--:--",
          "checkOut": "--:--",
          "status": "Belum Absen",
          "totalKerja": "-",
          "lembur": "0 Jam",
        };
      }

      final Map<String, dynamic> attendance =
          jsonDecode(response.body);

      return {
        "checkIn": attendance["check_in"] ?? "--:--",
        "checkOut": attendance["check_out"] ?? "--:--",
        "status": attendance["status"] ?? "Belum Absen",
        "totalKerja": attendance["total_kerja"]?.toString() ?? "-",
        "lembur": attendance["lembur"]?.toString() ?? "0 Jam",
      };
    }
    
  Future<void> simpanHistory({
    required String tanggal,
    required String checkIn,
    required String checkOut,
    required String status,
    required String totalKerja,
    required String lembur,
  }) async {
    final prefs =
        await SharedPreferences.getInstance();

    List<String> history =
        prefs.getStringList("history") ?? [];

    Map<String, dynamic> data = {
      "tanggal": tanggal,
      "checkIn": checkIn,
      "checkOut": checkOut,
      "status": status,
      "totalKerja": totalKerja,
      "lembur": lembur,
    };

    print("History sebelum: ${history.length}");

    history.add(jsonEncode(data));

    print("History sesudah: ${history.length}");
    await prefs.setStringList(
      "history",
      history,
    );
  }
  
  bool telat(DateTime now) {

    return now.hour > 8 ||
        (now.hour == 8 &&
            now.minute > 0);
  }

  bool bolehCheckIn(
      DateTime now) {

    return now.hour >= 7;
  }

  bool bolehCheckOut(
      DateTime now) {

    return true;
  }

  String hitungLembur(
      DateTime now) {

    int totalLembur = 0;

    if (now.hour >= 17) {

      totalLembur =
          (now.hour - 16);
    }

    return "$totalLembur Jam";
  }

  String hitungTotalKerja({

    required DateTime masuk,
    required DateTime keluar,

  }) {

    Duration kerja =
        keluar.difference(masuk);

    int jam =
        kerja.inHours;

    int menit =
        kerja.inMinutes % 60;

    return "$jam Jam $menit Menit";
  }
}