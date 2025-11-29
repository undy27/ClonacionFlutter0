import 'package:flutter/material.dart';
import '../models/carta.dart';
import '../theme/app_theme.dart';
import '../providers/game_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CartaWidget extends StatefulWidget {
  final Carta carta;
  final String tema;
  final double width;
  final double height;
  final bool isVisible;
  final VoidCallback? onTap;
  final MatchDetails? matchDetails;

  const CartaWidget({
    super.key,
    required this.carta,
    this.tema = 'moderno', // 'clasico' or 'moderno'
    required this.width,
    required this.height,
    this.isVisible = true,
    this.onTap,
    this.matchDetails,
  });

  @override
  State<CartaWidget> createState() => _CartaWidgetState();
}

class _CartaWidgetState extends State<CartaWidget> with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _scaleAnimation;
  Animation<Color?>? _colorAnimationWhite;
  Animation<Color?>? _colorAnimationBlack;
  Animation<double>? _shadowBlurAnimation;

  void _initAnimations() {
    if (_controller != null) return;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 3.5).chain(CurveTween(curve: Curves.easeOutExpo)), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 3.5, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)), weight: 75),
    ]).animate(_controller!);

    _colorAnimationWhite = TweenSequence<Color?>([
      TweenSequenceItem(tween: ColorTween(begin: Colors.white, end: const Color(0xFFFFD700)), weight: 20),
      TweenSequenceItem(tween: ColorTween(begin: const Color(0xFFFFD700), end: Colors.white), weight: 80),
    ]).animate(_controller!);

    _colorAnimationBlack = TweenSequence<Color?>([
      TweenSequenceItem(tween: ColorTween(begin: Colors.black, end: const Color(0xFFFFD700)), weight: 20),
      TweenSequenceItem(tween: ColorTween(begin: const Color(0xFFFFD700), end: Colors.black), weight: 80),
    ]).animate(_controller!);

    _shadowBlurAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 15.0).chain(CurveTween(curve: Curves.easeOut)), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 15.0, end: 0.0).chain(CurveTween(curve: Curves.easeIn)), weight: 80),
    ]).animate(_controller!);
  }

  @override
  void initState() {
    super.initState();
    _initAnimations();
    if (widget.matchDetails != null && widget.matchDetails!.hasMatch) {
      _controller!.forward();
    }
  }

  @override
  void didUpdateWidget(CartaWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initAnimations(); // Ensure initialized
    if (widget.matchDetails != oldWidget.matchDetails && widget.matchDetails != null && widget.matchDetails!.hasMatch) {
      _controller!.reset();
      _controller!.forward();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _initAnimations(); // Ensure initialized

    if (!widget.isVisible) {
      return GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: widget.width,
          height: widget.height,
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
                fontSize: widget.width * 0.4,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.border, width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: widget.tema == 'clasico' ? _buildClasico() : 
                 AnimatedBuilder(
                   animation: _controller!,
                   builder: (context, child) => _buildModerno(),
                 ),
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
                    "${widget.carta.multiplicaciones[0][0]}×${widget.carta.multiplicaciones[0][1]}",
                    style: _getTextStyle(),
                    textAlign: TextAlign.left,
                  ),
                ),
                Container(width: 1.5, color: const Color(0xFF333333)),
                Expanded(
                  flex: 2,
                  child: Text(
                    "${widget.carta.multiplicaciones[1][0]}×${widget.carta.multiplicaciones[1][1]}",
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
                    "${widget.carta.division[0]}:${widget.carta.division[1]}",
                    style: _getTextStyle(),
                    textAlign: TextAlign.left,
                  ),
                ),
                Container(width: 1.5, color: const Color(0xFF333333)),
                Expanded(
                  flex: 2,
                  child: Text(
                    "${widget.carta.multiplicaciones[2][0]}×${widget.carta.multiplicaciones[2][1]}",
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
              children: widget.carta.resultados
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
        double diameter = w * 0.32;
        
        // Margen fijo: 4px a cada lado = 8px total
        const double margin = 8.0;
        
        double uniformFontSize = ((diameter - margin) / 2.0) * 0.9;
        
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
            
            // Mult 1: Top Left (x~40, y~43)
            Positioned(
              left: scaleX(40) - (diameter / 2), 
              top: scaleY(43) - (diameter / 2),
              width: diameter,
              height: diameter,
              child: Center(
                child: _buildAnimatedElement(
                  isMatched: widget.matchDetails?.matchedMults.contains(0) ?? false,
                  child: _buildOperationText(
                    "${widget.carta.multiplicaciones[0][0]}×${widget.carta.multiplicaciones[0][1]}",
                    widget.carta.multiplicaciones[0].contains(10) ? uniformFontSize * 0.8 : uniformFontSize,
                    Colors.white,
                    isMatched: widget.matchDetails?.matchedMults.contains(0) ?? false,
                  ),
                ),
              ),
            ),
            
            // Mult 2: Top Right (x~120, y~43)
            Positioned(
              left: scaleX(120) - (diameter / 2),
              top: scaleY(43) - (diameter / 2),
              width: diameter,
              height: diameter,
              child: Center(
                child: _buildAnimatedElement(
                  isMatched: widget.matchDetails?.matchedMults.contains(1) ?? false,
                  child: _buildOperationText(
                    "${widget.carta.multiplicaciones[1][0]}×${widget.carta.multiplicaciones[1][1]}",
                    widget.carta.multiplicaciones[1].contains(10) ? uniformFontSize * 0.8 : uniformFontSize,
                    Colors.white,
                    isMatched: widget.matchDetails?.matchedMults.contains(1) ?? false,
                  ),
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
                child: _buildAnimatedElement(
                  isMatched: widget.matchDetails?.matchedMults.contains(2) ?? false,
                  child: _buildOperationText(
                    "${widget.carta.multiplicaciones[2][0]}×${widget.carta.multiplicaciones[2][1]}",
                    widget.carta.multiplicaciones[2].contains(10) ? uniformFontSize * 0.8 : uniformFontSize,
                    Colors.white,
                    isMatched: widget.matchDetails?.matchedMults.contains(2) ?? false,
                  ),
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
                child: _buildAnimatedElement(
                  isMatched: widget.matchDetails?.matchedDiv ?? false,
                  child: _buildOperationText(
                    "${widget.carta.division[0]}:${widget.carta.division[1]}",
                    widget.carta.division[0] >= 10 ? uniformFontSize * 0.9 : uniformFontSize,
                    Colors.white,
                    isMatched: widget.matchDetails?.matchedDiv ?? false,
                  ),
                ),
              ),
            ),

            // Results (Light Blue Wave Area)
            
            // Res 1: Left margin (10px for single digit, 5px otherwise)
            Positioned(
              left: widget.carta.resultados[0] < 10 ? 10.0 : 5.0,
              bottom: scaleY(27) - (diameter / 2),
              height: diameter,
              child: Center(
                child: _buildAnimatedElement(
                  isMatched: widget.matchDetails?.matchedResults.contains(0) ?? false,
                  child: _buildOperationText(
                    "${widget.carta.resultados[0]}",
                    uniformFontSize * 1.1,
                    Colors.black,
                    isMatched: widget.matchDetails?.matchedResults.contains(0) ?? false,
                  ),
                ),
              ),
            ),
            
            // Res 2: Centered horizontally
            Positioned(
              left: 0,
              right: 0,
              bottom: scaleY(27) - (diameter / 2),
              height: diameter,
              child: Center(
                child: _buildAnimatedElement(
                  isMatched: widget.matchDetails?.matchedResults.contains(1) ?? false,
                  child: _buildOperationText(
                    "${widget.carta.resultados[1]}",
                    uniformFontSize * 1.1,
                    Colors.black,
                    isMatched: widget.matchDetails?.matchedResults.contains(1) ?? false,
                  ),
                ),
              ),
            ),
            
            // Res 3: Right margin (10px for single digit, 5px otherwise)
            Positioned(
              right: widget.carta.resultados[2] < 10 ? 10.0 : 5.0,
              bottom: scaleY(27) - (diameter / 2),
              height: diameter,
              child: Center(
                child: _buildAnimatedElement(
                  isMatched: widget.matchDetails?.matchedResults.contains(2) ?? false,
                  child: _buildOperationText(
                    "${widget.carta.resultados[2]}",
                    uniformFontSize * 1.1,
                    Colors.black,
                    isMatched: widget.matchDetails?.matchedResults.contains(2) ?? false,
                  ),
                ),
              ),
            ),
          ],
        );
      }
    );
  }
  
  Widget _buildAnimatedElement({required Widget child, required bool isMatched}) {
    if (!isMatched) return child;
    return ScaleTransition(
      scale: _scaleAnimation!,
      child: child,
    );
  }
  
  Widget _buildOperationText(String text, double fontSize, Color baseColor, {bool isMatched = false}) {
      Color finalColor = baseColor;
      if (isMatched) {
          if (baseColor == Colors.white) {
              finalColor = _colorAnimationWhite?.value ?? baseColor;
          } else {
              finalColor = _colorAnimationBlack?.value ?? baseColor;
          }
      }

      return Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'LexendMega',
          fontSize: fontSize,
          color: finalColor,
          fontWeight: FontWeight.bold,
          height: 1.0,
          leadingDistribution: TextLeadingDistribution.even,
          shadows: (isMatched && _shadowBlurAnimation != null && _shadowBlurAnimation!.value > 0.1) ? [
            Shadow(
                color: Colors.black.withOpacity(0.5 * (_shadowBlurAnimation!.value / 8.0)), 
                blurRadius: _shadowBlurAnimation!.value, 
                offset: const Offset(0, 0)
            )
          ] : null,
        ),
      );
  }

  TextStyle _getTextStyle() {
      double fontSize = widget.width * 0.12; 
      return TextStyle(
        fontFamily: 'LexendMega',
        fontSize: fontSize,
        color: Colors.black,
        fontWeight: FontWeight.normal,
      );
  }
}
