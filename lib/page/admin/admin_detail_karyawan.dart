import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:staffpoint/service/api_service.dart';

class UserDetailPage extends StatefulWidget {
  final int userId;

  const UserDetailPage({super.key, required this.userId});

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

enum TimeZone { wib, wita, wit, london }

class _UserDetailPageState extends State<UserDetailPage> {
  Map<String, dynamic>? user;
  List<dynamic> attendanceRecords = [];
  bool isLoading = true;
  String errorMessage = '';

  TimeZone selectedTimeZone = TimeZone.wib;

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  String formatAttendanceDate(String dateStr, TimeZone zone) {
    final wib = DateTime.parse(dateStr).toLocal();
    late final DateTime converted;

    switch (zone) {
      case TimeZone.wita:
        converted = wib.add(const Duration(hours: 2));
        break;
      case TimeZone.wit:
        converted = wib.add(const Duration(hours: 3));
        break;
      case TimeZone.london:
        converted = wib.subtract(const Duration(hours: 7));
        break;
      case TimeZone.wib:
      default:
        converted = wib;
    }

    return DateFormat('yyyy-MM-dd HH:mm').format(converted);
  }

  Future<void> fetchUserDetails() async {
    final box = Hive.box('authBox');
    final token = box.get('token', defaultValue: '');

    if (token.isEmpty) {
      setState(() {
        isLoading = false;
        errorMessage = 'Token not found. Please login first.';
      });
      return;
    }

    final api = ApiService();

    try {
      final userRes = await api.fetchUserById(widget.userId, token);
      final attRes = await api.fetchUserAttendance(widget.userId, token);

      if (userRes.code == 200 && attRes.code == 200) {
        setState(() {
          user =userRes.data;
          attendanceRecords = attRes.data!;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load user details.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Something went wrong.';
        isLoading = false;
      });
    }
  }

  String getTimeZoneLabel(TimeZone tz) {
    switch (tz) {
      case TimeZone.wib: return "WIB (GMT+7)";
      case TimeZone.wita: return "WITA (GMT+8)";
      case TimeZone.wit: return "WIT (GMT+9)";
      case TimeZone.london: return "London (GMT+1)";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B9A),
        title: const Text('User Profile', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : user == null
          ? const Center(child: Text("User not found."))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: user!['pfp'] != null
                  ? CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(user!['pfp']),
              )
                  : const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.deepPurple,
                child: Icon(Icons.person, color: Colors.white, size: 40),
              ),
            ),
            const SizedBox(height: 16),
            Text("Name: ${user!['name']}", style: _boldText()),
            Text("Email: ${user!['email']}"),
            Text("NPK: ${user!['npk']}"),
            Text("Phone: ${user!['phone']}"),
            Text("Address: ${user!['address']}"),
            Text("Job: ${user!['job_name']}"),
            Text("Role: ${user!['role_name']}"),
            Text("Company: ${user!['company_name']}"),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text("Timezone:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                DropdownButton<TimeZone>(
                  value: selectedTimeZone,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedTimeZone = value;
                      });
                    }
                  },
                  items: TimeZone.values.map((tz) {
                    final label = tz.name.toUpperCase();
                    return DropdownMenuItem(
                      value: tz,
                      child: Text(label),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text("Attendance History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...attendanceRecords.map((record) {
              final date = formatAttendanceDate(record['attendance_date'], selectedTimeZone);
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: Image.network(record['attendance_url'], width: 50, height: 50, fit: BoxFit.cover),
                  title: Text('${record['attendance_type'].toString().toUpperCase()} - $date'),
                  subtitle: Text('Distance: ${record['distance_m']} m'),
                ),
              );
            }).toList()
          ],
        ),
      ),
    );
  }

  TextStyle _boldText() => const TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
}