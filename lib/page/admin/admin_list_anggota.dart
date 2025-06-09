import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:staffpoint/service/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final box = Hive.box('authBox');
    final token = box.get('token', defaultValue: '');

    if (token.isEmpty) {
      setState(() {
        isLoading = false;
        errorMessage = 'Token not found, please login first.';
      });
      return;
    }

    final apiService = ApiService();
    final response = await apiService.fetchUserList(token);
    if (response.code == 200) {
      final data = response.data;
      if (data is List) {
        setState(() {
          users = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Unexpected data format from API.';
          isLoading = false;
        });
      }
    } else {
      setState(() {
        errorMessage = 'Failed to load users. Status code: ${response.code}';
        isLoading = false;
      });
    }
  }

  void _openEmail(String email) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    await launchUrl(emailLaunchUri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          final name = user['name'] ?? '';
          final email = user['email'] ?? '';
          final pfp = user['pfp'];

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            child: ListTile(
              leading: pfp != null && pfp.isNotEmpty
                  ? CircleAvatar(
                backgroundImage: NetworkImage(pfp),
              )
                  : const CircleAvatar(
                backgroundColor: Colors.deepPurple,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: IconButton(
                icon: const Icon(Icons.email, color: Colors.deepPurple),
                onPressed: email.isNotEmpty ? () => _openEmail(email) : null,
              ),
            ),
          );
        },
      ),
    );
  }
}
