import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_switch_baru/pages/auth/login_page.dart';
import 'package:smart_switch_baru/pages/education/education_page.dart';
import 'package:smart_switch_baru/pages/home/home_page.dart';
import 'package:smart_switch_baru/services/realtime_auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  final String userId;
  final String email;

  const ProfilePage({super.key, required this.userId, required this.email});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final RealtimeAuthService _authService = RealtimeAuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _newPasswordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _isLoading = false;
  String userName = 'Loading...';
  String userEmail = '';

  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final userData = await _authService.getUserData(widget.email);
      if (userData['success']) {
        setState(() {
          usernameController.text = userData['username'] ?? '';
          emailController.text = userData['email'] ?? '';
          userName = userData['username'] ?? '';
          userEmail = userData['email'] ?? '';
        });
      } else {
        _showErrorDialog(userData['message']);
      }
    } catch (e) {
      _showErrorDialog('Terjadi kesalahan saat memuat data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
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
            content: Text(
              "Profil berhasil disimpan\nSilakan login kembali",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            actions: <Widget>[
              Center(
                child: TextButton(
                  child: const Text(
                    "OK",
                    style: TextStyle(color: Color(0xFF6BB5A6)),
                  ),
                  onPressed: () {
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
    if (newPasswordController.text.isNotEmpty &&
        newPasswordController.text != confirmPasswordController.text) {
      _showErrorDialog('Password baru dan konfirmasi password tidak sama!');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.updateUserProfile(
        userId: widget.userId,
        username: usernameController.text.trim(),
        password:
            newPasswordController.text.isNotEmpty
                ? newPasswordController.text.trim()
                : null,
      );

      if (result['success']) {
        setState(() {
          userName = usernameController.text.trim();
        });
        if (newPasswordController.text.isNotEmpty) {
          _showReLoginDialog();
        } else {
          _showSuccessDialog('Profil berhasil disimpan!');
        }
      } else {
        _showErrorDialog(result['message']);
      }
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
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            actions: [
              TextButton(
                child: const Text(
                  'OK',
                  style: TextStyle(color: Color(0xFF6BB5A6)),
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
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            actions: [
              TextButton(
                child: const Text(
                  'OK',
                  style: TextStyle(color: Color(0xFF6BB5A6)),
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
        MaterialPageRoute(
          builder:
              (context) => HomePage(
                username:
                    usernameController.text.isNotEmpty
                        ? usernameController.text
                        : userName,
                email: widget.email,
                userId: widget.userId,
              ),
        ),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => EducationPage(
                username:
                    usernameController.text.isNotEmpty
                        ? usernameController.text
                        : userName,
                email: widget.email,
                userId: widget.userId,
              ),
        ),
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
            fontSize: 12,
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
              fontSize: 12,
              color: readOnly ? Colors.grey.shade600 : Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: GoogleFonts.poppins(
                fontSize: 12,
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
      key: _scaffoldKey,
      backgroundColor: Colors.white, // Changed to white as requested

      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 13, 138, 117),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (context) => HomePage(
                      username:
                          usernameController.text.isNotEmpty
                              ? usernameController.text
                              : userName,
                      email: widget.email,
                      userId: widget.userId,
                    ),
              ),
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
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                  children: [
                    // Profile Picture Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
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
                                  height: 36,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF6BB5A6),
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
                          const SizedBox(height: 10),
                          Text(
                            userName,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            userEmail,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Form Section
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 25,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputField(
                            controller: usernameController,
                            label: 'Username',
                            placeholder: 'Masukkan Username Baru',
                            icon: Icons.person_outline,
                          ),
                          const SizedBox(height: 16),
                          _buildInputField(
                            controller: emailController,
                            label: 'Email',
                            placeholder: 'Masukkan Email',
                            icon: Icons.email_outlined,
                            readOnly: true,
                          ),
                          const SizedBox(height: 16),
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
                          const SizedBox(height: 16),
                          _buildInputField(
                            controller: confirmPasswordController,
                            label: 'Konfirmasi Kata Sandi',
                            placeholder: 'Masukkan Konfirmasi Kata Sandi',
                            icon: Icons.lock_outline,
                            obscureText: !_confirmPasswordVisible,
                            passwordVisible: _confirmPasswordVisible,
                            togglePasswordVisibility: () {
                              setState(() {
                                _confirmPasswordVisible =
                                    !_confirmPasswordVisible;
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
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : Text(
                                        'Simpan',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
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
        selectedItemColor: const Color(0xFF6BB5A6),
        unselectedItemColor: Colors.grey[600],
        selectedIconTheme: const IconThemeData(size: 24),
        unselectedIconTheme: const IconThemeData(size: 22),
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF6BB5A6),
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
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Edukasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
