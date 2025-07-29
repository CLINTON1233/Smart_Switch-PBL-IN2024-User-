import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RelayControlCard extends StatelessWidget {
  final bool isOn;
  final String lastUpdate;
  final Function(bool) onChanged;

  const RelayControlCard({
    Key? key,
    required this.isOn,
    required this.lastUpdate,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Kendalikan saklar anda',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 24),
          Center(
            child: GestureDetector(
              onTap: () => onChanged(!isOn),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                width: 90,
                height: 70,
                decoration: BoxDecoration(
                  color: isOn ? Color(0xFF00A693) : Colors.grey[300],
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isOn ? Color(0xFF00A693) : Colors.grey)
                          .withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.power_settings_new,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ),

          SizedBox(height: 16),
          Text(
            isOn ? 'ON' : 'OFF',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isOn ? Color(0xFF00A693) : Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Terakhir diperbarui: $lastUpdate',
            style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
