import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:staffpoint/model/user_profile.dart';
import 'package:staffpoint/service/api_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserProfile? userProfile;
  bool isLoading = true;
  final ApiService apiService = ApiService();

  static const Color _primaryColor = Color(0xFF6A1B9A);
  static const Color _textColor = Colors.black87;
  static const Color _subtitleColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      final box = await Hive.openBox('authBox');
      final token = box.get('token', defaultValue: '');

      final response = await apiService.getProfile(token);

      if (mounted) {
        if (response.code == 200) {
          final data = response.data!;
          setState(() {
            userProfile = UserProfile.fromJson(data);
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memuat profil: ${response.message}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    }
  }

  Widget buildProfileItem(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: _primaryColor, size: 28),
      title: Text(
        title,
        style: const TextStyle(
          color: _subtitleColor,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          color: _textColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: _primaryColor))
          : userProfile == null
          ? const Center(child: Text('Data profil tidak tersedia.'))
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                children: [
                  userProfile!.pfp != null && userProfile!.pfp!.isNotEmpty
                      ? CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(userProfile!.pfp!),
                  )
                      : const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.deepPurple,
                    child: Icon(Icons.person, color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userProfile!.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userProfile!.email,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(thickness: 0.5),

              buildProfileItem(CupertinoIcons.building_2_fill, 'Perusahaan', userProfile!.companyName),
              buildProfileItem(CupertinoIcons.briefcase_fill, 'Jabatan', userProfile!.jobName),
              buildProfileItem(CupertinoIcons.number, 'NPK', userProfile!.npk),
              const Divider(thickness: 0.5, indent: 16, endIndent: 16),

              buildProfileItem(CupertinoIcons.location_solid, 'Alamat', userProfile!.address),
              buildProfileItem(CupertinoIcons.phone_fill, 'Telepon', userProfile!.phone),
              const Divider(thickness: 0.5, indent: 16, endIndent: 16),

              buildProfileItem(CupertinoIcons.money_dollar, 'Gaji', "Rp ${userProfile!.salary.toString()}"),
              buildProfileItem(CupertinoIcons.lock_shield_fill, 'Role', userProfile!.roleName),
            ],
          ),
        ),
      ),
    );
  }
}