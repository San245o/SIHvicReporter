import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AnimatedBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Color backgroundColor;
  final Color selectedColor;
  final Color unselectedColor;
  final double borderRadius;
  final EdgeInsets padding;

  const AnimatedBottomNavBar({
    super.key,
    required this.currentIndex,
    this.backgroundColor = const Color(0xFF1E1E1E),
    this.selectedColor = const Color.fromARGB(255, 39, 43, 40), // Light green
    this.unselectedColor = const Color.fromARGB(255, 17, 209, 17),
    this.borderRadius = 30.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            context,
            icon: Icons.home,
            label: 'Home',
            index: 0,
            route: '/home',
          ),
          _buildNavItem(
            context,
            icon: Icons.map,
            label: 'Maps',
            index: 1,
            route: '/maps',
          ),
          _buildNavItem(
            context,
            icon: Icons.add,
            label: 'Create',
            index: 2,
            route: '/create-post',
          ),
          _buildNavItem(
            context,
            icon: Icons.person,
            label: 'Profile',
            index: 3,
            route: '/my-posts',
          ),
          _buildNavItem(
            context,
            icon: Icons.inbox,
            label: 'Inbox',
            index: 4,
            route: '/inbox',
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
    required String route,
  }) {
    final isSelected = currentIndex == index;
    
    return GestureDetector(
      onTap: () {
        if (currentIndex != index) {
          context.go(route);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Icon(
                icon,
                size: isSelected ? 24 : 20,
                color: isSelected ? Colors.white : unselectedColor,
              ),
            ),
            // Animated text that appears/disappears
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isSelected ? 1.0 : 0.0,
                child: Container(
                  margin: EdgeInsets.only(left: isSelected ? 8 : 0),
                  child: Text(
                    isSelected ? label : '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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

// Alternative implementation with more pill-like design matching your image
class PillBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Color backgroundColor;
  final Color selectedColor;
  final Color unselectedColor;

  const PillBottomNavBar({
    super.key,
    required this.currentIndex,
    this.backgroundColor = const Color(0xFF1E1E1E),
    this.selectedColor = const Color(0xFF4ADE80), // Light green
    this.unselectedColor = const Color(0xFF8E8E93),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildNavPill(
            context,
            icon: Icons.home,
            label: 'Home',
            index: 0,
            route: '/home',
          ),
          const SizedBox(height: 8),
          _buildNavPill(
            context,
            icon: Icons.folder_open,
            label: 'Portfolio',
            index: 1,
            route: '/maps',
          ),
          const SizedBox(height: 8),
          _buildNavPill(
            context,
            icon: Icons.visibility,
            label: 'Watchlist',
            index: 2,
            route: '/create-post',
          ),
          const SizedBox(height: 8),
          _buildNavPill(
            context,
            icon: Icons.trending_up,
            label: 'Markets',
            index: 3,
            route: '/my-posts',
          ),
        ],
      ),
    );
  }

  Widget _buildNavPill(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
    required String route,
  }) {
    final isSelected = currentIndex == index;
    
    return GestureDetector(
      onTap: () {
        if (currentIndex != index) {
          context.go(route);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? selectedColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: EdgeInsets.all(isSelected ? 8 : 6),
              decoration: BoxDecoration(
                color: isSelected ? selectedColor : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: isSelected ? 20 : 16,
                color: isSelected ? Colors.white : unselectedColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  color: isSelected ? Colors.white : unselectedColor,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
                child: Text(label),
              ),
            ),
            // Additional icons on the right (like in your design)
            Row(
              children: [
                Icon(
                  Icons.settings,
                  size: 16,
                  color: unselectedColor.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.more_horiz,
                  size: 16,
                  color: unselectedColor.withValues(alpha: 0.5),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Horizontal bottom nav that matches your civic reporter app
class CivicBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Color backgroundColor;
  final Color selectedColor;
  final Color unselectedColor;

  const CivicBottomNavBar({
    super.key,
    required this.currentIndex,
    this.backgroundColor = const Color(0xFF1E1E1E),
    this.selectedColor = const Color(0xFF4ADE80), // Light green
    this.unselectedColor = const Color(0xFF8E8E93),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildExpandingNavItem(
            context,
            icon: Icons.home,
            label: 'Home',
            index: 0,
            route: '/home',
          ),
          _buildExpandingNavItem(
            context,
            icon: Icons.map,
            label: 'Maps',
            index: 1,
            route: '/maps',
          ),
          _buildExpandingNavItem(
            context,
            icon: Icons.add_circle,
            label: 'Create',
            index: 2,
            route: '/create-post',
          ),
          _buildExpandingNavItem(
            context,
            icon: Icons.article,
            label: 'Posts',
            index: 3,
            route: '/my-posts',
          ),
          _buildExpandingNavItem(
            context,
            icon: Icons.notifications,
            label: 'Inbox',
            index: 4,
            route: '/inbox',
          ),
        ],
      ),
    );
  }

  Widget _buildExpandingNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
    required String route,
  }) {
    final isSelected = currentIndex == index;
    
    return Expanded(
      flex: isSelected ? 3 : 1,
      child: GestureDetector(
        onTap: () {
          if (currentIndex != index) {
            // Use go instead of push to replace the current route
            context.go(route);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          // Remove horizontal padding to prevent overflow
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? selectedColor : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: Icon(
                  icon,
                  size: isSelected ? 24 : 20,
                  color: isSelected ? Colors.white : unselectedColor,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: isSelected ? 1.0 : 0.0,
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}