// lib/services/firestore_auth_services.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register user dengan Firebase Auth + Firestore
  Future<User?> registerUser({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      // Cek apakah username sudah ada
      bool usernameExists = await isUsernameExists(username);
      if (usernameExists) {
        throw Exception('Username sudah digunakan');
      }

      // Cek apakah email sudah ada di Firestore
      bool emailExists = await isEmailExists(email);
      if (emailExists) {
        throw Exception('Email sudah terdaftar');
      }

      // Registrasi dengan Firebase Auth
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Simpan data ke Firestore
        await saveUserData(
          userId: credential.user!.uid,
          username: username,
          email: email,
        );

        // Update display name
        await credential.user!.updateDisplayName(username);
      }

      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e));
    } catch (e) {
      throw Exception('Gagal registrasi: $e');
    }
  }

  // Login user
  Future<User?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e));
    } catch (e) {
      throw Exception('Gagal login: $e');
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Gagal logout: $e');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e));
    } catch (e) {
      throw Exception('Gagal reset password: $e');
    }
  }

  // Menyimpan data user setelah registrasi
  Future<void> saveUserData({
    required String userId,
    required String username,
    required String email,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'username': username,
        'email': email,
        'role': 'user', // Tambahkan role
        'isActive': true, // Status aktif
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Gagal menyimpan data user: $e');
    }
  }

  // Mengambil data user berdasarkan userId
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      throw Exception('Gagal mengambil data user: $e');
    }
  }

  // Get current user data
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    if (currentUser != null) {
      return await getUserData(currentUser!.uid);
    }
    return null;
  }

  // Update data user
  Future<void> updateUserData({
    required String userId,
    Map<String, dynamic>? data,
  }) async {
    try {
      if (data != null) {
        data['updatedAt'] = FieldValue.serverTimestamp();
        await _firestore.collection('users').doc(userId).update(data);
      }
    } catch (e) {
      throw Exception('Gagal update data user: $e');
    }
  }

  // Update current user profile
  Future<void> updateCurrentUserProfile({
    String? username,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      if (currentUser != null) {
        Map<String, dynamic> updateData = {};

        if (username != null) {
          // Cek apakah username baru sudah digunakan
          bool usernameExists = await isUsernameExists(username);
          if (usernameExists) {
            throw Exception('Username sudah digunakan');
          }
          updateData['username'] = username;
          // Update display name juga
          await currentUser!.updateDisplayName(username);
        }

        if (additionalData != null) {
          updateData.addAll(additionalData);
        }

        if (updateData.isNotEmpty) {
          await updateUserData(userId: currentUser!.uid, data: updateData);
        }
      }
    } catch (e) {
      throw Exception('Gagal update profile: $e');
    }
  }

  // Cek apakah username sudah digunakan
  Future<bool> isUsernameExists(String username) async {
    try {
      // Cek di collection users
      QuerySnapshot userQuery =
          await _firestore
              .collection('users')
              .where('username', isEqualTo: username)
              .limit(1)
              .get();

      // Cek di collection admins juga untuk memastikan unique
      QuerySnapshot adminQuery =
          await _firestore
              .collection('admins')
              .where('username', isEqualTo: username)
              .limit(1)
              .get();

      return userQuery.docs.isNotEmpty || adminQuery.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Gagal cek username: $e');
    }
  }

  // Cek apakah email sudah digunakan di Firestore
  Future<bool> isEmailExists(String email) async {
    try {
      QuerySnapshot userQuery =
          await _firestore
              .collection('users')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      QuerySnapshot adminQuery =
          await _firestore
              .collection('admins')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      return userQuery.docs.isNotEmpty || adminQuery.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Gagal cek email: $e');
    }
  }

  // Hapus akun user (soft delete)
  Future<void> deleteUserAccount() async {
    try {
      if (currentUser != null) {
        // Soft delete - set status tidak aktif
        await updateUserData(
          userId: currentUser!.uid,
          data: {'isActive': false, 'deletedAt': FieldValue.serverTimestamp()},
        );

        // Hapus akun Firebase Auth
        await currentUser!.delete();
      }
    } catch (e) {
      throw Exception('Gagal menghapus akun: $e');
    }
  }

  // Handle Firebase Auth errors
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Email tidak terdaftar';
      case 'wrong-password':
        return 'Password salah';
      case 'email-already-in-use':
        return 'Email sudah terdaftar';
      case 'weak-password':
        return 'Password terlalu lemah';
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'user-disabled':
        return 'Akun telah dinonaktifkan';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan, coba lagi nanti';
      default:
        return 'Terjadi kesalahan: ${e.message}';
    }
  }
}
