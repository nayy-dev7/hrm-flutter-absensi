// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// class LoginController {
//   Future<bool> login({
//     required String nip,
//     required String password,
//   }) async {
//     final response = await http.post(
//       Uri.parse("${ApiConfig.baseUrl}/login"),
//       body: {
//         "nip": nip,
//         "password": password,
//       },
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);

//       final prefs = await SharedPreferences.getInstance();

//       await prefs.setInt(
//         "employee_id",
//         data["employee"]["id"],
//       );

//       return true;
//     }

//     return false;
//   }
// }