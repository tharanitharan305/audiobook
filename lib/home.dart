import 'package:audiobook/audio/data/audioService.dart';
import 'package:audiobook/summarize/ui/summaryList.dart';
import 'package:audiobook/theme/bloc/themeBloc.dart';
import 'package:audiobook/theme/bloc/themeEvent.dart';
import 'package:audiobook/theme/bloc/themeState.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'audio/widget/audioTest.dart';
import 'dashboard/ui/dashboard.dart';
import 'login/widget/logo.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  final List<Widget> pages = [
    const Dashboard(),
    const SavedSummariesScreen(),
    AudioChapterScreen(documentId: '',service: MockAudioService(),),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWeb = width > 1000;

    return isWeb ? _buildWebLayout(context) : _buildMobileLayout(context);
  }

  /// =========================
  /// 🔵 MOBILE / TABLET LAYOUT
  /// =========================
  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: pages[selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() => selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          NavigationDestination(
            icon: Icon(Icons.summarize_outlined),
            selectedIcon: Icon(Icons.summarize),
            label: "Summarise",
          ),
          NavigationDestination(
            icon: Icon(Icons.headphones_outlined),
            selectedIcon: Icon(Icons.headphones),
            label: "Audio",
          ),
        ],
      ),
    );
  }

  /// =========================
  /// 🟣 WEB / DESKTOP LAYOUT
  /// =========================
  Widget _buildWebLayout(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(context),
          Expanded(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(child: pages[selectedIndex]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// =========================
  /// Sidebar
  /// =========================
  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.symmetric(vertical: 24),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          /// 🔥 Your Logo Widget
          Logo(),

          const SizedBox(height: 40),

          _sideItem(
            context,
            icon: Icons.dashboard_rounded,
            title: "Dashboard",
            index: 0,
          ),
          _sideItem(
            context,
            icon: Icons.summarize_rounded,
            title: "Summarise",
            index: 1,
          ),
          _sideItem(
            context,
            icon: Icons.headphones_rounded,
            title: "Audio",
            index: 2,
          ),
        ],
      ),
    );
  }

  Widget _sideItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required int index,
      }) {
    final isSelected = selectedIndex == index;

    return InkWell(
      onTap: () => setState(() => selectedIndex = index),
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isSelected
              ? Theme.of(context)
              .colorScheme
              .primary
              .withOpacity(0.1)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
            ),
            const SizedBox(width: 14),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// =========================
  /// Shared AppBar
  /// =========================
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: const Text("Audiobook"),
      actions: [
        BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, state) {
            final isDark = state.themeMode == ThemeMode.dark;

            return IconButton(
              icon: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
              ),
              onPressed: () {
                context.read<ThemeBloc>().add(ToggleTheme());
              },
            );
          },
        ),
      ],
    );
  }

  /// =========================
  /// Dummy Logo (Replace Later)
  /// =========================
  Widget Logo() {
    return Column(
      children: [
       logo(),
        const SizedBox(height: 8),
        const Text(
          "Audiobook",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }
}