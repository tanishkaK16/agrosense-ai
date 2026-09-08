import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/locale_controller.dart';
import '../../core/routing/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/floating_nav_bar.dart';
import '../../generated/l10n/app_localizations.dart';

/// Defines the three bottom navigation destinations.
List<NavDestination> _buildDestinations(AppLocalizations l10n) => [
      NavDestination(
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_rounded,
        label: l10n.home,
        path: AppRoutes.home,
      ),
      NavDestination(
        icon: Icons.grid_view_outlined,
        selectedIcon: Icons.grid_view_rounded,
        label: l10n.myFields,
        path: AppRoutes.fields,
      ),
      NavDestination(
        icon: Icons.notifications_none_rounded,
        selectedIcon: Icons.notifications_rounded,
        label: l10n.alerts,
        path: AppRoutes.alerts,
      ),
    ];

/// The main shell that wraps the three primary tab screens.
///
/// Hosts the [FloatingNavBar] and re-routes to the correct path when the
/// user taps a tab. Locale changes are observed via [LocaleController]
/// so tab labels update immediately when the user switches language.
class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  @override
  void initState() {
    super.initState();
    LocaleController.instance.addListener(_onLocaleChange);
  }

  @override
  void dispose() {
    LocaleController.instance.removeListener(_onLocaleChange);
    super.dispose();
  }

  void _onLocaleChange() {
    if (mounted) setState(() {});
  }

  int _currentIndex(String location) {
    if (location.startsWith(AppRoutes.alerts)) return 2;
    if (location.startsWith(AppRoutes.fields)) return 1;
    return 0;
  }

  void _onTabTap(int index, List<NavDestination> destinations) {
    context.go(destinations[index].path);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final destinations = _buildDestinations(l10n);
    final location = GoRouterState.of(context).uri.toString();

    return Scaffold(
      backgroundColor: AppColors.background,
      // No system bottom nav — we render our own floating pill.
      extendBody: true,
      body: widget.child,
      bottomNavigationBar: FloatingNavBar(
        destinations: destinations,
        currentIndex: _currentIndex(location),
        onDestinationSelected: (i) => _onTabTap(i, destinations),
      ),
    );
  }
}
