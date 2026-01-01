import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/avatar_helper.dart';
import '../models/partida.dart';

class PlayerInfoBadge extends StatelessWidget {
  final JugadorInfo jugador;
  final double availableHeight;
  final int avatarState;
  final bool isCurrentUser;

  const PlayerInfoBadge({
    super.key,
    required this.jugador,
    required this.availableHeight,
    required this.avatarState,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    // Maximize avatar size - use most of the available height
    final avatarSize = (availableHeight * 0.85).clamp(40.0, 100.0);
    final badgeSize = (avatarSize * 0.35).clamp(20.0, 35.0);
    final badgeFontSize = (badgeSize * 0.5).clamp(10.0, 16.0);
    
    return Container(
      height: availableHeight,
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentUser ? AppTheme.primary : Colors.white24,
          width: isCurrentUser ? 3 : 2,
        ),
      ),
      child: Center(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Avatar (centered)
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2C),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  AvatarHelper.getAvatarPath(jugador.avatar ?? 'default', avatarState),
                  width: avatarSize,
                  height: avatarSize,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: avatarSize,
                    height: avatarSize,
                    color: Colors.grey[200],
                    child: Icon(Icons.person, size: avatarSize * 0.5, color: Colors.grey),
                  ),
                ),
              ),
            ),
            
            // Purple circle badge (top-left) - Remaining cards
            Positioned(
              left: -badgeSize * 0.2,
              top: -badgeSize * 0.2,
              child: Container(
                width: badgeSize,
                height: badgeSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF9C27B0), // Purple
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${jugador.cartasRestantes}',
                    style: TextStyle(
                      fontSize: badgeFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            
            // Red triangle badge (bottom-right) - Penalties
            if (jugador.penalizaciones > 0)
              Positioned(
                right: -badgeSize * 0.2,
                bottom: -badgeSize * 0.2,
                child: CustomPaint(
                  size: Size(badgeSize, badgeSize),
                  painter: TriangleBadgePainter(
                    color: AppTheme.error,
                    borderColor: Colors.white,
                  ),
                  child: SizedBox(
                    width: badgeSize,
                    height: badgeSize,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: badgeSize * 0.1),
                        child: Text(
                          '${jugador.penalizaciones}',
                          style: TextStyle(
                            fontSize: badgeFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for triangle badge
class TriangleBadgePainter extends CustomPainter {
  final Color color;
  final Color borderColor;
  
  TriangleBadgePainter({required this.color, required this.borderColor});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final path = Path();
    path.moveTo(size.width / 2, 0); // Top center
    path.lineTo(size.width, size.height); // Bottom right
    path.lineTo(0, size.height); // Bottom left
    path.close();
    
    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
