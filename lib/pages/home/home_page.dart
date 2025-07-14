import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';

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

  // User data
  String userName = 'Loading...';
  String userEmail = '';
  String currentCity = 'Batam';
  String weatherDescription = 'Cerah';
  double temperature = 28.0;
  bool isLoadingWeather = true;

  // Firebase
  late DatabaseReference _dbRef;
  StreamSubscription<DatabaseEvent>? _dataSubscription;
  bool isFirebaseConnected = false;
  bool _isLoading = true;
  DateTime? lastDataUpdate;

  // Sensor data
  double currentVoltage = 0.0;
  double currentCurrent = 0.0;
  double currentPower = 0.0;
  double currentEnergy = 0.0;
  double currentFrequency = 0.0;
  double currentPf = 0.0;
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
    _initFirebase();
    // FirebaseDatabase.instance.setLoggingEnabled(true);
  }
Future<void> _initFirebase() async {
  try {
    if (!mounted) return; // Cek jika widget masih aktif
    
    _dbRef = FirebaseDatabase.instance.ref();
    print("Firebase initialized");
    
    if (!mounted) return;
    setState(() {
      isFirebaseConnected = true;
      _isLoading = false;
    });
    
    _listenToDataChanges();
  } catch (e) {
    print("Firebase init error: $e");
    if (!mounted) return;
    setState(() {
      isFirebaseConnected = false;
      _isLoading = false;
    });
  }
}

  void _listenToDataChanges() {
    _dataSubscription?.cancel();
    
    _dataSubscription = _dbRef.onValue.listen((event) {
      final data = event.snapshot.value;
      print("Raw data from Firebase: $data");
      
      if (data != null && data is Map) {
        _processFirebaseData(Map<String, dynamic>.from(data));
      }
    }, onError: (error) {
      print("Firebase error: $error");
      setState(() => isFirebaseConnected = false);
    });
  }

  void _processFirebaseData(Map<String, dynamic> data) {
    try {
      print("Processing data: $data");
      
      // Process sensor data
      if (data.containsKey('sensor')) {
        final sensorData = data['sensor'] as Map;
        
        // PZEM data
        if (sensorData.containsKey('pzem')) {
          final pzemData = sensorData['pzem'] as Map;
          setState(() {
            currentVoltage = double.tryParse(pzemData['voltage'].toString()) ?? 0.0;
            currentCurrent = double.tryParse(pzemData['current'].toString()) ?? 0.0;
            currentPower = double.tryParse(pzemData['power'].toString()) ?? 0.0;
            currentEnergy = double.tryParse(pzemData['energy'].toString()) ?? 0.0;
            currentFrequency = double.tryParse(pzemData['frequency'].toString()) ?? 0.0;
            currentPf = double.tryParse(pzemData['power_factor'].toString()) ?? 0.0;
          });
        }
        
        // System data
        if (sensorData.containsKey('system')) {
          final systemData = sensorData['system'] as Map;
          setState(() {
            wifiRssi = int.tryParse(systemData['wifi_rssi'].toString()) ?? 0;
            lastUpdateTime = systemData['timestamp']?.toString() ?? 'N/A';
            isSwitchOn = systemData['relay_state']?.toString() == 'ON';
          });
        }
      }
      
      // Process powerData
      if (data.containsKey('powerData')) {
        final powerData = data['powerData'] as Map;
        setState(() {
          currentCurrent = double.tryParse(powerData['current'].toString()) ?? currentCurrent;
          currentEnergy = double.tryParse(powerData['energy'].toString()) ?? currentEnergy;
          currentFrequency = double.tryParse(powerData['frequency'].toString()) ?? currentFrequency;
          currentPower = double.tryParse(powerData['power'].toString()) ?? currentPower;
          currentPf = double.tryParse(powerData['powerFactor'].toString()) ?? currentPf;
        });
      }
      
      // Process relay status
      if (data.containsKey('relayStatus')) {
        setState(() => isSwitchOn = data['relayStatus']?.toString() == 'ON');
      }
      
      if (data.containsKey('relay') && data['relay'] is Map) {
        final relayData = data['relay'] as Map;
        if (relayData.containsKey('status')) {
          setState(() => isSwitchOn = relayData['status']?.toString() == 'ON');
        }
      }
      
      setState(() {
        isFirebaseConnected = true;
        lastDataUpdate = DateTime.now();
      });
      
      _updateChartData();
      
    } catch (e) {
      print("Error processing data: $e");
    }
  }

  void _updateChartData() {
    if (powerSpots.length >= 10) {
      powerSpots.removeAt(0);
      timeLabels.removeAt(0);
      for (int i = 0; i < powerSpots.length; i++) {
        powerSpots[i] = FlSpot(i.toDouble(), powerSpots[i].y);
      }
    }

    double newX = powerSpots.length.toDouble();
    powerSpots.add(FlSpot(newX, currentPower));

    DateTime now = DateTime.now();
    timeLabels.add('${now.hour}:${now.minute.toString().padLeft(2, '0')}');
  }

  Future<void> _sendControlCommand(bool isOn) async {
    try {
      String status = isOn ? 'ON' : 'OFF';
      await _dbRef.update({
        'relay/status': status,
        'relayStatus': status,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      print('Control updated: $status');
    } catch (e) {
      print('Error updating control: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update: ${e.toString()}')),
      );
    }
  }

  void _toggleSwitch(bool newValue) {
    setState(() => isSwitchOn = newValue);
    _sendControlCommand(newValue);
  }

  void _loadUserData() {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        userName = user.displayName ?? 'User';
        userEmail = user.email ?? '';
      });
    }
  }

  void _loadWeatherData() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() => isLoadingWeather = false);
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
              'Detail Sensor',
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
                    Colors.grey, // Warna icon diubah ke abu-abu
                  ),
                ),
                Expanded(
                  child: _buildSensorItem(
                    'Current',
                    '${(currentCurrent * 1000).toStringAsFixed(0)} mA',
                    Icons.battery_charging_full,
                    Colors.grey, // Warna icon diubah ke abu-abu
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
                    Colors.grey, // Warna icon diubah ke abu-abu
                  ),
                ),
                Expanded(
                  child: _buildSensorItem(
                    'Energy',
                    '${currentEnergy.toStringAsFixed(3)} kWh',
                    Icons.energy_savings_leaf,
                    Colors.grey, // Warna icon diubah ke abu-abu
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
                    Colors.grey, // Warna icon diubah ke abu-abu
                  ),
                ),
                Expanded(
                  child: _buildSensorItem(
                    'Power Factor',
                    currentPf.toStringAsFixed(2),
                    Icons.timeline,
                    Colors.grey, // Warna icon diubah ke abu-abu
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSensorItem(
                    'WiFi Strength',
                    '$wifiRssi dBm',
                    Icons.wifi,
                    Colors.grey, // Warna icon diubah ke abu-abu
                  ),
                ),
                Expanded(
                  child: _buildSensorItem(
                    'Relay Status',
                    isSwitchOn ? 'ON' : 'OFF',
                    Icons.power_settings_new,
                    isSwitchOn ? Colors.grey : Colors.grey, // Warna icon diubah ke abu-abu
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
      color: Colors.grey[200], // Latar belakang abu-abu untuk semua card
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
  void dispose() {
    _dataSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!isFirebaseConnected) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Koneksi ke Firebase terputus',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _initFirebase,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 13, 138, 117),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
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
            icon: Icon(
              isFirebaseConnected ? Icons.cloud_done : Icons.cloud_off,
              color: Colors.white,
            ),
            onPressed: () => _initFirebase(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
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
                      Icon(Icons.wb_cloudy, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        isLoadingWeather ? 'Loading...' : '${temperature.toInt()}°C, $weatherDescription',
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
                          color: isFirebaseConnected ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isFirebaseConnected ? 'Online' : 'Offline',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: isFirebaseConnected ? Colors.green : Colors.red,
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

              // Power Usage Card
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
                                  Icon(Icons.electric_bolt, color: Colors.white, size: 18),
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
                                  Icon(Icons.battery_charging_full, color: Colors.white, size: 18),
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

              // Switch Control
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
                      onTap: () => _toggleSwitch(!isSwitchOn),
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: isSwitchOn ? Colors.green.shade400 : Colors.grey.shade300,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (isSwitchOn ? const Color(0xFFABD3CC) : Colors.grey)
                                  .withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Icon(
                          isSwitchOn ? Icons.power_settings_new : Icons.power_outlined,
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
                        color: isSwitchOn ? const Color(0xFFABD3CC) : Colors.grey.shade600,
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

              // Sensor Data Display
              _buildSensorDataDisplay(),

              const SizedBox(height: 25),

              // Chart Section
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
                                color: isFirebaseConnected
                                    ? const Color.fromARGB(255, 24, 213, 141)
                                    : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isFirebaseConnected ? 'Live' : 'Offline',
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
                      child: powerSpots.isEmpty
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
                                        if (value.toInt() < timeLabels.length) {
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 8.0),
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
                                maxX: powerSpots.length > 0 ? powerSpots.length - 1 : 0,
                                minY: 0,
                                maxY: currentPower * 1.5,
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: powerSpots,
                                    isCurved: true,
                                    color: const Color.fromARGB(255, 222, 170, 72),
                                    barWidth: 3,
                                    isStrokeCapRound: true,
                                    dotData: FlDotData(show: false),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          const Color.fromARGB(255, 222, 170, 72)
                                              .withOpacity(0.3),
                                          const Color.fromARGB(255, 222, 170, 72)
                                              .withOpacity(0.1),
                                          const Color.fromARGB(255, 222, 170, 72)
                                              .withOpacity(0.05),
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
    );
  }
}