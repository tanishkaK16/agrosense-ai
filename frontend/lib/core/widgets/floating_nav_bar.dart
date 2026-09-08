import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../constants/app_sizes.dart';

/// Destination descriptor for [FloatingNavBar].
class NavDestination {
  const NavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.path,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String path;
}

/// Compact floating pill navigation bar.
///
/// Sits in the lower-center of the screen with a warm shadow.
/// Active destination: filled dark-olive pill + light icon.
/// Inactive: muted icon + label.
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    super.key,
    required this.destinations,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  final List<NavDestination> destinations;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSizes.navBarSidePadding,
        right: AppSizes.navBarSidePadding,
        bottom: AppSizes.navBarBottomMargin,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusPill),
          boxShadow: AppShadows.nav,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.navBarHorizontalPadding,
            vertical: 6,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(destinations.length, (i) {
              return _NavItem(
                destination: destinations[i],
                isSelected: i == currentIndex,
                onTap: () => onDestinationSelected(i),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.isSelected,
    required this.onTap,
  });

  final NavDestination destination;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: destination.label,
      selected: isSelected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          // Ensures minimum tap target
          width: AppSizes.minTapTarget,
          height: AppSizes.navBarHeight - 12,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isSelected ? destination.selectedIcon : destination.icon,
                  size: AppSizes.iconMedium,
                  color: isSelected ? AppColors.onPhoto : AppColors.muted,
                ),
                if (!isSelected) ...[
                  const SizedBox(height: 2),
                  Text(
                    destination.label,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.muted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textScaler: TextScaler.noScaling,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
