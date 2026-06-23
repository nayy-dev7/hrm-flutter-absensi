import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:absensi/config/config.dart';

class HrPage extends StatefulWidget {
  const HrPage({super.key});

@override
State<HrPage> createState() =>
    _HrPageState();
}

class _HrPageState
    extends State<HrPage> {
      
  int currentRequest = 0;
  int selectedMonth = DateTime.now().month;

  @override

  void initState() {
    super.initState();
    getLeaveHistory();
    getReport();
    getPayroll();
  }
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
  List<dynamic> approvalData = [];
  bool isLoading = true;
  bool payrollAvailable = false;
  int hadir = 0;
  int terlambat = 0;
  int lembur = 0;
  int alpha = 0;
  double gajiPokok = 0;
  double tunjanganHadir = 0;
  double bonusLembur = 0;
  double potonganTelat = 0;
  double totalGaji = 0;

  Future<void> getLeaveHistory() async {
    final prefs = await SharedPreferences.getInstance();

    int employeeId = prefs.getInt("employee_id") ?? 0;
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/leaves/$employeeId"),
      );

      print(response.body);

      if (response.statusCode != 200) return;

      final data = jsonDecode(response.body);

      if (!mounted) return;

      setState(() {
        approvalData = data;
        isLoading = false;
      });
    } catch (e, s) {
      print(e);
      print(s);
    }
  }

  Future<void> getReport() async {
    final prefs = await SharedPreferences.getInstance();

    int employeeId = prefs.getInt("employee_id") ?? 0;

    final response = await http.get(
      Uri.parse(
        "${ApiConfig.baseUrl}/attendance/report/$employeeId/$selectedMonth",
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (!mounted) return;

      setState(() {
        hadir = data["hadir"];
        terlambat = data["terlambat"];
        lembur = data["lembur"];
        alpha = data["alpha"];
      });
    }
  }

  Future<void> getPayroll() async {
    final prefs = await SharedPreferences.getInstance();
    int employeeId = prefs.getInt("employee_id") ?? 0;

    try {
      final response = await http.get(
        Uri.parse(
          "${ApiConfig.baseUrl}/payrolls/$employeeId/$selectedMonth/${DateTime.now().year}",
        ),
      );

      print(response.statusCode);
      print(response.body);

      if (!mounted) return;

      if (response.statusCode != 200) {
        setState(() {
          payrollAvailable = false;
        });
        return;
      }

      final data = jsonDecode(response.body);

      setState(() {
        payrollAvailable = true;
        gajiPokok = double.tryParse(data["gaji_pokok"].toString()) ?? 0;
        tunjanganHadir = double.tryParse(data["tunjangan_hadir"].toString()) ?? 0;
        bonusLembur = double.tryParse(data["bonus_lembur"].toString()) ?? 0;
        potonganTelat = double.tryParse(data["potongan_telat"].toString()) ?? 0;
        totalGaji = double.tryParse(data["total_gaji"].toString()) ?? 0;
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
          "HR Report",
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
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            )
          else if (approvalData.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Text("Belum ada pengajuan cuti", style: TextStyle(fontSize: 16),),
              ),
            )
          else ...[

          // HEADER REPORT
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
                    "Laporan Bulanan",
                    style: TextStyle(
                      color:
                          Colors.white70,
                    ),
                  ),

                  SizedBox(height: 8),

                  DropdownButton<int>(
                    value: selectedMonth,
                    dropdownColor: const Color(0xff0d6efd),
                    underline: const SizedBox(),
                    iconEnabledColor: Colors.white,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    items: List.generate(12, (index) {
                      return DropdownMenuItem(
                        value: index + 1,
                        child: Text(namaBulan[index]),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        selectedMonth = value!;
                      });
                      getReport();
                      getPayroll();
                    },
                  ),

                  SizedBox(height: 6),

                  Text(
                    "Monitoring HR & Payroll",
                    style: TextStyle(
                      color:
                          Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // STAT CARD
            Row(
              children: [

                Expanded(
                  child: statBox(
                    "Hadir",
                    hadir.toString(),
                    Colors.green,
                  ),
                ),

                const SizedBox(
                    width: 10),

                Expanded(
                  child: statBox(
                    "Terlambat",
                    terlambat.toString(),
                    Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [

                Expanded(
                  child: statBox(
                    "Lembur",
                    lembur.toString(),
                    Colors.blue,
                  ),
                ),

                const SizedBox(
                    width: 10),

                Expanded(
                  child: statBox(
                    "Alpha",
                    alpha.toString(),
                    Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              "Riwayat Pengajuan Cuti",
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            Container(
              padding:
                  const EdgeInsets.all(
                      20),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(
                        22),

                boxShadow: const [
                BoxShadow(
                  color:
                      Colors.black12,
                  blurRadius: 5,
                )
              ],
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [

                Text(
                  "Pengajuan ${approvalData[currentRequest]["jenis"]}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),

                Text(
                  "${approvalData[currentRequest]["start_date"]} - ${approvalData[currentRequest]["end_date"]}",
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),

                Text(
                  "Request ${currentRequest + 1} of ${approvalData.length}",

                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
        
                const SizedBox(height: 18),

                approvalInfo(
                  "Request",
                  approvalData[currentRequest]["jenis"]
                ),

                approvalInfo(
                  "Tanggal",
                  "${approvalData[currentRequest]["start_date"]} s/d ${approvalData[currentRequest]["end_date"]}"
                ),

                approvalInfo(
                  "Alasan",
                  approvalData[
                          currentRequest]
                      ["reason"],
                ),

                Row(
                  children: [

                    const SizedBox(
                      width: 90,

                      child: Text(
                        "Status",
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),

                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),

                      decoration: BoxDecoration(

                        color:
                            approvalData[currentRequest]
                                        ["status"] ==
                                    "approved"

                                ? Colors.green.shade100

                                : approvalData[currentRequest]
                                            ["status"] ==
                                        "rejected"

                                    ? Colors.red.shade100

                                    : Colors.orange
                                        .shade100,

                        borderRadius:
                            BorderRadius.circular(
                                20),
                      ),

                      child: Text(
                        approvalData[currentRequest]
                            ["status"],

                        style: TextStyle(

                          color:
                              approvalData[currentRequest]
                                          ["status"] ==
                                      "approved"

                                  ? Colors.green

                                  : approvalData[currentRequest]
                                              ["status"] ==
                                          "rejected"

                                      ? Colors.red

                                      : Colors.orange,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

        
                const SizedBox(height: 20),

                Row(
                  children: [

                    Expanded(
                      child:
                          OutlinedButton.icon(
                            onPressed: currentRequest < approvalData.length - 1
                            ? () {
                                setState(() {
                                  currentRequest++;
                                });
                              }
                            : null,

                        icon: const Icon(
                          Icons.arrow_back_ios,
                          size: 16,
                        ),

                        label:
                            const Text(
                          "Previous",
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: currentRequest > 0
                        ? () {
                            setState(() {
                              currentRequest--;
                            });
                          }
                        : null,

                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(
                                  0xff0d6efd),
                        ),

                        icon: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color:
                              Colors.white,
                        ),

                        label:
                            const Text(
                          "Next",
                          style:
                              TextStyle(
                            color:
                                Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              "Payroll Summary",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            if (!payrollAvailable)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Payroll untuk bulan ini belum digenerate oleh HR.",
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              payrollCard(
                "Gaji Pokok",
                "Rp ${gajiPokok.toStringAsFixed(0)}",
              ),

              payrollCard(
                "Tunjangan Hadir",
                "Rp ${tunjanganHadir.toStringAsFixed(0)}",
              ),

              payrollCard(
                "Bonus Lembur",
                "Rp ${bonusLembur.toStringAsFixed(0)}",
              ),

              payrollCard(
                "Potongan Telat",
                "- Rp ${potonganTelat.toStringAsFixed(0)}",
              ),

              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xff0d6efd),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Gaji",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Rp ${totalGaji.toStringAsFixed(0)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget statBox(
    String title,
    String value,
    Color warna,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(
              18),
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
      child: Column(
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
              height: 8),

          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight:
                  FontWeight.bold,
              color: warna,
            ),
          ),
        ],
      ),
    );
  }

  Widget payrollCard(
    String title,
    String nominal,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(
              bottom: 10),
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
        mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,
        children: [

          Text(
            title,
            style:
                const TextStyle(
              fontWeight:
                  FontWeight.w500,
            ),
          ),

          Text(
            nominal,
            style:
                const TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  Widget approvalInfo(
    String title,
    String value,
  ) {

    return Padding(
      padding:
          const EdgeInsets.only(
              bottom: 10),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,

        children: [

          SizedBox(
            width: 90,

            child: Text(
              title,
              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}