import 'package:flutter/material.dart';
import 'package:staffpoint/page/common/attendance.dart';
import 'package:staffpoint/page/common/company_profile.dart';
import 'package:staffpoint/page/user/user_list_anggota.dart';
import 'package:staffpoint/page/common/notification.dart';
import 'package:staffpoint/page/common/profile.dart';
import 'package:staffpoint/service/sse_service.dart';
import 'package:staffpoint/widgets/appbar.dart';
import 'package:staffpoint/widgets/navbar.dart';

class UserDashboardContent extends StatelessWidget {
  const UserDashboardContent({super.key});

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

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _selectedIndex = 0;
  final SseService _sseService = SseService();
  bool _hasNewNotification = false;

  static const List<Widget> _pages = <Widget>[
    UserDashboardContent(),
    UserListPage(),
    NotificationPage(),
    ProfilePage(),
  ];

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 2) {
        _hasNewNotification = false;
      }
    });
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
      color: const Color(0xFFF3E5F5),
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