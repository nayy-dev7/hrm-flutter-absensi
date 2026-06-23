import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'dart:io';
import 'inputpegawai.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:absensi/config/config.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override

  State<ProfilePage> createState() =>
      _ProfilePageState();
}

class _ProfilePageState
    extends State<ProfilePage> {

  String nama = "";
  String role = "";
  String nip = "";
  String email = "";
  String hp = "";
  String address = "";
  String division = "";
  String joinDate = "";
  String fotoProfile = "";
  bool profileLengkap = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final prefs = await SharedPreferences.getInstance();

    int employeeId = prefs.getInt("employee_id") ?? 0;

    print("Employee ID = $employeeId");

    final response = await http.get(
      Uri.parse(
        "${ApiConfig.baseUrl}/employees/$employeeId",
      ),
    );

    print(response.body);

    if (response.statusCode == 200) {
      final employee = jsonDecode(response.body);
      if (!mounted) return;

      setState(() {
        nama = employee["nama"] ?? "";
        role = employee["role"] ?? "";
        nip = employee["nip"] ?? "";
        email = employee["email"] ?? "";
        hp = employee["phone"] ?? "";
        address = employee["alamat"] ?? "";
        division = employee["divisi"] ?? "";
        joinDate = employee["join_date"] ?? "";
        fotoProfile = employee["foto"] ?? "";

        profileLengkap =
            nama.isNotEmpty &&
            nip.isNotEmpty &&
            role.isNotEmpty;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xfff5f7fb),

      appBar: AppBar(
        title: const Text(
          "My Profile",
        ),
        centerTitle: true,
        backgroundColor:
            const Color(0xff0d6efd),
        foregroundColor:
            Colors.white,
        elevation: 0,
      ),

      body: ListView(
        padding:
            const EdgeInsets.all(16),
        children: [

          // HEADER PROFILE
          Container(
            padding:
                const EdgeInsets.all(
                    24),
            decoration:
                BoxDecoration(
              gradient:
                  const LinearGradient(
                colors: [
                  Color(0xff0d6efd),
                  Color(0xff4da3ff),
                ],
              ),
              borderRadius:
                  BorderRadius.circular(
                      24),
            ),
            child: Column(
              children: [

                CircleAvatar(
                  radius: 55,

                  backgroundColor:
                      Colors.white,

                  backgroundImage: null,
                      // fotoProfile.isNotEmpty
                      //     ? FileImage(
                      //         File(fotoProfile),
                      //       )
                      //     : null,
                      

                  child: fotoProfile.isEmpty
                      ? const Icon(
                          Icons.person,
                          size: 55,
                          color: Colors.grey,
                        )
                      : null,
                ),

                SizedBox(height: 14),

                Text(
                  nama.isEmpty
                      ? "Employee Name"
                      : nama,

                  style: TextStyle(
                    color:
                        Colors.white,
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                SizedBox(height: 6),

                Text(
                  role.isEmpty
                    ? "Complete Your Profile"
                    : role,
                  style: TextStyle(
                    color:
                        Colors.white70,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  "ID : ${nip.isEmpty ? "-" : nip}",
                  style: TextStyle(
                    color:
                        Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "Personal Information",
            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 14),

          infoCard(
            Icons.email,
            "Email",
            email,
          ),

          infoCard(
            Icons.phone,
            "Phone",
            hp,
          ),

          infoCard(
            Icons.location_on,
            "Address",
            address,
          ),

          infoCard(
            Icons.work,
            "Division",
            division,
          ),

          infoCard(
            Icons.calendar_month,
            "Join Date",
            joinDate,
          ),

          const SizedBox(height: 20),

          // ACTION BUTTON
          ElevatedButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FormPegawaiPage(),
                ),
              );

              getData();
            },
            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(
                      0xff0d6efd),
              minimumSize:
                  const Size(
                      double.infinity,
                      55),
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius
                        .circular(
                            16),
              ),
            ),
            child: Text(
              profileLengkap ? "EDIT PROFILE" : "LENGKAPI PROFILE",
              style: TextStyle(
                color:
                    Colors.white,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 12),

          OutlinedButton(
            onPressed: () async {

              final prefs =
                  await SharedPreferences.getInstance();

              await prefs.clear();

              if (!context.mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const MyApp(),
                ),
                (route) => false,
              );
            },
            style:
                OutlinedButton.styleFrom(
              side: const BorderSide(
                color:
                    Colors.red,
              ),
              minimumSize:
                  const Size(
                      double.infinity,
                      55),
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius
                        .circular(
                            16),
              ),
            ),
            child: const Text(
              "LOGOUT",
              style: TextStyle(
                color: Colors.red,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget infoCard(
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(
              bottom: 12),
      padding:
          const EdgeInsets.all(
              16),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
                18),
        boxShadow: const [
          BoxShadow(
            color:
                Colors.black12,
            blurRadius: 5,
          )
        ],
      ),
      child: Row(
        children: [

          CircleAvatar(
            backgroundColor:
                const Color(
                    0xffeaf3ff),
            child: Icon(
              icon,
              color:
                  const Color(
                      0xff0d6efd),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [

                Text(
                  title,
                  style:
                      const TextStyle(
                    color:
                        Colors.grey,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(
                    height: 4),

                Text(
                  value,
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}