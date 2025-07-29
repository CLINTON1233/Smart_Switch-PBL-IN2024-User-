import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:smart_switch_baru/pages/auth/login_page.dart';
import 'package:smart_switch_baru/pages/home/home_page.dart';
import 'package:smart_switch_baru/pages/education/education_page.dart';
import 'package:smart_switch_baru/pages/profile/profile_page.dart';
import 'package:smart_switch_baru/pages/home/saklar2_page.dart';
import 'package:smart_switch_baru/pages/home/saklar4_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_switch_baru/services/weather_services.dart';
import 'package:smart_switch_baru/services/firebase_service.dart';
import 'package:smart_switch_baru/models/sensor_data.dart';
import 'package:smart_switch_baru/models/device_control.dart';

class Saklar3Page extends StatefulWidget {
  final String username;
  final String email;
  final String userId;

  const Saklar3Page({
    super.key,
    required this.username,
    required this.email,
    required this.userId,
  });

  @override
  State<Saklar3Page> createState() => _Saklar3PageState();
}

class _Saklar3PageState extends State<Saklar3Page> {
  int _selectedIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseService _firebaseService = FirebaseService();

  // Variabel untuk user dan weather
  String userName = 'Loading...';
  String userEmail = '';
  String currentCity = 'Batam';
  String weatherDescription = 'Cerah';
  double temperature = 28.0;
  bool isLoadingWeather = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadWeatherData();
  }

  // Method untuk load data user
  void _loadUserData() {
    setState(() {
      userName = widget.username;
      userEmail = widget.email;
    });
  }

  void _loadWeatherData() async {
    try {
      // Coba dapatkan lokasi saat ini
      final position = await WeatherService.getCurrentPosition();

      Map<String, dynamic> weatherData;

      if (position != null) {
        // Jika berhasil dapat lokasi, gunakan koordinat
        weatherData = await WeatherService.getWeatherByCoordinates(
          position.latitude,
          position.longitude,
        );
      } else {
        // Jika gagal, gunakan default Batam
        weatherData = await WeatherService.getWeatherByCity('Batam');
      }

      setState(() {
        currentCity = weatherData['city'] ?? 'Batam';
        temperature = weatherData['temperature'] ?? 28.0;
        weatherDescription = weatherData['description'] ?? '';
        isLoadingWeather = false;
      });
    } catch (e) {
      // Jika ada error, gunakan data default
      setState(() {
        currentCity = 'Batam';
        temperature = 28.0;
        weatherDescription = 'Cerah';
        isLoadingWeather = false;
      });
    }
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Icon(Icons.warning, color: Colors.orange, size: 40),
          content: const Text(
            "Apakah Kamu Yakin ingin Melakukan Logout?",
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  child: const Text(
                    "Tidak, Batalkan!",
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text(
                    "Ya",
                    style: TextStyle(color: Colors.green),
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
              ],
            ),
          ],
        );
      },
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
                username: widget.username,
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
                username: widget.username,
                email: widget.email,
                userId: widget.userId,
              ),
        ),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  ProfilePage(userId: widget.userId, email: widget.email),
        ),
      );
    }
  }

  // Build Drawer Menu
  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            height: 232,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color.fromARGB(255, 13, 138, 117),
                  const Color.fromARGB(255, 24, 142, 122),
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      radius: 23,
                      backgroundColor: Colors.white,
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                        style: GoogleFonts.poppins(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6BB5A6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      userName,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      userEmail,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.home_outlined,
                  title: 'Beranda',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => HomePage(
                              username: widget.username,
                              email: widget.email,
                              userId: widget.userId,
                            ),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.power_settings_new,
                  title: 'Kontrol Saklar - Ruang Tamu',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => Saklar2Page(
                              username: widget.username,
                              email: widget.email,
                              userId: widget.userId,
                            ),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.power_settings_new,
                  title: 'Kontrol Saklar - Kamar Tidur',
                  onTap: () {
                    Navigator.pop(context);
                  },
                  isActive: true,
                ),
                _buildDrawerItem(
                  icon: Icons.power_settings_new,
                  title: 'Kontrol Saklar - Dapur',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => Saklar4Page(
                              username: widget.username,
                              email: widget.email,
                              userId: widget.userId,
                            ),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.logout,
                  title: 'Logout',
                  onTap: () {
                    Navigator.pop(context);
                    _showLogoutConfirmationDialog();
                  },
                  isLogout: true,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(30),
            child: Text(
              'Version 1.0.0',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[400]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isActive = false,
    bool isLogout = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color:
            isActive
                ? const Color(0xFFABD3CC).withOpacity(0.1)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color:
              isLogout
                  ? Colors.red
                  : isActive
                  ? const Color(0xFF6BB5A6)
                  : Colors.grey[600],
          size: 24,
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color:
                isLogout
                    ? Colors.red
                    : isActive
                    ? const Color(0xFF6BB5A6)
                    : Colors.black87,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
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
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8F9FA),
      drawer: _buildDrawer(),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 13, 138, 117),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Text(
          'Saklar Kamar Tidur',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          StreamBuilder<DeviceControl>(
            stream: _firebaseService.getDeviceControlStream(),
            builder: (context, snapshot) {
              final isOnline = snapshot.hasData && snapshot.data != null;
              return Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: isOnline ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.cloud_done,
                      color: isOnline ? Colors.white : Colors.grey[400],
                    ),
                    onPressed: () {},
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section untuk Kamar Tidur
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kamar Tidur',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Kendalikan Saklar Kamar-Tidur!',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$currentCity, Kepulauan Riau',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.wb_cloudy,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isLoadingWeather
                            ? 'Loading...'
                            : '${temperature.toInt()}°C, $weatherDescription',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  StreamBuilder<DeviceControl>(
                    stream: _firebaseService.getDeviceControlStream(),
                    builder: (context, snapshot) {
                      final isOnline =
                          snapshot.hasData && snapshot.data != null;
                      final isOn = snapshot.data?.relayControl == 'ON';
                      return Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isOnline ? Colors.green : Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isOnline ? 'Online' : 'Offline',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: isOnline ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            isOn ? Icons.power_settings_new : Icons.power_off,
                            size: 14,
                            color: isOn ? Colors.green : Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isOn ? 'Saklar Aktif' : 'Saklar Tidak Aktif',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: isOn ? Colors.green : Colors.grey.shade600,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Power Usage Card
              StreamBuilder<SensorData>(
                stream: _firebaseService.getSensorDataStream(),
                builder: (context, snapshot) {
                  final sensorData = snapshot.data;
                  return Container(
                    height: 180,
                    padding: const EdgeInsets.all(20),
                    margin: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color.fromARGB(255, 222, 170, 72),
                          const Color.fromARGB(255, 219, 186, 124),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Power Usage',
                              style: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Icon(
                              Icons.arrow_downward,
                              color: Colors.white.withOpacity(0.8),
                              size: 16,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${sensorData?.power.toStringAsFixed(1) ?? '0.0'} W',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.electric_bolt,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${sensorData?.voltage.toStringAsFixed(1) ?? '0.0'} V',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.battery_charging_full,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${sensorData?.current.toStringAsFixed(0) ?? '0'} mA',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              // Control Switch Section
              StreamBuilder<DeviceControl>(
                stream: _firebaseService.getDeviceControlStream(),
                builder: (context, snapshot) {
                  final deviceControl = snapshot.data;
                  return Container(
                    width: double.infinity,
                    margin: EdgeInsets.zero,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Kendalikan saklar anda',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            _firebaseService.updateRelayControl(
                              deviceControl?.relayControl == 'ON'
                                  ? 'OFF'
                                  : 'ON',
                            );
                          },
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color:
                                  deviceControl?.relayControl == 'ON'
                                      ? const Color(0xFF00A693)
                                      : Colors.grey.shade300,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (deviceControl?.relayControl == 'ON'
                                          ? const Color(0xFFABD3CC)
                                          : Colors.grey)
                                      .withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Icon(
                              deviceControl?.relayControl == 'ON'
                                  ? Icons.power_settings_new
                                  : Icons.power_outlined,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          deviceControl?.relayControl ?? 'OFF',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color:
                                deviceControl?.relayControl == 'ON'
                                    ? const Color(0xFF00A693)
                                    : Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Terakhir diperbarui: ${deviceControl?.lastUpdate ?? 'N/A'}',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              // Informasi Penggunaan Title Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'Informasi Penggunaan Listrik',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              // Informasi Penggunaan Section - Split into two cards
              StreamBuilder<SensorData>(
                stream: _firebaseService.getSensorDataStream(),
                builder: (context, snapshot) {
                  final sensorData = snapshot.data;
                  return Column(
                    children: [
                      // Card 1: Tegangan, Arus, Daya
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.zero,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.electrical_services,
                                  color: const Color(0xFF6BB5A6),
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Pengukuran Listrik',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildInfoCard(
                              icon: Icons.bolt,
                              title: 'Tegangan Listrik',
                              value:
                                  '${sensorData?.voltage.toStringAsFixed(1) ?? '0.0'} V',
                              color: const Color(0xFF6BB5A6),
                            ),
                            const SizedBox(height: 12),
                            _buildInfoCard(
                              icon: Icons.battery_charging_full,
                              title: 'Arus Listrik yang digunakan',
                              value:
                                  '${sensorData?.current.toStringAsFixed(0) ?? '0'} mA',
                              color: const Color(0xFF6BB5A6),
                            ),
                            const SizedBox(height: 12),
                            _buildInfoCard(
                              icon: Icons.flash_on,
                              title: 'Daya Listrik yang digunakan',
                              value:
                                  '${sensorData?.power.toStringAsFixed(1) ?? '0.0'} W',
                              color: const Color(0xFF6BB5A6),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Card 2: Energi, Frekuensi, Faktor Daya
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.zero,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.analytics,
                                  color: const Color(0xFF6BB5A6),
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Analisis Daya',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildInfoCard(
                              icon: Icons.energy_savings_leaf,
                              title: 'Energi yang digunakan',
                              value:
                                  '${sensorData?.energy.toStringAsFixed(3) ?? '0.000'} kWh',
                              color: const Color(0xFF6BB5A6),
                            ),
                            const SizedBox(height: 12),
                            _buildInfoCard(
                              icon: Icons.waves,
                              title: 'Frekuensi Listrik',
                              value:
                                  '${sensorData?.frequency.toStringAsFixed(1) ?? '0.0'} Hz',
                              color: const Color(0xFF6BB5A6),
                            ),
                            const SizedBox(height: 12),
                            _buildInfoCard(
                              icon: Icons.trending_up,
                              title: 'Faktor Daya',
                              value:
                                  '${sensorData?.powerFactor.toStringAsFixed(2) ?? '0.00'}',
                              color: const Color(0xFF6BB5A6),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 25),
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

  // Helper method to build info card for sensor data
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
