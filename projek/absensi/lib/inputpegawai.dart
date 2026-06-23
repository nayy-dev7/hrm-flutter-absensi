import 'package:flutter/material.dart';
import 'camera.dart';
import 'dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:absensi/config/config.dart';

class FormPegawaiPage extends StatefulWidget {
  const FormPegawaiPage({super.key});

  @override
  State<FormPegawaiPage> createState() =>
      _FormPegawaiPageState();
}

class _FormPegawaiPageState
    extends State<FormPegawaiPage> {

  final nip =
      TextEditingController();
  final nama =
      TextEditingController();
  final email =
      TextEditingController();
  final hp =
      TextEditingController();
  final role =
      TextEditingController();
  final address =
      TextEditingController();
  final division =
      TextEditingController();
  File? imageFile;
  
  @override
  void initState() {
    super.initState();

    loadData();
  }

  Future<void> loadData() async {

    final prefs =
        await SharedPreferences.getInstance();
    
    nip.text =
        prefs.getString("nip") ?? "";

    nama.text =
        prefs.getString("nama") ?? "";

    email.text =
        prefs.getString("email") ?? "";

    hp.text =
        prefs.getString("hp") ?? "";

    role.text =
        prefs.getString("role") ?? "";

    division.text =
        prefs.getString("division") ?? "";

    address.text =
        prefs.getString("address") ?? "";

    String foto =
        prefs.getString("foto") ?? "";

    if (foto.isNotEmpty) {

      imageFile =
          File(foto);
    }

    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xfff5f7fb),

      appBar: AppBar(
        title:
            const Text("Data Pegawai"),
        centerTitle: true,
        backgroundColor:
            const Color(0xff0d6efd),
        foregroundColor:
            Colors.white,
      ),

      body: ListView(
        padding:
            const EdgeInsets.all(16),
        children: [

          // FOTO PROFILE
          Center(
            child: Stack(
              children: [

                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    image: imageFile != null
                        ? DecorationImage(
                            image: FileImage(imageFile!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),

                  child: imageFile == null
                      ? const Icon(
                          Icons.person,
                          size: 55,
                          color: Colors.grey,
                        )
                      : null,
                ),

                Positioned(
                  right: 0,
                  bottom: 0,

                  child: InkWell(

                    onTap: () async {

                      final result =
                          await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const CameraPage(),
                        ),
                      );

                      if (result != null) {

                        setState(() {

                          imageFile =
                              File(result);
                        });
                      }
                    },

                    child: Container(
                      padding:
                          const EdgeInsets.all(10),

                      decoration:
                          const BoxDecoration(
                        color: Color(0xff0d6efd),
                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          inputBox(
            "NIP",
            nip,
            Icons.badge,
          ),

          inputBox(
            "Nama Pegawai",
            nama,
            Icons.person,
          ),

          inputBox(
            "Email",
            email,
            Icons.email,
          ),

          inputBox(
            "No HP",
            hp,
            Icons.phone,
          ),

          inputBox(
            "Role",
            role,
            Icons.work,
          ),

          inputBox(
            "Division",
            division,
            Icons.apartment,
          ),

          inputBox(
            "Address",
            address,
            Icons.location_on,
          ),

          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: () async {

              if (
                  nip.text.isEmpty ||
                  nama.text.isEmpty ||
                  email.text.isEmpty ||
                  hp.text.isEmpty ||
                  role.text.isEmpty
              ) {

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Semua data wajib diisi",
                    ),
                  ),
                );

                return;
              }
              final prefs =
                  await SharedPreferences.getInstance();

              int employeeId = prefs.getInt("employee_id") ?? 0;

              print(employeeId);

              final response = await http.put(
                Uri.parse(
                  "${ApiConfig.baseUrl}/employees/$employeeId",
                ),
                headers: {
                  "Accept": "application/json",
                },
                body: {
                  "nama": nama.text,
                  "email": email.text,
                  "nip": nip.text,
                  "phone": hp.text,
                  "role": role.text,
                  "divisi": division.text,
                  "alamat": address.text,
                },
              );

              final data = jsonDecode(response.body);

              if (response.statusCode == 200 && data["success"] == true) {

                await prefs.setString("nama", data["employee"]["nama"] ?? "");
                await prefs.setString("email", data["employee"]["email"] ?? "");
                await prefs.setString("nip", data["employee"]["nip"] ?? "");
                await prefs.setString("role", data["employee"]["role"] ?? "");
                await prefs.setString("hp", data["employee"]["phone"] ?? "");
                await prefs.setString("division", data["employee"]["divisi"] ?? "");
                await prefs.setString("address", data["employee"]["alamat"] ?? "");
                await prefs.setString("joinDate", data["employee"]["join_date"] ?? "");

                if (imageFile != null) {

                  await prefs.setString(
                    "foto",
                    imageFile!.path,
                  );
                }

                Navigator.pop(context);
                // Navigator.pushAndRemoveUntil(
                //   context,
                //   MaterialPageRoute(
                //     builder: (_) => MainDashboard(currentIndex: 4),
                //   ),
                //   (route) => false,
                // );

              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(data["message"] ?? "Gagal update profile"),
                  ),
                );
              }
              


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
            child: const Text(
              "SIMPAN DATA",
              style: TextStyle(
                color:
                    Colors.white,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget inputBox(
    String hint,
    TextEditingController c,
    IconData icon,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(
              bottom: 14),
      child: TextField(
        controller: c,
        decoration:
            InputDecoration(
          prefixIcon:
              Icon(icon),
          hintText: hint,
          filled: true,
          fillColor:
              Colors.white,
          border:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
                    16),
            borderSide:
                BorderSide.none,
          ),
        ),
      ),
    );
  }
}