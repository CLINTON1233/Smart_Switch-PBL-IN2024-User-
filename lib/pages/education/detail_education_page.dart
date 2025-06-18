import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_switch/pages/education/education_page.dart';
import 'package:smart_switch/pages/home/home_page.dart';
import 'package:smart_switch/pages/profile/profile_page.dart';

class DetailEducationPage extends StatefulWidget {
  final String imagePath;
  final String title;
  final String difficulty;
  final String estimatedTime;

  const DetailEducationPage({
    super.key,
    required this.imagePath,
    this.title =
        'Bagaimana cara mengukur daya, arus, tegangan, dan hambatan yang benar ?',
    this.difficulty = 'MUDAH',
    this.estimatedTime = '10-15 menit',
  });

  @override
  State<DetailEducationPage> createState() => _DetailEducationPageState();
}

class _DetailEducationPageState extends State<DetailEducationPage> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const EducationPage()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toUpperCase()) {
      case 'MUDAH':
        return const Color(0xFF4CAF50);
      case 'SEDANG':
        return const Color(0xFFFF9800);
      case 'SULIT':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF4CAF50);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 13, 138, 117),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const EducationPage()),
            );
          },
        ),
        title: Text(
          'Detail Edukasi',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar di bagian atas detail
              Container(
                height: 200,
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    widget.imagePath,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: const Color(0xFFF0F4F0),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.school_outlined,
                                size: 48,
                                color: const Color.fromARGB(255, 13, 138, 117),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Gambar tidak ditemukan',
                                style: GoogleFonts.poppins(
                                  color: const Color.fromARGB(
                                    255,
                                    13,
                                    138,
                                    117,
                                  ),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Badges dan info
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Badge edukasi lengkap
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 13, 138, 117),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'EDUKASI LENGKAP',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Difficulty badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(widget.difficulty),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        widget.difficulty.toUpperCase(),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Info waktu estimasi
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time_outlined,
                      size: 20,
                      color: const Color.fromARGB(255, 13, 138, 117),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Estimasi waktu: ${widget.estimatedTime}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color.fromARGB(255, 13, 138, 117),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Judul materi
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  widget.title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color.fromARGB(255, 13, 15, 15),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 24),

              // Konten edukasi
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Materi Pembelajaran',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color.fromARGB(255, 12, 12, 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE8E8E8)),
                      ),
                      child: Text(
                        'Tegangan, arus, dan hambatan adalah elemen utama dalam kelistrikan. Tegangan listrik mendorong pergerakan elektron dalam rangkaian dan diukur dalam Volt (V), sedangkan arus listrik adalah aliran elektron yang diukur dalam Ampere (A). Arus terdiri dari arus searah (DC) dan arus bolak-balik (AC). Hambatan listrik berfungsi membatasi aliran arus untuk mencegah kerusakan perangkat, diukur dalam Ohm (Ω).\n\n'
                        'Hubungan ketiga komponen ini dirumuskan dalam Hukum Ohm: V=I×R = I, di mana tegangan (V) diperoleh dari arus (I) dikalikan hambatan (R). Rumus ini memudahkan perhitungan tegangan, arus, atau hambatan dalam suatu rangkaian listrik.',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xFF2E2E2E),
                          height: 1.6,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
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
