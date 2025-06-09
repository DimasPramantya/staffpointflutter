import 'package:flutter/material.dart';
import 'package:staffpoint/page/common/attendance.dart';
import 'package:staffpoint/page/common/company_profile.dart';
import 'package:staffpoint/page/admin/admin_create_user.dart';
import 'package:staffpoint/page/admin/admin_list_anggota.dart';
import 'package:staffpoint/page/common/notification.dart';
import 'package:staffpoint/page/common/profile.dart';
import 'package:staffpoint/service/sse_service.dart';
import 'package:staffpoint/widgets/appbar.dart';
import 'package:staffpoint/widgets/navbar.dart';

class AdminDashboardContent extends StatelessWidget {
  const AdminDashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 16),
        MenuItemCard(
          icon: Icons.fingerprint,
          title: 'Presensi',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AttendancePage()),
            );
          },
        ),
        MenuItemCard(
          icon: Icons.person_add,
          title: 'Daftarkan Anggota',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AnggotaFormPage()),
            );
          },
        ),
        MenuItemCard(
          icon: Icons.business,
          title: 'Profil Perusahaan',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CompanyProfilePage()),
            );
          },
        ),
        MenuItemCard(
          icon: Icons.comment,
          title: 'Kesan Mata Kuliah Teknologi Mobile',
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Kesan Teknologi Mobile'),
                content: const Text(
                  'Mata kuliah ini sangat menantang dan menarik. Saya belajar membangun aplikasi mobile secara nyata menggunakan Flutter!',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tutup'),
                  )
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  bool _hasNewNotification = false;
  final SseService _sseService = SseService();

  static const List<Widget> _pages = <Widget>[
    AdminDashboardContent(),
    UserListPage(),
    NotificationPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 2) {
        _hasNewNotification = false;
      }
    });
  }

  void _onNewEvent(Map<String, dynamic> data) {
    setState(() {
      _hasNewNotification = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(data['message'] ?? "Notifikasi baru")),
    );
  }

  @override
  void initState() {
    super.initState();
    _sseService.connectToCompanyStream(_onNewEvent);
  }

  @override
  void dispose() {
    _sseService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: const StaffPointAppBar(),
      body: _pages.elementAt(_selectedIndex),

      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        hasNotification: _hasNewNotification,
      ),
    );
  }
}

class MenuItemCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const MenuItemCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });


  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFF3E5F5), // Ungu muda
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF6A1B9A)),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF4A148C),
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}