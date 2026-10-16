import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'controllers/todo_controller.dart';
import 'pages/calendar_page.dart';
import 'pages/home_page.dart';
import 'theme/app_theme.dart';

class TodoApp extends StatelessWidget {
  /// Menerima controller dari entry point untuk memudahkan pengujian.
  const TodoApp({super.key, required this.controller});
  final TodoController controller;

  /// Mengaktifkan tema dan lokalisasi Indonesia termasuk date picker.
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Daylist',
    theme: AppTheme.light(),
    locale: const Locale('id'),
    supportedLocales: const [Locale('id')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    home: _AppShell(controller: controller),
  );
}

class _AppShell extends StatefulWidget {
  /// Menyediakan navigasi dua halaman dengan state yang dipertahankan.
  const _AppShell({required this.controller});
  final TodoController controller;

  /// Membuat state indeks navigasi.
  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  int _index = 0;

  /// Merender loading, kegagalan penyimpanan, dan isi dua halaman.
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) {
      final controller = widget.controller;
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'daylist✳',
            style: TextStyle(fontWeight: FontWeight.w800),
          )
        ),
        body: SafeArea(
          child: Column(
            children: [
              if (controller.error != null)
                MaterialBanner(
                  content: Text(controller.error!),
                  actions: [
                    TextButton(
                      onPressed: controller.isLoading
                          ? null
                          : (controller.loadFailed
                                ? controller.initialize
                                : controller.retrySave),
                      child: Text(
                        controller.loadFailed ? 'Muat ulang' : 'Simpan lagi',
                      ),
                    ),
                  ],
                ),
              Expanded(
                child: controller.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : controller.loadFailed
                    ? const Center(
                        child: Text('Muat ulang untuk membuka tugas kamu.'),
                      )
                    : IndexedStack(
                        index: _index,
                        children: [
                          HomePage(controller: controller),
                          CalendarPage(controller: controller),
                        ],
                      ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (index) => setState(() => _index = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month),
              label: 'Kalender & Riwayat',
            ),
          ],
        ),
      );
    },
  );
}
