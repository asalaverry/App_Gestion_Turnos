import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/paleta_colores.dart' as pal;

/// AppBar reusable con dos variantes: Home (menú + notificaciones) y Back (← + título).
class CustomTopBar extends StatelessWidget implements PreferredSizeWidget {
  // modo
  final _Mode _mode;

  // comunes
  final String? title;

  final PreferredSizeWidget? bottom;

  // Home
  final void Function(String value)? onMenuSelected;
  final List<PopupMenuEntry<String>> Function(BuildContext context)? menuBuilder;
  final int notifCount;
  final VoidCallback? onNotificationsPressed;

  // Atras
  final VoidCallback? onBack;

  const CustomTopBar._({
    super.key,
    required _Mode mode,
    this.title,
    this.bottom,  
    this.onMenuSelected,
    this.menuBuilder,
    this.notifCount = 0,
    this.onNotificationsPressed,
    this.onBack,
  }) : _mode = mode;

  /// Variante Home: menú + notificaciones
  factory CustomTopBar.home({
    Key? key,
    String? title,
    required void Function(String value) onMenuSelected,
    required List<PopupMenuEntry<String>> Function(BuildContext context) menuBuilder,
    int notifCount = 0,
    VoidCallback? onNotificationsPressed,
    PreferredSizeWidget? bottom,  
  }) {
    return CustomTopBar._(
      key: key,
      mode: _Mode.home,
      title: title,
      bottom: bottom,
      onMenuSelected: onMenuSelected,
      menuBuilder: menuBuilder,
      notifCount: notifCount,
      onNotificationsPressed: onNotificationsPressed,
    );
  }

  /// Variante Back: flecha atrás + título
  factory CustomTopBar.back({
    Key? key,
    required String title,
    VoidCallback? onBack,
    PreferredSizeWidget? bottom,  
  }) {
    return CustomTopBar._(
      key: key,
      mode: _Mode.back,
      title: title,
      bottom: bottom,
      onBack: onBack,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: pal.colorPrimario,
      foregroundColor: pal.fondo,
      elevation: 0,
      titleSpacing: 0,
      leading: _mode == _Mode.home
          ? PopupMenuButton<String>(
              icon: const Icon(Icons.menu),
              position: PopupMenuPosition.under,
              offset: const Offset(0, 8),
              color: pal.colorPrimario,
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              onSelected: onMenuSelected,
              itemBuilder: (ctx) => menuBuilder?.call(ctx) ?? const <PopupMenuEntry<String>>[],
            )
          : IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
            ),
      title: Text(title ?? ''),
      actions: _mode == _Mode.home
          ? [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none),
                    onPressed: onNotificationsPressed,
                  ),
                  if (notifCount > 0)
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: pal.colorAtencion,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          notifCount > 9 ? '9+' : '$notifCount',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),
            ]
          : null,
      bottom: bottom, 
    );
  }
}

enum _Mode { home, back }
