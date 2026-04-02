import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Visual showcase section displaying IPL teams with logos
/// and team colors. Uses a horizontal scrollable carousel.
class TeamShowcase extends StatefulWidget {
  const TeamShowcase({super.key});

  @override
  State<TeamShowcase> createState() => _TeamShowcaseState();
}

class _TeamShowcaseState extends State<TeamShowcase>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // IPL team data with team colors
  static final List<Map<String, dynamic>> _teams = [
    {
      'name': 'Mumbai Indians',
      'short': 'MI',
      'color1': Color(0xFF004BA0),
      'color2': Color(0xFFD4A843),
      'icon': Icons.sports_cricket,
    },
    {
      'name': 'Chennai Super Kings',
      'short': 'CSK',
      'color1': Color(0xFFFFCC00),
      'color2': Color(0xFFE84C30),
      'icon': Icons.shield,
    },
    {
      'name': 'Royal Challengers',
      'short': 'RCB',
      'color1': Color(0xFFD4192C),
      'color2': Color(0xFFD4A843),
      'icon': Icons.local_fire_department,
    },
    {
      'name': 'Kolkata Knight Riders',
      'short': 'KKR',
      'color1': Color(0xFF3A225D),
      'color2': Color(0xFFD4A843),
      'icon': Icons.flash_on,
    },
    {
      'name': 'Delhi Capitals',
      'short': 'DC',
      'color1': Color(0xFF004C93),
      'color2': Color(0xFFD71920),
      'icon': Icons.account_balance,
    },
    {
      'name': 'Rajasthan Royals',
      'short': 'RR',
      'color1': Color(0xFFE73895),
      'color2': Color(0xFF254AA5),
      'icon': Icons.castle,
    },
    {
      'name': 'Punjab Kings',
      'short': 'PBKS',
      'color1': Color(0xFFDD1F2D),
      'color2': Color(0xFFDCDDDF),
      'icon': Icons.whatshot,
    },
    {
      'name': 'Sunrisers Hyderabad',
      'short': 'SRH',
      'color1': Color(0xFFFF8C00),
      'color2': Color(0xFF000000),
      'icon': Icons.wb_sunny,
    },
    {
      'name': 'Gujarat Titans',
      'short': 'GT',
      'color1': Color(0xFF1C1C2B),
      'color2': Color(0xFFB08ECD),
      'icon': Icons.bolt,
    },
    {
      'name': 'Lucknow Super Giants',
      'short': 'LSG',
      'color1': Color(0xFF03BBEB),
      'color2': Color(0xFFF27223),
      'icon': Icons.stars,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 768;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // Section header
          Row(
            children: [
              Container(
                width: 4,
                height: 28,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.neonCyan, AppColors.neonGreen],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'IPL TEAMS',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              Text(
                '${_teams.length} Teams',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Horizontally scrollable team cards
          SizedBox(
            height: isSmall ? 150 : 170,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _teams.length,
              itemBuilder: (context, index) {
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 500 + index * 100),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: _buildTeamCard(_teams[index], isSmall),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamCard(Map<String, dynamic> team, bool isSmall) {
    return Container(
      width: isSmall ? 130 : 155,
      margin: const EdgeInsets.only(right: 14),
      child: _TeamCardHover(team: team, isSmall: isSmall),
    );
  }
}

class _TeamCardHover extends StatefulWidget {
  final Map<String, dynamic> team;
  final bool isSmall;

  const _TeamCardHover({required this.team, required this.isSmall});

  @override
  State<_TeamCardHover> createState() => _TeamCardHoverState();
}

class _TeamCardHoverState extends State<_TeamCardHover> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final team = widget.team;
    final color1 = team['color1'] as Color;
    final color2 = team['color2'] as Color;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..scale(_isHovered ? 1.05 : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              color1.withOpacity(_isHovered ? 0.25 : 0.12),
              color2.withOpacity(_isHovered ? 0.15 : 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: color1.withOpacity(_isHovered ? 0.5 : 0.2),
            width: 1,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: color1.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Team icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [color1, color2],
                ),
                boxShadow: [
                  BoxShadow(
                    color: color1.withOpacity(0.3),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                team['icon'] as IconData,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),

            // Short name
            Text(
              team['short'] as String,
              style: TextStyle(
                color: _isHovered ? color1 : AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),

            // Full name
            Text(
              team['name'] as String,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
