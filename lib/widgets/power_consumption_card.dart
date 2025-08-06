// widgets/power_consumption_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firebase_service.dart';
import '../models/sensor_data.dart';

class PowerConsumptionCard extends StatelessWidget {
  const PowerConsumptionCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirebaseService _firebaseService = FirebaseService();

    return StreamBuilder<SensorData>(
      stream: _firebaseService.getSensorDataStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sensors, color: Colors.grey[400], size: 32),
                SizedBox(height: 8),
                Text(
                  'Memuat data sensor...',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.red, size: 32),
                SizedBox(height: 8),
                Text(
                  'Error memuat data sensor',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.red),
                ),
              ],
            ),
          );
        }

        final sensorData = snapshot.data;

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: Offset(0, 2),
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
                    'Konsumsi Daya Listrik',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Color(0xFF00A693),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Live',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Color(0xFF00A693),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                '${sensorData?.energy.toStringAsFixed(3) ?? '0.000'} kWh',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 40),
              Container(
                height: 120,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.battery_charging_full,
                        color: Colors.grey[400],
                        size: 32,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Data konsumsi daya: ${sensorData?.energy.toStringAsFixed(3) ?? '0.000'} kWh',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
