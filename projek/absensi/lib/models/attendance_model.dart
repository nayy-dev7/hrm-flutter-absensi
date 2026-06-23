class AttendanceModel {

  String checkIn;
  String checkOut;
  String status;
  String totalKerja;
  String lembur;

  bool sudahCheckIn;
  bool sudahCheckOut;

  AttendanceModel({

    required this.checkIn,
    required this.checkOut,
    required this.status,
    required this.totalKerja,
    required this.lembur,
    required this.sudahCheckIn,
    required this.sudahCheckOut,
  });
}