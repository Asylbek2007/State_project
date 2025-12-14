import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../goals/presentation/pages/goals_page.dart';
import '../../../community/presentation/pages/community_page.dart';

/// Home page with BottomNavigationBar.
///
/// Three tabs:
/// 1. Profile - user info, settings, logout
/// 2. Main (Goals) - default landing, list of goals
/// 3. Community - impact wall, top donors, achievements
class HomePage extends StatefulWidget {
  final String userName;
  final String userGroup;
  final int initialIndex;

  const HomePage({
    super.key,
    required this.userName,
    required this.userGroup,
    this.initialIndex = 1, // Default to Main tab
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _currentIndex;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    
    // Initialize pages
    _pages = [
      ProfilePage(
        userName: widget.userName,
        userGroup: widget.userGroup,
      ),
      GoalsPage(
        userName: widget.userName,
        userGroup: widget.userGroup,
      ),
      const CommunityPage(),
    ];
  }

  void _onTabTapped(int index) {
    if (index != _currentIndex) {
      print('Navigating to tab: $index');
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppTheme.surfaceWhite,
          selectedItemColor: AppTheme.primarySkyBlue,
          unselectedItemColor: AppTheme.textSecondary,
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, size: 24),
              activeIcon: Icon(Icons.person, size: 24),
              label: 'Профиль',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 24),
              activeIcon: Icon(Icons.home, size: 24),
              label: 'Главная',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline, size: 24),
              activeIcon: Icon(Icons.people, size: 24),
              label: 'Сообщество',
            ),
          ],
        ),
      ),
    );
  }
}

