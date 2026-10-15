import 'package:flutter/material.dart';
import '../core/layout/adaptive_shell.dart';
import '../features/profile/profile_tab.dart';
import '../features/discovery/discovery_tab.dart';
import '../features/collection/collection_tab.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _tabIndex = 1; // uygulama ortadaki "Akış" tabıyla açılsın

  // IndexedStack sayesinde tab değiştiğinde her tab'ın
  // scroll konumu ve state'i (video oynatma vb.) korunur.
  final List<Widget> _tabs = const [
    ProfileTab(),
    DiscoveryTab(),
    CollectionTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return AdaptiveShell(
      tabs: _tabs,
      destinations: const [
        ShellDestination(icon: Icons.person, label: "Profil"),
        ShellDestination(icon: Icons.explore, label: "Akış"),
        ShellDestination(icon: Icons.bookmark, label: "Koleksiyon"),
      ],
      currentIndex: _tabIndex,
      onSelected: (i) => setState(() => _tabIndex = i),
    );
    /*Scaffold(
      backgroundColor: Colors.black,
      extendBody: true,
      body: IndexedStack(index: _tabIndex, children: _tabs),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white38,
        currentIndex: _tabIndex,
        onTap: (i) => setState(() => _tabIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Akış"),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: "Koleksiyon"),
        ],
      ),
    );*/
  }
}
