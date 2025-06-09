import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:staffpoint/page/admin/admin_detail_karyawan.dart';
import 'package:staffpoint/service/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminListPage extends StatefulWidget {
  const AdminListPage({super.key});

  @override
  State<AdminListPage> createState() => _AdminListPageState();
}

class _AdminListPageState extends State<AdminListPage> {
  List<Map<String, dynamic>> allUsers = [];
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;
  String errorMessage = '';
  String searchQuery = '';

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
        final userList = List<Map<String, dynamic>>.from(data);
        setState(() {
          allUsers = userList;
          users = userList;
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

  void _searchUsers(String query) {
    setState(() {
      searchQuery = query;
      users = allUsers
          .where((user) =>
          (user['name'] ?? '').toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
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
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search by name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _searchUsers,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final name = user['name'] ?? '';
                final email = user['email'] ?? '';
                final pfp = user['pfp'];
                final jobName = user['job_name'] ?? '';

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UserDetailPage(userId: user['id']),
                        ),
                      );
                    },
                    child: ListTile(
                      leading: pfp != null && pfp.isNotEmpty
                          ? CircleAvatar(
                        backgroundImage: NetworkImage(pfp),
                      )
                          : const CircleAvatar(
                        backgroundColor: Colors.deepPurple,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(jobName),
                      trailing: IconButton(
                        icon: const Icon(Icons.email, color: Colors.deepPurple),
                        onPressed: email.isNotEmpty ? () => _openEmail(email) : null,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

