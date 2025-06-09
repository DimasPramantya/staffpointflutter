import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:staffpoint/service/api_service.dart';

class AnggotaFormPage extends StatefulWidget {
  const AnggotaFormPage({super.key});

  @override
  State<AnggotaFormPage> createState() => _AnggotaFormPageState();
}

class _AnggotaFormPageState extends State<AnggotaFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController npkController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  int? selectedJobId;
  List<Map<String, dynamic>> jobs = [];
  File? selectedFile;

  @override
  void initState() {
    super.initState();
    fetchJobs();
  }

  Future<void> fetchJobs() async {
    final box = Hive.box('authBox');
    final token = box.get('token', defaultValue: '');
    final apiService = ApiService();
    final response = await apiService.fetchJobList(token);
    if (response.code == 200) {
      final data = response.data;
      setState(() {
        jobs = data!.map((e) => e as Map<String, dynamic>).toList();
        print(jobs);
      });
    }
  }

  Future<void> submitForm() async {
    if (!_formKey.currentState!.validate() || selectedJobId == null || selectedFile == null) return;

    final box = Hive.box('authBox');
    final token = box.get('token');
    final companyId = box.get('company_id');

    final uri = Uri.parse('https://staff-point-352086447594.asia-southeast2.run.app/api/users/register');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['email'] = emailController.text
      ..fields['name'] = nameController.text
      ..fields['npk'] = npkController.text
      ..fields['salary'] = salaryController.text
      ..fields['address'] = addressController.text
      ..fields['phone'] = phoneController.text
      ..fields['company_id'] = companyId.toString()
      ..fields['job_id'] = selectedJobId.toString()
      ..fields['password'] = passwordController.text
      ..files.add(await http.MultipartFile.fromPath('file', selectedFile!.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anggota berhasil didaftarkan!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFormValid = _formKey.currentState?.validate() == true && selectedJobId != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B9A),
        title: const Text('Form Registrasi Karyawan', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          onChanged: () => setState(() {}),
          child: ListView(
            children: [
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(
                height: 12,
              ),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama'),
              ),
              const SizedBox(
                height: 12,
              ),
              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Alamat'),
              ),
              const SizedBox(
                height: 12,
              ),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Telepon'),
              ),
              const SizedBox(
                height: 12,
              ),
              TextFormField(
                controller: npkController,
                decoration: const InputDecoration(labelText: 'NPK'),
              ),
              const SizedBox(
                height: 12,
              ),
              TextFormField(
                controller: salaryController,
                decoration: const InputDecoration(labelText: 'Gaji'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(
                height: 12,
              ),
              DropdownButtonFormField<int>(
                value: selectedJobId,
                decoration: const InputDecoration(labelText: 'Pilih Jabatan'),
                items: jobs.map((job) {
                  return DropdownMenuItem<int>(
                    value: job['id'],
                    child: Text(job['name']),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedJobId = value),
              ),
              const SizedBox(
                height: 12,
              ),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(
                height: 12,
              ),
              Text(selectedFile != null ? selectedFile!.path.split('/').last : 'Belum ada file'),
              TextButton.icon(
                onPressed: () async {
                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: FileType.image,
                  );
                  if (result != null) {
                    setState(() {
                      selectedFile = File(result.files.single.path!);
                    });
                  }
                },
                icon: const Icon(Icons.upload_file),
                label: const Text('Unggah Foto Profil'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isFormValid ? submitForm : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A1B9A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Daftarkan'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
