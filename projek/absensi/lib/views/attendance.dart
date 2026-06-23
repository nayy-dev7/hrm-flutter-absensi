import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../dashboard.dart';
import '../controllers/attendance_controller.dart';
// import 'models/attendance_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:absensi/config/config.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() =>
      _AttendancePageState();
}

class _AttendancePageState
    extends State<AttendancePage> {
    final AttendanceController
      attendanceController =
          AttendanceController();
  String selectedJenis = "Izin";
  String jamSekarang = "";
  String checkIn = "--:--";
  String checkOut = "--:--";
  String status = "Belum Absen";
  String lokasi = "Kantor Pusat";

  bool sudahCheckIn = false;
  bool sudahCheckOut = false;

  String totalKerja = "-";
  String lembur = "0 Jam";

  bool lokasiValid = false;

  double jarakKantor = 0;

  DateTime? startDate;
  DateTime? endDate;
  TimeOfDay? jamMulai;
  TimeOfDay? jamSelesai;

  final TextEditingController reasonController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    jalanJam();
    cekLokasi();
    loadData();
  }

  void jalanJam() async {

    while (mounted) {
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      final now = DateTime.now();

      setState(() {
        jamSekarang =
            "${now.hour.toString().padLeft(2, '0')}:"
            "${now.minute.toString().padLeft(2, '0')}:"
            "${now.second.toString().padLeft(2, '0')}";
      });
    }
  }
  Future<void> loadData() async {
    final data = await attendanceController.getData();

    if (!mounted) return;

    setState(() {
      checkIn = data["checkIn"]!;
      checkOut = data["checkOut"]!;
      status = data["status"]!;
      totalKerja = data["totalKerja"]!;
      lembur = data["lembur"]!;

      sudahCheckIn = checkIn != "--:--";
      sudahCheckOut = checkOut != "--:--";
    });
  }

  Future<void> cekLokasi() async {

    bool serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return;
    }

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission =
          await Geolocator.requestPermission();
    }

    if (permission ==
            LocationPermission.denied ||
        permission ==
            LocationPermission.deniedForever) {
      return;
    }

    Position posisi =
        await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    double kantorLat = -7.1510764372179825;
    double kantorLong = 113.49882830021474;

    double jarak =
        Geolocator.distanceBetween(
      posisi.latitude,
      posisi.longitude,
      kantorLat,
      kantorLong,
    );

    if (!mounted) return;

    setState(() {
      jarakKantor = jarak;
      lokasiValid = true;
      print(lokasiValid);
    });
  }

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xfff5f7fb),

      appBar: AppBar(
        backgroundColor:
            const Color(0xff0d6efd),
        foregroundColor:
            Colors.white,
        title:
            const Text("Attendance"),
        centerTitle: true,
        elevation: 0,
      ),

      body: ListView(
        padding:
            const EdgeInsets.all(16),
        children: [

          // HEADER
          Container(
            padding:
                const EdgeInsets.all(
                    20),

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

                const Icon(
                  Icons.location_on,
                  color:
                      Colors.white,
                  size: 40,
                ),

                const SizedBox(
                    height: 10),

                Text(
                  lokasi,

                  style:
                      const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                    height: 8),

                Text(
                  lokasiValid
                      ? "Lokasi Valid"
                      : "Di Luar Area Kantor",

                  style: TextStyle(
                    color: lokasiValid
                        ? Colors.white70
                        : Colors.red.shade100,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "Jarak : ${jarakKantor.toStringAsFixed(0)} Meter",

                  style: const TextStyle(
                    color:
                        Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // CLOCK
          Container(
            padding:
                const EdgeInsets.all(
                    18),

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
                )
              ],
            ),

            child: Column(
              children: [

                const Text(
                  "Jam Sekarang",

                  style: TextStyle(
                    color:
                        Colors.grey,
                  ),
                ),

                const SizedBox(
                    height: 10),

                Text(
                  jamSekarang,

                  style:
                      const TextStyle(
                    fontSize: 34,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Color(
                            0xff0d6efd),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // CHECK DATA
          Row(
            children: [

              Expanded(
                child: infoBox(
                  "Check In",
                  checkIn,
                  Colors.green,
                ),
              ),

              const SizedBox(
                  width: 12),

              Expanded(
                child: infoBox(
                  "Check Out",
                  checkOut,
                  Colors.orange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // STATUS
          Container(
            padding:
                const EdgeInsets.all(
                    18),

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
                  blurRadius: 5,
                )
              ],
            ),

            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,

              children: [

                const Text(
                  "Status",

                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                Text(
                  status,

                  style:
                      const TextStyle(
                    color:
                        Color(
                            0xff0d6efd),

                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // BUTTON
          Row(
            children: [

              Expanded(
                child:
                    ElevatedButton(

                  onPressed: () async {

                    // if (!lokasiValid) {

                    //   ScaffoldMessenger.of(context)
                    //       .showSnackBar(
                    //     const SnackBar(
                    //       content: Text(
                    //         "Anda di luar area kantor",
                    //       ),
                    //     ),
                    //   );

                    //   return;
                    // }

                    final now = DateTime.now();

                    if (sudahCheckIn) {

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Sudah check in hari ini",
                          ),
                        ),
                      );

                      return;
                    }

                    if (
                        !attendanceController
                            .bolehCheckIn(now)
                    ) {

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Check in dimulai jam 07:00",
                          ),
                        ),
                      );

                      return;
                    }

                    setState(() {
                      checkIn =
                          "${now.hour.toString().padLeft(2, '0')}:"
                          "${now.minute.toString().padLeft(2, '0')}";

                      sudahCheckIn = true;

                      if (attendanceController.telat(now)) {
                        status = "Terlambat";
                      } else {
                        status = "Hadir";
                      }
                    });

                    final prefs = await SharedPreferences.getInstance();

                      int employeeId =
                          prefs.getInt("employee_id") ?? 0;

                      final response = await http.post(
                        Uri.parse(
                          "${ApiConfig.baseUrl}/attendance/checkin",
                        ),
                        body: {
                          "employee_id": employeeId.toString(),
                        },
                      );
                      
                      print(response.body);
                      
                      if (mounted) {
                        await loadData();
                      }
                  },

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.green,

                    minimumSize:
                        const Size(
                            0, 55),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                              16),
                    ),
                  ),

                  child:
                      const Text(
                    "CHECK IN",

                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                  width: 12),

              Expanded(
                child:
                    ElevatedButton(

                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();

                    int employeeId = prefs.getInt("employee_id") ?? 0;
                    // if (!lokasiValid) {

                    //   ScaffoldMessenger.of(context)
                    //       .showSnackBar(
                    //     const SnackBar(
                    //       content: Text(
                    //         "Anda di luar area kantor",
                    //       ),
                    //     ),
                    //   );

                    //   return;
                    // }

                    final now = DateTime.now();

                    if (!sudahCheckIn) {

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Harus check in dulu",
                          ),
                        ),
                      );

                      return;
                    }

                    if (sudahCheckOut) {

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Sudah check out hari ini",
                          ),
                        ),
                      );

                      return;
                    }

                    if (
                        !attendanceController
                            .bolehCheckOut(now)
                    ) {

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Check out dimulai jam 16:00",
                          ),
                        ),
                      );

                      return;
                    }
                    if (checkIn == "--:--" ||
                        checkIn.isEmpty ||
                        !checkIn.contains(":")) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Data Check In tidak valid"),
                        ),
                      );
                      return;
                    }

                    DateTime masuk = DateTime(
                      now.year,
                      now.month,
                      now.day,
                      int.parse(checkIn.split(":")[0]),
                      int.parse(checkIn.split(":")[1]),
                    );

                    totalKerja =
                        attendanceController
                            .hitungTotalKerja(

                      masuk: masuk,
                      keluar: now,
                    );
                      lembur =
                          attendanceController
                              .hitungLembur(now);
                    setState(() {
                      checkOut =
                          "${now.hour.toString().padLeft(2, '0')}:"
                          "${now.minute.toString().padLeft(2, '0')}";

                      sudahCheckOut = true;
                    });

                    final response = await http.post(
                      Uri.parse(
                        "${ApiConfig.baseUrl}/attendance/checkout",
                      ),
                      body: {
                        "employee_id": employeeId.toString(),
                      },
                    );
                    print(response.body);
                    
                    if (mounted) {
                      await loadData();
                    }
                    

                    // if (mounted) {

                    //   Navigator.pushReplacement(
                    //     context,

                    //     MaterialPageRoute(
                    //       builder: (_) =>
                    //           const MainDashboard(),
                    //     ),
                    //   );
                    // }
                  },

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.orange,

                    minimumSize:
                        const Size(
                            0, 55),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                              16),
                    ),
                  ),

                  child:
                      const Text(
                    "CHECK OUT",

                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          const Text(
            "Pengajuan",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedJenis,
                    decoration: const InputDecoration(
                      labelText: "Jenis Pengajuan",
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: "Izin",
                        child: Text("Izin"),
                      ),
                      DropdownMenuItem(
                        value: "Sakit",
                        child: Text("Sakit"),
                      ),
                      DropdownMenuItem(
                        value: "Lembur",
                        child: Text("Lembur"),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedJenis = value!;
                      });
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text(
                      startDate == null
                          ? "Pilih Tanggal Mulai"
                          : startDate.toString().split(" ")[0],
                    ),
                    onTap: pickStartDate,
                  ),

                  if (selectedJenis == "Lembur") ...[
                    const Divider(),

                    ListTile(
                      leading: const Icon(Icons.access_time),
                      title: Text(
                        jamMulai == null
                            ? "Pilih Jam Mulai"
                            : jamMulai!.format(context),
                      ),
                      onTap: pickJamMulai,
                    ),

                    const Divider(),

                    ListTile(
                      leading: const Icon(Icons.access_time_filled),
                      title: Text(
                        jamSelesai == null
                            ? "Pilih Jam Selesai"
                            : jamSelesai!.format(context),
                      ),
                      onTap: pickJamSelesai,
                    ),
                  ] else ...[
                    const Divider(),

                    ListTile(
                      leading: const Icon(Icons.calendar_month),
                      title: Text(
                        endDate == null
                            ? "Pilih Tanggal Selesai"
                            : endDate.toString().split(" ")[0],
                      ),
                      onTap: pickEndDate,
                    ),
                  ],

                  const SizedBox(height: 12),

                  TextField(
                    controller: reasonController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Catatan",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: submitLeave,
                      child: const Text("Ajukan Pengajuan"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Future<void> pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        startDate = picked;
      });
    }
  }

  Future<void> pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: startDate ?? DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        endDate = picked;
      });
    }
  }
  Future<void> pickJamMulai() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        jamMulai = picked;
      });
    }
  }

  Future<void> pickJamSelesai() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        jamSelesai = picked;
      });
    }
  }
  Future<void> submitLeave() async {
    if (selectedJenis == "Lembur") {
      if (startDate == null ||
          jamMulai == null ||
          jamSelesai == null ||
          reasonController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Lengkapi semua data lembur"),
          ),
        );
        return;
      }
    } else {
      if (startDate == null ||
          endDate == null ||
          reasonController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Lengkapi semua data pengajuan"),
          ),
        );
        return;
      }
    }
    final prefs = await SharedPreferences.getInstance();

    int employeeId = prefs.getInt("employee_id") ?? 0;

    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/leaves"),
      body: {
        "employee_id": employeeId.toString(),
        "jenis": selectedJenis,
        "start_date": startDate!.toString().split(" ")[0],
        "end_date": selectedJenis == "Lembur"
            ? startDate!.toString().split(" ")[0]
            : endDate!.toString().split(" ")[0],
        "reason": reasonController.text,
        "jam_mulai": selectedJenis == "Lembur"
            ? "${jamMulai!.hour.toString().padLeft(2, '0')}:${jamMulai!.minute.toString().padLeft(2, '0')}"
            : "",

        "jam_selesai": selectedJenis == "Lembur"
            ? "${jamSelesai!.hour.toString().padLeft(2, '0')}:${jamSelesai!.minute.toString().padLeft(2, '0')}"
            : "",
      },
    );
    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pengajuan berhasil"),
        ),
      );

      reasonController.clear();

      setState(() {
        startDate = null;
        endDate = null;
        jamMulai = null;
        jamSelesai = null;
        selectedJenis = "Izin";
        reasonController.clear();
      });
    }
  }

  Widget infoBox(
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
                20),

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
              fontSize: 22,
              color: warna,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}