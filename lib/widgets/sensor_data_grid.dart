// widgets/sensor_data_grid.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/sensor_data.dart';

class SensorDataGrid extends StatelessWidget {
  final SensorData? sensorData;

  const SensorDataGrid({Key? key, this.sensorData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.0,
        children: [
          _buildSensorCard(
            'Voltage',
            '${sensorData?.voltage.toStringAsFixed(1) ?? '0.0'} V',
            sensorData?.voltage ?? 0.0,
            Icons.bolt,
            Color.fromARGB(255, 253, 254, 255),
            Color(0xFF2196F3),
          ),
          _buildSensorCard(
            'Current',
            '${sensorData?.current.toStringAsFixed(0) ?? '0'} mA',
            sensorData?.current ?? 0.0,
            Icons.battery_charging_full,
            Color(0xFFE8F5E8),
            Color(0xFF4CAF50),
          ),
          _buildSensorCard(
            'Power',
            '${sensorData?.power.toStringAsFixed(1) ?? '0.0'} W',
            sensorData?.power ?? 0.0,
            Icons.flash_on,
            Color(0xFFFFF3E0),
            Color(0xFFFF9800),
          ),
          _buildSensorCard(
            'Energy',
            '${sensorData?.energy.toStringAsFixed(3) ?? '0.000'} kWh',
            sensorData?.energy ?? 0.0,
            Icons.energy_savings_leaf,
            Color(0xFFF3E5F5),
            Color(0xFF9C27B0),
          ),
          _buildSensorCard(
            'Frequency',
            '${sensorData?.frequency.toStringAsFixed(1) ?? '0.0'} Hz',
            sensorData?.frequency ?? 0.0,
            Icons.waves,
            Color(0xFFE0F2F1),
            Color(0xFF009688),
          ),
          _buildSensorCard(
            'Power Factor',
            '${sensorData?.powerFactor.toStringAsFixed(2) ?? '0.00'}',
            sensorData?.powerFactor ?? 0.0,
            Icons.trending_up,
            Color(0xFFFFEBEE),
            Color(0xFFF44336),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorCard(
    String title,
    String value,
    double valueRaw,
    IconData icon,
    Color bgColor,
    Color iconColor,
  ) {
    final bool isZero = valueRaw == 0.0;

    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isZero ? Colors.grey[300] : bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}
