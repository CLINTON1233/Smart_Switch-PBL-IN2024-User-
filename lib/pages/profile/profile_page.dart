import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_switch/pages/auth/login_page.dart';
import 'package:smart_switch/pages/home/home_page.dart';
import 'package:smart_switch/pages/education/education_page.dart';
import 'package:smart_switch/services/firestore_auth_services.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _newPasswordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreAuthService _firestoreService = FirestoreAuthService();

  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      // Load data from Firestore
      try {
        Map<String, dynamic>? userData = await _firestoreService.getUserData(
          user.uid,
        );
        if (userData != null) {
          usernameController.text = userData['username'] ?? '';
          emailController.text = userData['email'] ?? '';
        } else {
          // Fallback to FirebaseAuth data
          usernameController.text = user.displayName ?? '';
          emailController.text = user.email ?? '';
        }
      } catch (e) {
        // Fallback to FirebaseAuth data
        usernameController.text = user.displayName ?? '';
        emailController.text = user.email ?? '';
      }
    }
  }

  void _showReLoginDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: Theme.of(context).copyWith(
            textTheme: GoogleFonts.poppinsTextTheme(
              Theme.of(context).textTheme,
            ),
          ),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 40,
            ),
            content: const Text(
              "Profile berhasil disimpan \nSilakan login kembali",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13), // akan terpengaruh oleh Poppins
            ),
            actions: <Widget>[
              Center(
                child: TextButton(
                  child: const Text(
                    "OK",
                    style: TextStyle(color: Color(0xFF5CB0AC)),
                  ),
                  onPressed: () async {
                    await _auth.signOut();
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    // Validasi password
    if (newPasswordController.text.isNotEmpty &&
        newPasswordController.text != confirmPasswordController.text) {
      _showErrorDialog('Password baru dan konfirmasi password tidak sama!');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    User? user = _auth.currentUser;

    try {
      if (user != null) {
        // Update username di Firestore
        if (usernameController.text.trim().isNotEmpty) {
          await _firestoreService.updateUserData(
            userId: user.uid,
            data: {'username': usernameController.text.trim()},
          );

          // Update displayName di FirebaseAuth juga
          await user.updateDisplayName(usernameController.text.trim());
          await user.reload();
          user = _auth.currentUser;
        }

        // Update password jika diisi
        if (newPasswordController.text.isNotEmpty) {
          await user!.updatePassword(newPasswordController.text);
          _showReLoginDialog();
          return;
        }

        // Jika tidak ganti password, tampilkan dialog sukses
        if (newPasswordController.text.isEmpty) {
          _showSuccessDialog('Profil berhasil disimpan!');
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = e.message ?? "Terjadi kesalahan saat update profile.";
      _showErrorDialog(message);
    } catch (e) {
      _showErrorDialog("Terjadi kesalahan: $e");
    } finally {
      setState(() {
        _isLoading = false;
        newPasswordController.clear();
        confirmPasswordController.clear();
      });
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 40,
            ),
            content: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                child: const Text(
                  'OK',
                  style: TextStyle(color: Color(0xFF5CB0AC)),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Icon(Icons.error, color: Colors.red, size: 40),
            content: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                child: const Text(
                  'OK',
                  style: TextStyle(color: Color(0xFF5CB0AC)),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
    );
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
    }
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    required IconData icon,
    bool readOnly = false,
    bool obscureText = false,
    bool? passwordVisible,
    VoidCallback? togglePasswordVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: readOnly ? const Color(0xFFF5F5F5) : const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: readOnly ? Colors.grey.shade300 : Colors.grey.shade200,
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            obscureText: obscureText,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: readOnly ? Colors.grey.shade600 : Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              prefixIcon: Icon(icon, color: Colors.grey.shade600, size: 20),
              suffixIcon:
                  togglePasswordVisibility != null
                      ? IconButton(
                        icon: Icon(
                          passwordVisible!
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                        onPressed: togglePasswordVisibility,
                      )
                      : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 13, 138, 117),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Picture Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade200,
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 36,
                          height: 30,
                          decoration: const BoxDecoration(
                            color: Color(0xFF5CB0AC),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Form Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputField(
                    controller: usernameController,
                    label: 'Username',
                    placeholder: 'putri',
                    icon: Icons.person_outline,
                  ),

                  const SizedBox(height: 10),

                  _buildInputField(
                    controller: emailController,
                    label: 'Email',
                    placeholder: 'putri@gmail.com',
                    icon: Icons.email_outlined,
                    readOnly: true,
                  ),

                  const SizedBox(height: 10),

                  _buildInputField(
                    controller: newPasswordController,
                    label: 'Kata Sandi Baru',
                    placeholder: 'Masukkan Kata Sandi Baru',
                    icon: Icons.lock_outline,
                    obscureText: !_newPasswordVisible,
                    passwordVisible: _newPasswordVisible,
                    togglePasswordVisibility: () {
                      setState(() {
                        _newPasswordVisible = !_newPasswordVisible;
                      });
                    },
                  ),

                  const SizedBox(height: 10),

                  _buildInputField(
                    controller: confirmPasswordController,
                    label: 'Konfirmasi Kata Sandi',
                    placeholder: 'Masukkan Konfirmasi Kata Sandi',
                    icon: Icons.lock_outline,
                    obscureText: !_confirmPasswordVisible,
                    passwordVisible: _confirmPasswordVisible,
                    togglePasswordVisibility: () {
                      setState(() {
                        _confirmPasswordVisible = !_confirmPasswordVisible;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          13,
                          138,
                          117,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ),
                      child:
                          _isLoading
                              ? const SizedBox(
                                width: 10,
                                height: 10,
                                child: CircularProgressIndicator(
                                  color: const Color.fromARGB(
                                    255,
                                    13,
                                    138,
                                    117,
                                  ),
                                  strokeWidth: 2,
                                ),
                              )
                              : Text(
                                'Simpan',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF5CB0AC),
        unselectedItemColor: Colors.grey[600],
        selectedIconTheme: const IconThemeData(size: 24),
        unselectedIconTheme: const IconThemeData(size: 22),
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF5CB0AC),
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Colors.grey[600],
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
