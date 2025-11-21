import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rescueeats/core/error/app_exception.dart';
import 'package:rescueeats/core/model/userModel.dart';
import 'package:rescueeats/core/model/restaurantModel.dart';
import 'package:rescueeats/core/model/orderModel.dart';

class ApiService {
  static const String baseUrl = 'https://rescueeats.onrender.com/api';
  static const String _tokenKey = 'auth_token';

  // Helper to get headers with token
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Helper to handle response
  dynamic _processResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return jsonDecode(response.body);
      case 400:
        final errorMsg = _extractErrorMessage(response.body);
        throw BadRequestException(errorMsg ?? 'Invalid request. Please check your input.');
      case 401:
      case 403:
        final errorMsg = _extractErrorMessage(response.body);
        throw UnauthorisedException(errorMsg ?? 'Session expired. Please login again.');
      case 404:
        throw FetchDataException(
          'Service not found. The backend server may be starting up or unavailable. Please try again in a moment.'
        );
      case 500:
      case 502:
      case 503:
        throw FetchDataException(
          'Server error. Our team has been notified. Please try again later.'
        );
      default:
        throw FetchDataException(
          'Unable to connect to server (Error ${response.statusCode}). Please check your internet connection and try again.'
        );
    }
  }

  // Helper to extract error message from response body
  String? _extractErrorMessage(String body) {
    try {
      final json = jsonDecode(body);
      return json['message'] ?? json['error'];
    } catch (e) {
      return null;
    }
  }


  // --- AUTHENTICATION ---

  // --- AUTHENTICATION ---

  Future<UserModel> login(String email, String password) async {
    try {
      print("Attempting login to: $baseUrl/users/login");
      final response = await http.post(
        Uri.parse('$baseUrl/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'emailOrPhone': email, 'password': password}),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw AppException('Connection timeout. Server might be waking up, please try again.');
        },
      );

      print("Login Response: ${response.statusCode} ${response.body}");
      final data = _processResponse(response);
      
      // Save Token
      if (data['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, data['token']);
      }

      if (data['user'] != null) {
        return UserModel.fromJson(data['user']);
      }
      return UserModel.fromJson(data);
    } on AppException {
      rethrow;
    } catch (e) {
      print("Login Error: $e");
      if (e.toString().contains('SocketException') || e.toString().contains('Failed host lookup')) {
        throw AppException('Cannot connect to server. Please check your internet connection.');
      }
      throw AppException('Login failed: ${e.toString()}');
    }
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
    required UserRole role,
  }) async {
    try {
      print("Attempting registration to: $baseUrl/users/signup");
      final response = await http.post(
        Uri.parse('$baseUrl/users/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phoneNumber,
          'password': password,
          'role': role.name,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw AppException('Connection timeout. Server might be waking up, please try again.');
        },
      );

      print("Register Response: ${response.statusCode} ${response.body}");
      final data = _processResponse(response);

      // Save Token
      if (data['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, data['token']);
      }

      if (data['user'] != null) {
        return UserModel.fromJson(data['user']);
      }
      return UserModel.fromJson(data);
    } on AppException {
      rethrow;
    } catch (e) {
      print("Register Error: $e");
      if (e.toString().contains('SocketException') || e.toString().contains('Failed host lookup')) {
        throw AppException('Cannot connect to server. Please check your internet connection.');
      }
      throw AppException('Registration failed: ${e.toString()}');
    }
  }

  Future<UserModel> googleAuth(String idToken, UserRole role) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/google-auth'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'idToken': idToken,
          'role': role.name,
        }),
      ).timeout(const Duration(seconds: 10));

      print("Google Auth Response: ${response.statusCode} ${response.body}");
      final data = _processResponse(response);

      // Save Token
      if (data['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, data['token']);
      }

      if (data['user'] != null) {
        return UserModel.fromJson(data['user']);
      }
      return UserModel.fromJson(data);
    } catch (e) {
      print("Google Auth Error: $e");
      throw AppException(e.toString());
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // --- RESTAURANTS ---

  Future<List<RestaurantModel>> getRestaurants({int page = 1, int limit = 20}) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/restaurants?page=$page&limit=$limit'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      final data = _processResponse(response);
      // Assuming data is { restaurants: [], ... } or just []
      final List<dynamic> list = data['restaurants'] ?? data;
      return list.map((e) => RestaurantModel.fromJson(e)).toList();
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  // --- ORDERS ---

  Future<List<OrderModel>> getOrders({int page = 1, int limit = 20}) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/orders?page=$page&limit=$limit'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      final data = _processResponse(response);
      // Assuming data is { orders: [], ... } or just []
      final List<dynamic> list = data['orders'] ?? data;
      return list.map((e) => OrderModel.fromJson(e)).toList();
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  Future<OrderModel> createOrder(OrderModel order) async {
    try {
      final headers = await _getHeaders();
      // Construct body manually to match API expectation if needed, 
      // or use toJson() if it matches perfectly.
      // API expects: { restaurantId, items: [{menuId, quantity}], deliveryAddress, paymentMethod }
      final body = {
        'restaurantId': order.restaurantId,
        'items': order.items.map((e) => {'menuId': e.menuId, 'quantity': e.quantity}).toList(),
        'deliveryAddress': order.deliveryAddress,
        'paymentMethod': order.paymentMethod,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));

      final data = _processResponse(response);
      return OrderModel.fromJson(data);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  Future<void> updateOrderStatus(String id, String status) async {
    try {
      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/orders/$id/status'),
        headers: headers,
        body: jsonEncode({'status': status}),
      ).timeout(const Duration(seconds: 10));
      _processResponse(response);
    } catch (e) {
      throw AppException(e.toString());
    }
  }
}
