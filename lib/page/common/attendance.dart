import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  bool isLoading = false;
  File? photo;
  String? lastType; // 'checkin', 'checkout', or null
  List<dynamic> history = [];

  final String apiUrl = 'https://staff-point-352086447594.asia-southeast2.run.app/api/users/attendance';

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    final box = await Hive.openBox('authBox');
    final token = box.get('token');
    setState(() => isLoading = true);
    final res = await http.get(
      Uri.parse(apiUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final items = data['data'] ?? [];
      setState(() {
        history = items;
        lastType = items.isNotEmpty ? items[0]['attendance_type'] : null;
        isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch history")),
      );
    }
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() => photo = File(picked.path));
    }
  }

  Future<Position?> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled')),
      );
      return null;
    }

    // Request permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied')),
        );
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission permanently denied')),
      );
      return null;
    }

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> postAttendance(String type) async {
    if (photo == null) return;

    final position = await _determinePosition();
    if (position == null) return;

    setState(() => isLoading = true);
    final box = await Hive.openBox('authBox');
    final token = box.get('token');
    final request = http.MultipartRequest('POST', Uri.parse(apiUrl));

    request.headers['Authorization'] = 'Bearer $token';
    request.fields['attendanceType'] = type;
    request.fields['attendanceDate'] =
        DateTime.now().toUtc().add(const Duration(hours: 7)).toIso8601String();
    request.fields['lattitude'] = position.latitude.toString();
    request.fields['longitude'] = position.longitude.toString();
    request.files.add(await http.MultipartFile.fromPath('file', photo!.path));

    final response = await request.send();
    final respStr = await response.stream.bytesToString();
    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Success")));
      await fetchHistory();
    } else {
      final msg = json.decode(respStr)['message'] ?? "Error";
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasCheckin = lastType == 'checkin';
    final hasCheckout = lastType == 'checkout';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B9A),
        title: const Text('Presensi', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: hasCheckin || hasCheckout ? null : () async {
                await pickImage();
                if (photo != null) await postAttendance("checkin");
              },
              icon: const Icon(Icons.login),
              label: const Text("Check In"),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: hasCheckout || !hasCheckin ? null : () async {
                await pickImage();
                if (photo != null) await postAttendance("checkout");
              },
              icon: const Icon(Icons.logout),
              label: const Text("Check Out"),
            ),
            const Divider(height: 32),
            const Text("Attendance History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            for (var item in history)
              ListTile(
                leading: Icon(item['attendance_type'] == 'checkin' ? Icons.login : Icons.logout),
                title: Text(item['attendance_type']),
                subtitle: Text(item['attendance_date']),
                trailing: Image.network(item['attendance_url'], width: 40, height: 40),
              ),
          ],
        ),
      ),
    );
  }
}
