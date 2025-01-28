import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'api_call_manager.dart';

class StateManager with ChangeNotifier {
  static const int loggedOut = 0;
  static const int homeScreen = 1;

  int _state = loggedOut;
  String _accessToken = '';
  String _refreshToken = '';
  int _pharmacyIndex = 0;

  // Getters
  String get refreshToken => _refreshToken;

  String get accessToken => _accessToken;

  int get state => _state;

  int get pharmacyIndex => _pharmacyIndex;

  Future<void> refreshAccessToken() async {
    final url = '$serverAddress/Refresh';

    try {
      if (refreshToken.isEmpty) throw Exception("No refresh token available");

      // Simulated API call
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({"refreshToken": refreshToken}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['newAccessToken'];

        notifyListeners();
      } else {
        throw Exception("Failed to refresh access token: ${response.body}");
      }
    } catch (e) {
      logout();
      rethrow;
    }
  }

  final FirebaseAuth FBauth = FirebaseAuth.instance;

  Future<void> login(String email, String password) async {
    final url = '$serverAddress/Login';

    try {
      UserCredential userCredential = await FBauth.signInWithEmailAndPassword(
          email: email, password: password);

      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({'FB_id': userCredential.user!.uid}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['Token'];
        _refreshToken = data['RefreshToken'];
        _state = homeScreen;

        notifyListeners();
      } else {
        throw Exception('Login failed: ${response.body}');
      }
    } catch (error) {
      rethrow;
    }
  }

  void logout() {
    _accessToken = '';
    _refreshToken = '';
    _state = loggedOut;
    notifyListeners();
  }

  Map<String, dynamic> decodeToken() {
    Map<String, dynamic> decoded = JwtDecoder.decode(_accessToken);
    return decoded;
  }
}
