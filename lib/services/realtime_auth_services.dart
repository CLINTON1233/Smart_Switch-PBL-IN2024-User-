import 'package:firebase_database/firebase_database.dart';

class RealtimeAuthService {
  final DatabaseReference _usersRef;

  RealtimeAuthService()
    : _usersRef = FirebaseDatabase.instance.ref().child('users');

  // Method untuk registrasi user
  Future<Map<String, dynamic>> registerUser({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      // Cek apakah email sudah terdaftar
      final emailCheck =
          await _usersRef.orderByChild('email').equalTo(email).once();

      if (emailCheck.snapshot.value != null) {
        return {'success': false, 'message': 'Email sudah terdaftar'};
      }

      // Buat data user baru
      final newUserRef = _usersRef.push();
      final userData = {
        'username': username,
        'email': email,
        'password': password,
        'createdAt': ServerValue.timestamp,
      };

      await newUserRef.set(userData);

      return {
        'success': true,
        'message': 'Registrasi berhasil!',
        'userId': newUserRef.key,
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  // Method untuk login user
  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      // Query database untuk mencari user dengan email yang sesuai
      final snapshot =
          await _usersRef.orderByChild('email').equalTo(email).once();

      if (snapshot.snapshot.value == null) {
        return {'success': false, 'message': 'Email tidak terdaftar'};
      }

      final Map<dynamic, dynamic> users =
          snapshot.snapshot.value as Map<dynamic, dynamic>;

      String? userId;
      String? username;
      bool isAuthenticated = false;

      users.forEach((key, value) {
        if (value['email'] == email && value['password'] == password) {
          isAuthenticated = true;
          userId = key;
          username = value['username'];
        }
      });

      if (isAuthenticated) {
        return {
          'success': true,
          'message': 'Login berhasil!',
          'userId': userId,
          'username': username,
        };
      } else {
        return {'success': false, 'message': 'Password salah'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  // Method untuk mengecek ketersediaan username
  Future<bool> checkUsernameAvailability(String username) async {
    try {
      final snapshot =
          await _usersRef.orderByChild('username').equalTo(username).once();

      return snapshot.snapshot.value == null;
    } catch (e) {
      return false;
    }
  }

  // Method untuk mengecek ketersediaan email
  Future<bool> checkEmailAvailability(String email) async {
    try {
      final snapshot =
          await _usersRef.orderByChild('email').equalTo(email).once();

      return snapshot.snapshot.value == null;
    } catch (e) {
      return false;
    }
  }

  // Method untuk memperbarui profil pengguna
  Future<Map<String, dynamic>> updateUserProfile({
    required String userId,
    required String username,
    String? password,
  }) async {
    try {
      // Cek apakah username baru sudah digunakan
      if (await checkUsernameAvailability(username)) {
        final userData = {
          'username': username,
          if (password != null && password.isNotEmpty) 'password': password,
        };

        await _usersRef.child(userId).update(userData);

        return {'success': true, 'message': 'Profil berhasil diperbarui!'};
      } else {
        return {
          'success': false,
          'message': 'Username sudah digunakan, silakan pilih yang lain',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  // Method untuk mendapatkan data pengguna berdasarkan email
  Future<Map<String, dynamic>> getUserData(String email) async {
    try {
      final snapshot =
          await _usersRef.orderByChild('email').equalTo(email).once();

      if (snapshot.snapshot.value == null) {
        return {'success': false, 'message': 'Pengguna tidak ditemukan'};
      }

      final Map<dynamic, dynamic> users =
          snapshot.snapshot.value as Map<dynamic, dynamic>;

      String? userId;
      String? username;
      String? userEmail;

      users.forEach((key, value) {
        userId = key;
        username = value['username'];
        userEmail = value['email'];
      });

      return {
        'success': true,
        'userId': userId,
        'username': username,
        'email': userEmail,
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }
}
