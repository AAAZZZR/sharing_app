import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_vault/l10n/app_localizations.dart';
import 'package:learning_vault/providers/settings_provider.dart';
import 'package:learning_vault/screens/home_screen.dart';
import 'package:learning_vault/screens/tags_screen.dart';
import 'package:learning_vault/screens/search_screen.dart';
import 'package:learning_vault/screens/settings_screen.dart';
import 'package:learning_vault/screens/share_receive_screen.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class LearningVaultApp extends ConsumerWidget {
  const LearningVaultApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      locale: locale,
      title: 'Learning Vault',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
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

  void _showAddLinkDialog(AppLocalizations l10n) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.addLink),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.pasteLinkHint),
          onSubmitted: (value) {
            final url = value.trim();
            if (url.isNotEmpty) {
              Navigator.pop(ctx);
              _openShareReceive(url);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              final url = controller.text.trim();
              if (url.isNotEmpty) {
                Navigator.pop(ctx);
                _openShareReceive(url);
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: _screens[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddLinkDialog(l10n),
        backgroundColor: const Color(0xFF7FD8BE),
        child: const Icon(Icons.add, color: Color(0xFF0F0F1A)),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1A1A2E),
        selectedItemColor: const Color(0xFF7FD8BE),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: l10n.navHome),
          BottomNavigationBarItem(icon: const Icon(Icons.label), label: l10n.navTags),
          BottomNavigationBarItem(icon: const Icon(Icons.search), label: l10n.navSearch),
          BottomNavigationBarItem(icon: const Icon(Icons.settings), label: l10n.navSettings),
        ],
      ),
    );
  }
}
