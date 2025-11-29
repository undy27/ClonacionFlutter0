import 'package:flutter/material.dart';
import '../models/carta.dart';
import '../theme/app_theme.dart';

import 'package:flutter_svg/flutter_svg.dart';

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
          ),
          child: Center(
            child: Text(
              "?",
              style: TextStyle(
                fontFamily: 'LexendMega',
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
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: tema == 'clasico' ? _buildClasico() : _buildModerno(),
        ),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        
        // Helper to map SVG coordinates (161x216) to current size
        double scaleX(double x) => (x / 161.0) * w;
        double scaleY(double y) => (y / 216.0) * h;

        // Cálculo de fuente responsivo basado en el tamaño de la carta
        // El diámetro de los círculos es aproximadamente 32% del ancho de la carta
        double diameter = w * 0.32;
        
        // Margen fijo: 4px a cada lado = 8px total
        const double margin = 8.0;
        
        // Calcular fontSize para que el texto quepa en el círculo
        // Para "10x10" (5 caracteres con LexendMega Bold)
        // Reducido a 2.0 para aprovechar mucho más el espacio
        // Y reducido un 10% adicional globalmente
        double uniformFontSize = ((diameter - margin) / 2.0) * 0.9;
        
        // Sin límite superior, solo mínimo para legibilidad
        if (uniformFontSize < 7) uniformFontSize = 7;

        return Stack(
          children: [
            // Background SVG
            SizedBox.expand(
              child: SvgPicture.asset(
                'assets/Carta2.svg',
                fit: BoxFit.fill,
              ),
            ),
            
            // Multiplications (Dark Blue Area)
            // Centros aproximados visuales en SVG original (161x216)
            
            // Mult 1: Top Left (x~40, y~43) - Adjusted Y for better centering
            Positioned(
              left: scaleX(40) - (diameter / 2), 
              top: scaleY(43) - (diameter / 2),
              width: diameter,
              height: diameter,
              child: Center(
                child: _buildOperationText(
                  "${carta.multiplicaciones[0][0]}×${carta.multiplicaciones[0][1]}",
                  carta.multiplicaciones[0].contains(10) ? uniformFontSize * 0.9 : uniformFontSize,
                  Colors.white
                ),
              ),
            ),
            
            // Mult 2: Top Right (x~120, y~43) - Adjusted Y for better centering
            Positioned(
              left: scaleX(120) - (diameter / 2),
              top: scaleY(43) - (diameter / 2),
              width: diameter,
              height: diameter,
              child: Center(
                child: _buildOperationText(
                  "${carta.multiplicaciones[1][0]}×${carta.multiplicaciones[1][1]}",
                  carta.multiplicaciones[1].contains(10) ? uniformFontSize * 0.9 : uniformFontSize,
                  Colors.white
                ),
              ),
            ),
            
            // Mult 3: Middle Left (x~40, y~118)
            Positioned(
              left: scaleX(40) - (diameter / 2),
              top: scaleY(118) - (diameter / 2),
              width: diameter,
              height: diameter,
              child: Center(
                child: _buildOperationText(
                  "${carta.multiplicaciones[2][0]}×${carta.multiplicaciones[2][1]}",
                  carta.multiplicaciones[2].contains(10) ? uniformFontSize * 0.9 : uniformFontSize,
                  Colors.white
                ),
              ),
            ),

            // Division (Green Circle)
            // Center is (118, 118)
            Positioned(
              left: scaleX(118) - (diameter / 2), 
              top: scaleY(118) - (diameter / 2),
              width: diameter, 
              height: diameter,
              child: Center(
                child: _buildOperationText(
                  "${carta.division[0]}:${carta.division[1]}",
                  carta.division[0] >= 10 ? uniformFontSize * 0.95 : uniformFontSize,
                  Colors.white
                ),
              ),
            ),

            // Results (Light Blue Bottom Area)
            // Starts around y=162. Centered vertically in the bottom area.
            Positioned(
              left: 0,
              right: 0,
              bottom: scaleY(10), // Ajuste fino
              height: scaleY(40), // Altura de la zona inferior
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: carta.resultados.map((res) => _buildOperationText(
                  res.toString(),
                  uniformFontSize,
                  Colors.white
                )).toList(),
              ),
            ),
          ],
        );
      }
    );
  }
  
  Widget _buildOperationText(String text, double fontSize, Color color) {
      return Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'LexendMega',
          fontSize: fontSize,
          color: color,
          fontWeight: FontWeight.bold,
          height: 1.0,
          leadingDistribution: TextLeadingDistribution.even, // Distribuir espacio uniformemente
        ),
      );
  }

  TextStyle _getTextStyle() {
      double fontSize = width * 0.12; 
      return TextStyle(
        fontFamily: 'LexendMega',
        fontSize: fontSize,
        color: Colors.black,
        fontWeight: FontWeight.normal,
      );
  }
}
