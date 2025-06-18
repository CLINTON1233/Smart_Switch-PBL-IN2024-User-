import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_switch/pages/auth/login_page.dart';
import 'package:smart_switch/pages/home/home_page.dart';
import 'package:smart_switch/pages/education/education_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _passwordVisible = false;
  bool _isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      usernameController.text = user.displayName ?? '';
      emailController.text = user.email ?? '';
    }
  }

  void _showReLoginDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Icon(Icons.warning, color: Colors.orange, size: 40),
          content: const Text(
            "Silahkan login kembali",
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            Center(
              child: TextButton(
                child: const Text("OK", style: TextStyle(color: Colors.green)),
                onPressed: () async {
                  await _auth.signOut(); // Logout user
                  Navigator.of(context).pop(); // Tutup dialog
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
    });

    User? user = _auth.currentUser;

    try {
      if (user != null) {
        // Update displayName (username)
        if (usernameController.text.trim().isNotEmpty &&
            usernameController.text.trim() != user.displayName) {
          await user.updateDisplayName(usernameController.text.trim());
          await user.reload();
          user = _auth.currentUser;
        }

        // Email tidak diubah di sini karena update email perlu verifikasi & flow lain

        // Update password jika diisi
        if (passwordController.text.isNotEmpty) {
          await user!.updatePassword(passwordController.text);

          // Setelah update password, logout user dan suruh login ulang
          _showReLoginDialog();
          return;
        }

        // Jika tidak ganti password, tampilkan dialog sukses simpan profil
        if (passwordController.text.isEmpty) {
          showDialog(
            context: context,
            builder:
                (_) => AlertDialog(
                  title: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 40,
                  ),
                  content: const Text(
                    'Profil berhasil disimpan!',
                    textAlign: TextAlign.center,
                  ),
                  actions: [
                    TextButton(
                      child: const Text('OK'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      // Jika error saat update password (misal butuh recent login)
      String message = e.message ?? "Terjadi kesalahan saat update profile.";
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Icon(Icons.error, color: Colors.red, size: 40),
              content: Text(message, textAlign: TextAlign.center),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
      );
    } finally {
      setState(() {
        _isLoading = false;
        passwordController.clear();
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const EducationPage()),
      );
    } else if (index == 2) {
      // Sudah di halaman Profile
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8FA),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 13, 138, 117),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            ); // Buka drawer
          },
        ),
        title: Text(
          'Edit Profil',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(20),
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: const DecorationImage(
                  image: AssetImage('assets/account_logo_profile.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informasi Akun',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Username (dulu Nama)
                      TextField(
                        controller: usernameController,
                        decoration: InputDecoration(
                          hintText: 'Username',
                          prefixIcon: const Icon(Icons.person_outline),
                          filled: true,
                          fillColor: const Color(0xFFD0ECEC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Email (readonly)
                      TextField(
                        controller: emailController,
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: 'Email (tidak bisa diubah)',
                          prefixIcon: const Icon(Icons.email_outlined),
                          filled: true,
                          fillColor: const Color(0xFFE0E0E0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Password baru dengan icon mata
                      TextField(
                        controller: passwordController,
                        obscureText: !_passwordVisible,
                        decoration: InputDecoration(
                          hintText: 'Masukkan password baru',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: const Color(0xFFD0ECEC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Tombol Simpan
                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5CB0AC),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child:
                                _isLoading
                                    ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                    : const Text(
                                      'Simpan',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white, // Ubah dari Color(0xFFD2E3DC) ke putih
        selectedItemColor: const Color(
          0xFF6BB5A6,
        ), // Warna hijau untuk item terpilih
        unselectedItemColor:
            Colors.grey[600], // Warna abu untuk item tidak terpilih
        selectedIconTheme: const IconThemeData(
          size: 24,
        ), // Kurangi dari 30 ke 24
        unselectedIconTheme: const IconThemeData(
          size: 22,
        ), // Kurangi dari 28 ke 22
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF6BB5A6), // Sesuaikan warna text dengan icon
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Colors.grey[600], // Sesuaikan warna text dengan icon
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Education',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
