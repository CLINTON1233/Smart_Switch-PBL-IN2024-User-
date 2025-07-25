import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smart_switch/pages/auth/login_page.dart';
import 'package:smart_switch/pages/education/education_page.dart';
import 'package:smart_switch/pages/home/saklar2_page.dart';
import 'package:smart_switch/pages/home/saklar3_page.dart';
import 'package:smart_switch/pages/home/saklar4_page.dart';
import 'package:smart_switch/pages/profile/profile_page.dart';
import 'dart:async';
import 'dart:math';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isSwitchOn = false;
  String selectedPeriod = 'Month';

  // Variabel user dan weather
  String userName = 'Loading...';
  String userEmail = '';
  String currentCity = 'Batam';
  String weatherDescription = 'Cerah';
  double temperature = 28.0;
  bool isLoadingWeather = true;

  // Variabel sensor (dengan nilai default)
  double currentVoltage = 220.0;
  double currentCurrent = 0.5;
  double currentPower = 110.0;
  double currentEnergy = 0.0;
  double currentFrequency = 50.0;
  double currentPf = 0.99;
  int wifiRssi = 0;
  String lastUpdateTime = '';

  // Chart data
  List<FlSpot> powerSpots = [];
  List<String> timeLabels = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadWeatherData();
    _initializeMockData();
  }

  void _initializeMockData() {
    // Initialize with mock data
    setState(() {
      currentVoltage = 220.0;
      currentCurrent = 0.5;
      currentPower = 110.0;
      currentEnergy = 0.0;
      currentFrequency = 50.0;
      currentPf = 0.99;
      wifiRssi = -65;
      lastUpdateTime = 'Just now';
      isSwitchOn = false;
    });

    // Simulate periodic data updates
    Timer.periodic(const Duration(seconds: 5), (timer) {
      _updateMockData();
    });
  }

  void _updateMockData() {
    // Simulate small fluctuations in power data
    final random = Random();
    final powerChange = (random.nextDouble() * 20) - 10; // -10 to +10
    final newPower = (currentPower + powerChange).clamp(50.0, 200.0);

    setState(() {
      currentPower = newPower;
      currentCurrent = newPower / 220.0;
      currentEnergy += newPower / 3600 / 1000; // Convert to kWh
      lastUpdateTime = DateFormat('HH:mm:ss').format(DateTime.now());
    });

    _updateChartData();
  }

  void _updateChartData() {
    if (powerSpots.length >= 10) {
      powerSpots.removeAt(0);
      timeLabels.removeAt(0);

      // Update indices for remaining spots
      for (int i = 0; i < powerSpots.length; i++) {
        powerSpots[i] = FlSpot(i.toDouble(), powerSpots[i].y);
      }
    }

    double newX = powerSpots.length.toDouble();
    powerSpots.add(FlSpot(newX, currentPower));

    DateTime now = DateTime.now();
    timeLabels.add('${now.hour}:${now.minute.toString().padLeft(2, '0')}');
  }

  void _toggleSwitch(bool newValue) {
    setState(() {
      isSwitchOn = newValue;
    });
    // In a real app, you would send this command to your device
    print('Switch toggled to: $newValue');
  }

  void _loadUserData() {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        userName = user.displayName ?? 'User';
        userEmail = user.email ?? 'user@email.com';
      });
    }
  }

  void _loadWeatherData() async {
    try {
      // Simulasi data cuaca
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        currentCity = 'Batam';
        temperature = 28.0;
        weatherDescription = 'Cerah';
        isLoadingWeather = false;
      });
    } catch (e) {
      setState(() {
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

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            height: 200,
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
                      radius: 25,
                      backgroundColor: Colors.white,
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6BB5A6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      userName,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
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
                  title: 'Home',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  },
                  isActive: true,
                ),
                _buildDrawerItem(
                  icon: Icons.power_settings_new,
                  title: 'Control Saklar 2',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Saklar2Page(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.power_settings_new,
                  title: 'Control Saklar 3',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Saklar3Page(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.power_settings_new,
                  title: 'Control Saklar 4',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Saklar4Page(),
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

  Widget _buildSensorDataDisplay() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
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
              Text(
                'Sensor Data',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildSensorItem(
                      'Voltage',
                      '${currentVoltage.toStringAsFixed(1)} V',
                      Icons.electric_bolt,
                      Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: _buildSensorItem(
                      'Current',
                      '${(currentCurrent * 1000).toStringAsFixed(0)} mA',
                      Icons.battery_charging_full,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildSensorItem(
                      'Power',
                      '${currentPower.toStringAsFixed(1)} W',
                      Icons.flash_on,
                      Colors.orange,
                    ),
                  ),
                  Expanded(
                    child: _buildSensorItem(
                      'Energy',
                      '${currentEnergy.toStringAsFixed(3)} kWh',
                      Icons.energy_savings_leaf,
                      Colors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildSensorItem(
                      'Frequency',
                      '${currentFrequency.toStringAsFixed(1)} Hz',
                      Icons.waves,
                      Colors.teal,
                    ),
                  ),
                  Expanded(
                    child: _buildSensorItem(
                      'Power Factor',
                      '${currentPf.toStringAsFixed(2)}',
                      Icons.timeline,
                      Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSensorItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
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
          'Home',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_done, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, $userName',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Let\'s save the energy!',
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
                      const SizedBox(width: 12),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Online',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                isSwitchOn ? 'Saklar Aktif' : 'Saklar Tidak Aktif',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: isSwitchOn ? Colors.green : Colors.grey.shade600,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 18),

              // Statistics Cards
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 160,
                      padding: const EdgeInsets.all(20),
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
                            '${currentPower.toStringAsFixed(1)} W',
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
                                    '${currentVoltage.toStringAsFixed(1)} V',
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
                                    '${(currentCurrent * 1000).toStringAsFixed(0)} mA',
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
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Control Switch Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
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
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        _toggleSwitch(!isSwitchOn);
                      },
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color:
                              isSwitchOn
                                  ? Colors.green.shade400
                                  : Colors.grey.shade300,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (isSwitchOn
                                      ? const Color(0xFFABD3CC)
                                      : Colors.grey)
                                  .withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Icon(
                          isSwitchOn
                              ? Icons.power_settings_new
                              : Icons.power_outlined,
                          size: 35,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isSwitchOn ? 'ON' : 'OFF',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color:
                            isSwitchOn
                                ? const Color(0xFFABD3CC)
                                : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Last Update: ${lastUpdateTime.isNotEmpty ? lastUpdateTime : 'N/A'}',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Add the sensor data display here
              _buildSensorDataDisplay(),

              const SizedBox(height: 25),

              // Overview Chart Section with Cost Data
              Container(
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Power Consumption',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 24, 213, 141),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Live',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Text(
                      '${currentEnergy.toStringAsFixed(3)} kWh',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    SizedBox(
                      height: 200,
                      child:
                          powerSpots.isEmpty
                              ? Center(
                                child: Text(
                                  'Menunggu data sensor...',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              )
                              : LineChart(
                                LineChartData(
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: true,
                                    drawHorizontalLine: true,
                                    verticalInterval: 1,
                                    horizontalInterval: 500,
                                    getDrawingHorizontalLine: (value) {
                                      return FlLine(
                                        color: Colors.grey.shade200,
                                        strokeWidth: 1,
                                        dashArray: [3, 3],
                                      );
                                    },
                                    getDrawingVerticalLine: (value) {
                                      return FlLine(
                                        color: Colors.grey.shade200,
                                        strokeWidth: 1,
                                        dashArray: [3, 3],
                                      );
                                    },
                                  ),
                                  titlesData: FlTitlesData(
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 30,
                                        interval: 1,
                                        getTitlesWidget: (value, meta) {
                                          if (value.toInt() <
                                              timeLabels.length) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                top: 8.0,
                                              ),
                                              child: Text(
                                                timeLabels[value.toInt()],
                                                style: GoogleFonts.poppins(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            );
                                          }
                                          return const Text('');
                                        },
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 55,
                                        interval: 500,
                                        getTitlesWidget: (value, meta) {
                                          return Text(
                                            '${value.toInt()}W',
                                            style: GoogleFonts.poppins(
                                              color: Colors.grey.shade600,
                                              fontSize: 9,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    topTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    rightTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  minX: 0,
                                  maxX:
                                      powerSpots.length > 0
                                          ? powerSpots.length - 1
                                          : 0,
                                  minY: 0,
                                  maxY:
                                      currentPower *
                                      1.5, // Dynamic max based on current power
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: powerSpots,
                                      isCurved: true,
                                      color: const Color.fromARGB(
                                        255,
                                        222,
                                        170,
                                        72,
                                      ),
                                      barWidth: 3,
                                      isStrokeCapRound: true,
                                      dotData: FlDotData(show: false),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            const Color.fromARGB(
                                              255,
                                              222,
                                              170,
                                              72,
                                            ).withOpacity(0.3),
                                            const Color.fromARGB(
                                              255,
                                              222,
                                              170,
                                              72,
                                            ).withOpacity(0.1),
                                            const Color.fromARGB(
                                              255,
                                              222,
                                              170,
                                              72,
                                            ).withOpacity(0.05),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                    ),
                  ],
                ),
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
