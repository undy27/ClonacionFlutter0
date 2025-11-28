import 'package:flutter/material.dart';
import '../models/carta.dart';
import '../theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class CartaWidget extends StatelessWidget {
  final Carta carta;
  final String tema;
  final double width;
  final double height;
  final bool isVisible;
  final VoidCallback? onTap;

  const CartaWidget({
    super.key,
    required this.carta,
    this.tema = 'moderno', // 'clasico' or 'moderno'
    required this.width,
    required this.height,
    this.isVisible = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.border, width: 2),
            boxShadow: AppTheme.smallHardShadow,
          ),
          child: Center(
            child: Text(
              "?",
              style: GoogleFonts.lexendMega(
                fontSize: width * 0.4,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.border, width: 2),
          boxShadow: AppTheme.smallHardShadow,
        ),
        child: tema == 'clasico' ? _buildClasico() : _buildModerno(),
      ),
    );
  }

  Widget _buildClasico() {
    return Column(
      children: [
        // Top Section (Multiplications)
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF333333), width: 1.5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "${carta.multiplicaciones[0][0]}×${carta.multiplicaciones[0][1]}",
                    style: _getTextStyle(),
                    textAlign: TextAlign.left,
                  ),
                ),
                Container(width: 1.5, color: const Color(0xFF333333)),
                Expanded(
                  flex: 2,
                  child: Text(
                    "${carta.multiplicaciones[1][0]}×${carta.multiplicaciones[1][1]}",
                    style: _getTextStyle(),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Middle Section (Division)
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF333333), width: 1.5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "${carta.division[0]}:${carta.division[1]}",
                    style: _getTextStyle(),
                    textAlign: TextAlign.left,
                  ),
                ),
                Container(width: 1.5, color: const Color(0xFF333333)),
                Expanded(
                  flex: 2,
                  child: Text(
                    "${carta.multiplicaciones[2][0]}×${carta.multiplicaciones[2][1]}",
                    style: _getTextStyle(),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Bottom Section (Results)
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.fromLTRB(5, 10, 5, 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: carta.resultados
                  .map((res) => Text(res.toString(), style: _getTextStyle()))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModerno() {
    // This is a simplified programmatic version of the SVG for the 'moderno' theme
    // Ideally, we would use flutter_svg to render the actual SVG asset with data overlaid
    return Stack(
      children: [
        // Background circles for multiplications (Blue)
        Positioned(
          left: width * 0.1,
          top: height * 0.1,
          child: _buildCircle(width * 0.35, const Color(0xFF1E3A8A), "${carta.multiplicaciones[0][0]}×${carta.multiplicaciones[0][1]}"),
        ),
        Positioned(
          right: width * 0.1,
          top: height * 0.1,
          child: _buildCircle(width * 0.35, const Color(0xFF1E3A8A), "${carta.multiplicaciones[1][0]}×${carta.multiplicaciones[1][1]}"),
        ),
         Positioned(
          left: width * 0.325,
          top: height * 0.3,
          child: _buildCircle(width * 0.35, const Color(0xFF1E3A8A), "${carta.multiplicaciones[2][0]}×${carta.multiplicaciones[2][1]}"),
        ),

        // Middle circle for division (Green)
        Positioned(
          left: width * 0.3,
          top: height * 0.55,
          child: _buildCircle(width * 0.4, const Color(0xFF10B981), "${carta.division[0]}:${carta.division[1]}"),
        ),

        // Bottom section for results (Light Blue)
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: height * 0.2,
          child: Container(
             decoration: const BoxDecoration(
               color: Color(0xFF38BDF8),
               borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
               border: Border(top: BorderSide(color: Colors.black, width: 2)),
             ),
             child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
               children: carta.resultados.map((res) => Text(
                 res.toString(),
                 style: _getTextStyle().copyWith(color: Colors.black, fontWeight: FontWeight.bold),
               )).toList(),
             ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildCircle(double size, Color color, String text) {
      return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 1.5),
          ),
          alignment: Alignment.center,
          child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text(
                    text,
                    style: _getTextStyle().copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
          ),
      );
  }

  TextStyle _getTextStyle() {
      // Dynamic font size calculation could be more sophisticated
      double fontSize = width * 0.12; 
      return GoogleFonts.lexendMega(
        fontSize: fontSize,
        color: Colors.black,
        fontWeight: FontWeight.normal,
      );
  }
}
