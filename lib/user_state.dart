import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'api_call_manager.dart';

class UserState with ChangeNotifier {
  static const int loggedOut = 0;
  static const int homeScreen = 1;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  int _state = loggedOut;
  String _accessToken = '';
  String _refreshToken = '';

  // Getters
  String get refreshToken => _refreshToken;

  String get accessToken => _accessToken;

  int get state => _state;

  // Initialize user from stored tokens
  Future<void> initializeUser() async {
    _accessToken = await _storage.read(key: 'accessToken') ?? '';
    _refreshToken = await _storage.read(key: 'refreshToken') ?? '';

    if (_accessToken.isNotEmpty) {
      if (JwtDecoder.isExpired(_accessToken)) {
        await refreshAccessToken();
      } else {
        _state = homeScreen;
        notifyListeners();
      }
    }
  }

  Future<void> login(String email, String password ,{String name="",phName=""}) async {
    final url = '$serverAddress/Login';

    try {
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

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

        // Save tokens securely
        await _storage.write(key: 'accessToken', value: _accessToken);
        await _storage.write(key: 'refreshToken', value: _refreshToken);

        notifyListeners();
      } else {
        throw Exception(
            'Login failed: ${jsonDecode(response.body)["message"]}');
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          throw Exception("Invalid email format.");
        case 'user-not-found':
          throw Exception("No account found with this email.");
        case 'wrong-password':
          throw Exception("Incorrect password. Please try again.");
        case 'user-disabled':
          throw Exception("This account has been disabled.");
        case 'email-already-in-use':
          throw Exception("This email is already registered.");
        case 'weak-password':
          throw Exception("Weak password. Please choose a stronger one.");
        case 'network-request-failed':
          throw Exception("Network error. Check your internet connection.");
        default:
          throw Exception("Login failed. Please check your credentials.");
      }
    } catch (e) {
      throw Exception("An unexpected error occurred. Please try again.");
    }
  }

  Future<void> signUp(String name, String pharmacyName, String email, String password) async {
    final url = '$serverAddress/sign_up';

    try {
      UserCredential userCredential;

      try {
        userCredential = await firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          // If email is already in use, just sign in the user
          userCredential = await firebaseAuth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
        } else {
          throw Exception("Firebase authentication error: ${e.message}");
        }
      }

      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({
          'name': name,
          'pharmacyName': pharmacyName,
          'email': email,
          'FB_id': userCredential.user!.uid,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        await login(email, password); // Call login after successful sign-up
      } else {
        throw Exception('Sign-up failed: ${jsonDecode(response.body)["message"]}');
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          throw Exception("Invalid email format.");
        case 'weak-password':
          throw Exception("Weak password. Please choose a stronger one.");
        case 'network-request-failed':
          throw Exception("Network error. Check your internet connection.");
        default:
          throw Exception("Sign-up failed. Please try again.");
      }
    } catch (e) {
      throw Exception("An unexpected error occurred. Please try again. $e");
    }
  }



  Future<void> refreshAccessToken() async {
    final url = '$serverAddress/Refresh';

    try {
      if (_refreshToken.isEmpty) throw Exception("No refresh token available");

      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({"refreshToken": _refreshToken}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['newAccessToken'];

        // Update stored access token
        await _storage.write(key: 'accessToken', value: _accessToken);
        notifyListeners();
      } else {
        throw Exception("Failed to refresh access token: ${response.body}");
      }
    } catch (e) {
      logout();
      rethrow;
    }
  }

  void logout() async {
    _accessToken = '';
    _refreshToken = '';
    _state = loggedOut;

    // Clear stored tokens
    await _storage.deleteAll();

    notifyListeners();
  }

  Map<String, dynamic> decodeToken() {
    return JwtDecoder.decode(_accessToken);
  }
}
