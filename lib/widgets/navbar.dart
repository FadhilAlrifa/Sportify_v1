import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class Navbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const Navbar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onTap,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF00B47A),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Ionicons.home_outline),
          label: "Home",
        ),
        // BottomNavigationBarItem(
        //   icon: Icon(Ionicons.chatbubble_ellipses_outline),
        //   label: "Chat",
        // ),
        BottomNavigationBarItem(
          icon: Icon(Ionicons.receipt_outline),
          label: "Riwayat",
        ),
        BottomNavigationBarItem(
          icon: Icon(Ionicons.person_outline),
          label: "Profil",
        ),
      ],
    );
  }
}