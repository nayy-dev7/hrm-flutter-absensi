import 'package:flutter/material.dart';
import 'views/attendance.dart';
import 'history.dart';
import 'hr.dart';
import 'profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:absensi/config/config.dart';

class MainDashboard extends StatefulWidget {

  final int currentIndex;

  const MainDashboard({
    super.key,
    this.currentIndex = 0,
  });

  @override
  State<MainDashboard> createState() =>
      _MainDashboardState();
}

class _MainDashboardState
  extends State<MainDashboard> {
  late int selectedIndex;

  final pages = [
    const HomePage(),
    const AttendancePage(),
    const HistoryPage(),
    const HrPage(),
    const ProfilePage(),
  ];
  @override
  void initState() {
    super.initState();

    selectedIndex =
        widget.currentIndex;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],

      bottomNavigationBar:
          BottomNavigationBar(
        currentIndex: selectedIndex,
        selectedItemColor:
            const Color(0xff0d6efd),
        unselectedItemColor:
            Colors.grey,
        type:
            BottomNavigationBarType.fixed,
        onTap: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon:
                Icon(Icons.fingerprint),
            label: "Attendance",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "History",
          ),
          BottomNavigationBarItem(
            icon:
                Icon(Icons.bar_chart),
            label: "HR",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

/* ================= HOME ================= */

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() =>
      _HomePageState();
}

class _HomePageState
    extends State<HomePage> {

  String nama = "-";
  String role = "-";
  String nip = "-";
  String checkIn = "--:--";
  String checkOut = "--:--";
  
  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final prefs = await SharedPreferences.getInstance();

    int employeeId = prefs.getInt("employee_id") ?? 0;

    nama = prefs.getString("nama") ?? "Nama Pegawai";
    role = prefs.getString("role") ?? "-";
    nip = prefs.getString("nip") ?? "-";

    final response = await http.get(
      Uri.parse(
        "${ApiConfig.baseUrl}/attendance/$employeeId",
      ),
    );

    if (response.statusCode == 200 &&
        response.body.isNotEmpty &&
        response.body != "[]") {

      final Map<String, dynamic> attendance =
          jsonDecode(response.body);

      checkIn = attendance["check_in"] ?? "--:--";
      checkOut = attendance["check_out"] ?? "--:--";

    } else {
      checkIn = "--:--";
      checkOut = "--:--";
    }

    if (mounted) {
      setState(() {});
    }
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding:
            const EdgeInsets.all(16),
        children: [

          Container(
            padding:
                const EdgeInsets.all(
                    18),
            decoration: BoxDecoration(
              color:
                  const Color(0xff0d6efd),
              borderRadius:
                  BorderRadius.circular(
                      22),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [

                const Text(
                  "ABC COMPANY",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  nama,
                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                Text(
                  "NIP : $nip",
                  style:
                      const TextStyle(
                    color:
                        Colors.white70,
                  ),
                ),

                Text(
                  role,
                  style:
                      const TextStyle(
                    color:
                        Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [

              Expanded(
                child: cardStat(
                  "Absen Masuk",
                  checkIn,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: cardStat(
                  "Absen Keluar",
                  checkOut,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [

              MenuBox(
                icon: Icons.fingerprint,
                text: "Absensi",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AttendancePage(),
                    ),
                  );
                },
              ),

              // MenuBox(
              //   icon: Icons.people,
              //   text: "Pegawai",
              // ),

              MenuBox(
                icon:
                    Icons.calendar_month,
                text: "Jadwal",
              ),

              MenuBox(
                icon: Icons.bar_chart,
                text: "Report",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HistoryPage(),
                    ),
                  );
                },
              ),


              MenuBox(
                icon: Icons.money,
                text: "Payroll",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HrPage(),
                    ),
                  );
                },
              ),

              MenuBox(
                icon: Icons.timer,
                text: "Lembur",
              ),

              MenuBox(
                icon:
                    Icons.apartment,
                text: "Company",
              ),

              MenuBox(
                icon:
                    Icons.more_horiz,
                text: "Lainnya",
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/* ================= COMPONENT ================= */

Widget cardStat(
    String title,
    String value) {
  return Container(
    padding:
        const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius:
          BorderRadius.circular(
              18),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 5,
        )
      ],
    ),
    child: Column(
      children: [
        Text(title),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight:
                FontWeight.bold,
            fontSize: 20,
          ),
        )
      ],
    ),
  );
}

class MenuBox extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  const MenuBox({
    super.key,
    required this.icon,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: const Color(0xff0d6efd),
            ),
            const SizedBox(height: 6),
            Text(
              text,
              style: const TextStyle(
                fontSize: 11,
              ),
            )
          ],
        ),
      ),
    );
  }
}

Widget historyCard() {
  return Container(
    margin:
        const EdgeInsets.only(
            bottom: 14),
    padding:
        const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius:
          BorderRadius.circular(
              18),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 4,
        )
      ],
    ),
    child: const Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          "22 Februari 2026",
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text("Check In : 08:00"),
        Text("Check Out : 17:00"),
        Text("Jam Kerja : 9 Jam"),
      ],
    ),
  );
}