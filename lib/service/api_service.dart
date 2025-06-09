import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:staffpoint/model/api_response.dart';
import 'package:staffpoint/util/encryption_decryption_util.dart';

class ApiService {
  static final String _baseUrl = dotenv.env['BASE_URL'] ?? 'https://staff-point-352086447594.asia-southeast2.run.app/api';

  Future<BaseResponse<Map<String, dynamic>>> login(String username, String password) async {
    final secretKey = dotenv.env['ENCRYPTION_KEY'] ?? '';
    final saltKey = dotenv.env['SALT_KEY'] ?? '';

    final encryption = AESGCMEncryptor(secret: secretKey, salt: saltKey);
    final encryptedUsername = encryption.encrypt(username);
    final encryptedPassword = encryption.encrypt(password);

    final uri = Uri.parse("$_baseUrl/users/login");
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      "username": encryptedUsername,
      "password": encryptedPassword,
    });

    final response = await http.post(uri, headers: headers, body: body);

    final json = jsonDecode(response.body);
    return BaseResponse<Map<String, dynamic>>.fromJson(json, (data) => data as Map<String, dynamic>);
  }

  Future<BaseResponse<List<dynamic>>> fetchUserList(String token) async {
    final uri = Uri.parse("$_baseUrl/users");

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return BaseResponse<List<dynamic>>.fromJson(json, (data) => data as List<dynamic>);
    } else {
      return BaseResponse<List<dynamic>>(
        code: response.statusCode,
        message: 'Failed to fetch user list',
        data: [],
      );
    }
  }

  Future<BaseResponse<List<dynamic>>> fetchJobList(String token) async {
    final uri = Uri.parse("$_baseUrl/jobs");

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return BaseResponse<List<dynamic>>.fromJson(json, (data) => data as List<dynamic>);
    } else {
      return BaseResponse<List<dynamic>>(
        code: response.statusCode,
        message: 'Failed to fetch job list',
        data: [],
      );
    }
  }

  Future<BaseResponse<Map<String, dynamic>>> getProfile(String token) async {
    final uri = Uri.parse("$_baseUrl/users/profile");

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return BaseResponse<Map<String, dynamic>>.fromJson(json, (data) => data as Map<String, dynamic>);
    } else {
      return BaseResponse<Map<String, dynamic>>(
        code: response.statusCode,
        message: 'Failed to fetch user profile',
        data: {},
      );
    }
  }

  Future<BaseResponse<Map<String, dynamic>>> fetchCompanyDetails(String token) async {
    final uri = Uri.parse("$_baseUrl/companies/details");

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return BaseResponse<Map<String, dynamic>>.fromJson(json, (data) => data as Map<String, dynamic>);
    } else {
      return BaseResponse<Map<String, dynamic>>(
        code: response.statusCode,
        message: 'Failed to fetch company details',
        data: {},
      );
    }
  }

  Future<BaseResponse<Map<String, dynamic>>> fetchUserById(int userId, String token) async {
    final uri = Uri.parse("$_baseUrl/users/$userId");
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return BaseResponse<Map<String, dynamic>>.fromJson(json, (data) => data as Map<String, dynamic>);
    } else {
      return BaseResponse<Map<String, dynamic>>(
        code: response.statusCode,
        message: 'Failed to fetch user',
        data: {},
      );
    }
  }

  Future<BaseResponse<List<dynamic>>> fetchUserAttendance(int userId, String token) async {
    final uri = Uri.parse("$_baseUrl/users/attendance/$userId");
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return BaseResponse<List<dynamic>>.fromJson(json, (data) => data as List<dynamic>);
    } else {
      return BaseResponse<List<dynamic>>(
        code: response.statusCode,
        message: 'Failed to fetch user attendance',
        data: [],
      );
    }
  }

}
