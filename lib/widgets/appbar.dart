import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:staffpoint/page/login_page.dart';

class StaffPointAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title = "StaffPoint";

  const StaffPointAppBar({
    super.key
  });

  Future<void> _logout(BuildContext context) async {
    await Hive.openBox('authBox');
    await Hive.box('authBox').clear();
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF6A1B9A),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
          letterSpacing: 1.2,
        ),
      ),
      elevation: 4,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Logout',
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text("Konfirmasi Logout"),
                content: const Text("Apakah Anda yakin ingin logout?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text("Batal"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text("Logout"),
                  ),
                ],
              ),
            );

            if (confirm == true) {
              await _logout(context);
            }
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
