import 'package:flutter/material.dart';
import 'package:learning_vault/screens/home_screen.dart';
import 'package:learning_vault/screens/tags_screen.dart';
import 'package:learning_vault/screens/search_screen.dart';
import 'package:learning_vault/screens/settings_screen.dart';
import 'package:learning_vault/screens/share_receive_screen.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class LearningVaultApp extends StatelessWidget {
  const LearningVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '學習庫',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF7FD8BE),
          secondary: const Color(0xFFF6C177),
          surface: const Color(0xFF1A1A2E),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F0F1A),
        cardColor: const Color(0xFF1A1A2E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F0F1A),
          elevation: 0,
        ),
      ),
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _setupShareIntent();
  }

  void _setupShareIntent() {
    ReceiveSharingIntent.instance
        .getInitialMedia()
        .then((List<SharedMediaFile> value) {
      final url = _extractUrl(value);
      if (url != null) _openShareReceive(url);
    });

    ReceiveSharingIntent.instance
        .getMediaStream()
        .listen((List<SharedMediaFile> value) {
      final url = _extractUrl(value);
      if (url != null) _openShareReceive(url);
    });
  }

  String? _extractUrl(List<SharedMediaFile> files) {
    if (files.isEmpty) return null;
    final text = files.first.path;
    final urlPattern = RegExp(r'https?://\S+');
    final match = urlPattern.firstMatch(text);
    return match?.group(0) ?? text;
  }

  void _openShareReceive(String url) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ShareReceiveScreen(sharedUrl: url)),
    );
  }

  final _screens = const [
    HomeScreen(),
    TagsScreen(),
    SearchScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1A1A2E),
        selectedItemColor: const Color(0xFF7FD8BE),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '首頁'),
          BottomNavigationBarItem(icon: Icon(Icons.label), label: '標籤'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: '搜尋'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '設定'),
        ],
      ),
    );
  }
}
