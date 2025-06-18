import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_switch/pages/auth/login_page.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/services.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSuccessDialog() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.rightSlide,
      title: 'Registrasi Berhasil',
      desc: 'Akun berhasil dibuat. Silakan login dengan akun baru Anda.',
      btnOkText: 'Login Sekarang',
      btnOkOnPress: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      },
      btnOkColor: Colors.green,
      dismissOnTouchOutside: false,
      dismissOnBackKeyPress: false,
    ).show();
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              child: Stack(
                alignment: Alignment.topLeft,
                children: [
                  Image.asset(
                    'assets/desain_kiri_atas_transparan.jpg',
                    width: 140,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 140,
                        height: 100,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 20.0),
                    child: Text(
                      'Create\nAccount',
                      style: GoogleFonts.oleoScriptSwashCaps(
                        fontSize: 25,
                        color: const Color(0xFF2C5C52),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 10,
              right: 0,
              child: Image.asset(
                'assets/splashscreen2.png',
                width: 100,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported),
                  );
                },
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 220,
                child: Image.asset(
                  'assets/hiasan_bawah.jpg',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 220,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported),
                    );
                  },
                ),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(40, 125, 40, 300),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, size: 30, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Regist Account',
                    style: GoogleFonts.oleoScriptSwashCaps(
                      fontSize: 20,
                      color: const Color(0xFF2C5C52),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(usernameController, Icons.person, 'Username'),
                  const SizedBox(height: 10),
                  _buildTextField(emailController, Icons.email, 'Email'),
                  const SizedBox(height: 10),
                  _buildTextField(
                    passwordController,
                    Icons.lock,
                    'Password',
                    isPassword: true,
                    obscureText: _obscurePassword,
                    onToggle:
                        () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    confirmPasswordController,
                    Icons.lock,
                    'Confirm Password',
                    isPassword: true,
                    obscureText: _obscureConfirmPassword,
                    onToggle:
                        () => setState(
                          () =>
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                        ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: _showSuccessDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Regist Now',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account?"),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: _navigateToLogin,
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    IconData icon,
    String hintText, {
    bool isPassword = false,
    bool? obscureText,
    VoidCallback? onToggle,
  }) {
    return SizedBox(
      height: 45,
      child: TextField(
        controller: controller,
        obscureText: obscureText ?? false,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 20),
          hintText: hintText,
          hintStyle: const TextStyle(fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 5,
          ),
          filled: true,
          fillColor: Colors.teal.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          suffixIcon:
              isPassword
                  ? IconButton(
                    icon: Icon(
                      obscureText == true
                          ? Icons.visibility_off
                          : Icons.visibility,
                      size: 20,
                    ),
                    onPressed: onToggle,
                  )
                  : null,
        ),
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}
