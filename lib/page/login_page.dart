import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:staffpoint/page/admin/admin_dashboard.dart';
import 'package:staffpoint/page/user/user_dashboard.dart';
import 'package:staffpoint/service/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});


  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  final apiService = ApiService();

  Future<void> _login(BuildContext context) async {
    setState(() => isLoading = true);

    try {
      final result = await apiService.login(
        usernameController.text,
        passwordController.text,
      );

      setState(() => isLoading = false);

      if (result.code == 200) {
        final token = result.data!['token'];
        final role = result.data!['role'];
        final userId = result.data!['user']['id'];
        final companyId = result.data!['user']['company_id'];

        final box = Hive.box('authBox');
        await box.put('company_id', companyId);
        await box.put('token', token);
        await box.put('role', role);
        await box.put('userId', userId);

        if (role.toLowerCase() == 'user') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const UserDashboard()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboard()));
        }
      } else {
        _showError(context, result.message);
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showError(context, 'Login failed: ${e.toString()}');
    }
  }

  void _showError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Login Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'StaffPoint Login',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.deepPurple[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'NPK or Email'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: isLoading ? null : () => _login(context),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Login'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
