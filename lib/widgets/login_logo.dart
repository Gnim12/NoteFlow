import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginLogo extends StatelessWidget {
  const LoginLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Hero(
          tag: "logo",
          child: SizedBox(
            width: 220,
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [

                /// Halo 1
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(.05),
                  ),
                ),

                /// Halo 2
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(.08),
                  ),
                ),

                /// Halo 3
                Container(
                  width: 145,
                  height: 145,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(.12),
                  ),
                ),

                /// Glow
                Container(
                  width: 115,
                  height: 115,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(.40),
                        blurRadius: 60,
                        spreadRadius: 15,
                      ),
                    ],
                  ),
                ),

                /// Cercle blanc
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.12),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                ),

                /// Icône
                ClipOval(
                  child: Image.asset(
                    "assets/icons/app_icon.png",
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 18),

        Text(
          "NoteFlow",
          style: GoogleFonts.poppins(
            fontSize: 38,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: .5,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          "Capturez • Organisez • Inspirez",
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white.withOpacity(.90),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}