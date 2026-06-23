import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:absensi/config/config.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() =>
      _HistoryPageState();
}
class _HistoryPageState
  extends State<HistoryPage> {
    int totalKehadiran = 0;
    List<dynamic> history = [];

    int selectedMonth = DateTime.now().month;
    int selectedYear = DateTime.now().year;
    
    List<String> namaBulan = [
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember",
    ];

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int employeeId = prefs.getInt("employee_id") ?? 0;

      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/attendance/history/$employeeId"),
      );

      print(response.statusCode);
      print(response.body);

      if (response.statusCode != 200) return;

      final List data = jsonDecode(response.body);

      final filtered = data.where((item) {
        DateTime tgl = DateTime.parse(item["tanggal"]);
        return tgl.month == selectedMonth &&
              tgl.year == selectedYear;
      }).toList();

      filtered.sort((a, b) =>
        DateTime.parse(b["tanggal"])
            .compareTo(DateTime.parse(a["tanggal"])));

      if (!mounted) return;

      setState(() {
        history = filtered;
        totalKehadiran = filtered.length;
      });
    } catch (e, s) {
      print(e);
      print(s);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xfff5f7fb),

      appBar: AppBar(
        title: const Text(
          "Attendance History",
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

          // HEADER CARD
          Container(
            padding:
                const EdgeInsets.all(
                    18),
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
                      22),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [

                Text(
                  "Total Kehadiran",
                  style: TextStyle(
                    color:
                        Colors.white70,
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  "$totalKehadiran Hari",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 6),

                Text(
                  "${namaBulan[selectedMonth - 1]} $selectedYear",
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                )
              ],
            ),
          ),

          const SizedBox(height: 20),

          const SizedBox(height: 16),

          DropdownButton<int>(
            value: selectedMonth,
            isExpanded: true,
            items: List.generate(12, (index) {
              return DropdownMenuItem(
                value: index + 1,
                child: Text(namaBulan[index]),
              );
            }),
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                selectedMonth = value;
              });

              getData();
            },
          ),

          const SizedBox(height: 16),
          const Text(
            "Riwayat Absensi",
            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 14),

          if (history.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text("Belum ada data absensi"),
              ),
            )
          else
          ...history.map((item) {
            return historyCard(
              item["tanggal"] ?? "-",
              item["check_in"] ?? "-",
              item["check_out"] ?? "-",
              item["total_kerja"]?.toString() ?? "-",
              item["status"] ?? "-",
              item["status"] == "Hadir"
                  ? Colors.green
                  : item["status"] == "Terlambat"
                      ? Colors.orange
                      : Colors.red,
            );
          }).toList(),
          
        ],
      ),
    );
  }

  Widget historyCard(
    String tanggal,
    String masuk,
    String keluar,
    String total,
    String status,
    Color warna,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(
              bottom: 14),
      padding:
          const EdgeInsets.all(
              16),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
                20),
        boxShadow: const [
          BoxShadow(
            color:
                Colors.black12,
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,
        children: [

          Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,
            children: [

              Text(
                tanggal,
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration:
                    BoxDecoration(
                  color: warna,
                  borderRadius:
                      BorderRadius
                          .circular(
                              12),
                ),
                child: Text(
                  status,
                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceAround,
            children: [

              infoBox(
                "Masuk",
                masuk,
              ),

              infoBox(
                "Keluar",
                keluar,
              ),

              infoBox(
                "Total",
                total,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget infoBox(
    String title,
    String value,
  ) {
    return Column(
      children: [
        Text(
          title,
          style:
              const TextStyle(
            color:
                Colors.grey,
          ),
        ),
        const SizedBox(
            height: 6),
        Text(
          value,
          style:
              const TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ],
    );
  }
}