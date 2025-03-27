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
  int _pharmaIndex = 0;
  String _accessToken = '';
  String _refreshToken = '';

  // Getters
  String get refreshToken => _refreshToken;

  String get accessToken => _accessToken;

  int get state => _state;

  int get pharmaIndex => _pharmaIndex;

  // FastLogin from secure Storage
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

  Future<void> login(String email, String password,
      {String name = "", String phName = ""}) async {
    final url = '$serverAddress/Login';
    final url2 = '$serverAddress/sign_up';

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

        // Store tokens
        await _storage.write(key: 'accessToken', value: _accessToken);
        await _storage.write(key: 'refreshToken', value: _refreshToken);

        notifyListeners();
      } else if (response.statusCode == 456) {
        // User not found, proceed to sign up
        final signUpResponse = await http.post(
          Uri.parse(url2),
          body: jsonEncode({
            'name': name,
            'pharmacyName': phName,
            'email': email,
            'FB_id': userCredential.user!.uid,
          }),
          headers: {'Content-Type': 'application/json'},
        );

        if (signUpResponse.statusCode == 200) {
          // Call login again after successful sign-up
          return login(email, password);
        } else {
          throw Exception(
              'Sign-up failed: ${jsonDecode(signUpResponse.body)["message"]}');
        }
      } else {
        throw Exception(
            'Login failed: ${jsonDecode(response.body)["message"]}');
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception("An unexpected error occurred. Please try again.");
    }
  }

  Future<void> signUp(
      String name, String phName, String email, String password) async {
    try {
      //create FireBase Account
      await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      //call login
      await login(email, password, name: name, phName: phName);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception("An unexpected error occurred. Please try again. $e");
    }
  }

  Future<void> addAssistant(
      String name, String email, String password,int phIndex, APICaller apiCaller) async {
    try {

      await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String fbId = firebaseAuth.currentUser!.uid;

      String route = "$serverAddress/add_assistant";
      Map<String, dynamic> requestBody = {
        "name": name,
        "email": email,
        "FB_id": fbId,
        "index": phIndex
      };

      try {
        final response = await apiCaller.post(route, requestBody);

        if (response.statusCode == 200) {
        } else {
          throw Exception('Failed to add assistant');
        }
      } catch (e) {
        print('Error: $e');
        rethrow;
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
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

        // store tokens
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

    //Clear tokens
    await _storage.deleteAll();

    notifyListeners();
  }

  void changeIndex(int x) {
    _pharmaIndex = x;
    //print(x);
    notifyListeners();
  }

  Map<String, dynamic> decodeToken() {
    return JwtDecoder.decode(_accessToken);
  }
}
