import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screens/settings_screen.dart';
import '../utils/app_colors.dart';
import '../models/user.dart';
import 'dart:io';

class HeaderHome extends StatelessWidget {
  final User user;

  const HeaderHome({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),

        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2563EB),
            Color(0xFF3B82F6),
          ],
        ),

        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(.25),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [

              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.18),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(.35),
                  ),
                ),
                child: ClipOval(
                  child: user.photo != null &&
                          user.photo!.isNotEmpty
                      ? Image.file(
                          File(user.photo!),
                          fit: BoxFit.cover,
                          width: 58,
                          height: 58,
                        )
                      : const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 30,
                        ),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    Text(
                      "Bonjour 👋",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      user.name,
                      style: GoogleFonts.poppins(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.15),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.settings,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const SettingsScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Text(
            "Vos idées toujours à portée de main",
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: Colors.white.withOpacity(.90),
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 6),
        ],
      ),
    );
  }
}