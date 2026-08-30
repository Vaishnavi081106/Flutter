import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';

void main() {
  runApp(const PulseApp());
}

class PulseApp extends StatefulWidget {
  const PulseApp({super.key});

  @override
  State<PulseApp> createState() => _PulseAppState();
}

class _PulseAppState extends State<PulseApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paper Boat Pulse',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF159B82)),
        textTheme: GoogleFonts.manropeTextTheme(),  
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF080D18),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF45D6B5),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.manropeTextTheme(ThemeData.dark().textTheme),
        cardTheme: CardThemeData(
          color: const Color(0xFF111A2B),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Color(0x1AFFFFFF)),
          ),
        ),
      ),
      home: DashboardScreen(
        isDarkMode: _themeMode == ThemeMode.dark,
        onToggleTheme: () {
          setState(() {
            _themeMode = _themeMode == ThemeMode.dark
                ? ThemeMode.light
                : ThemeMode.dark;
          });
        },
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _logger = Logger();   //logger setup
  int _selectedIndex = 0;
  bool _isExpanded = false;
  bool _notificationsEnabled = true;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _logger.i('Dashboard screen initialized');
  }

  @override
  void dispose() {
    _logger.i('Dashboard screen disposed');
    super.dispose();
  }

  void _selectTab(int index) {
    _logger.i('Navigation tab selected: $index');
    setState(() => _selectedIndex = index);
  }

  void _showNotificationStatus() {
    _logger.i('Notification status opened');
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Notifications'),
        content: Text(
          _notificationsEnabled
              ? 'Weekly summary notifications are enabled.'
              : 'Notifications are muted. Turn them on to receive weekly summaries.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _toggleNotifications();
            },
            child: Text(_notificationsEnabled ? 'Mute' : 'Enable'),
          ),
        ],
      ),
    );
  }

  void _toggleNotifications() {
    _logger.i('Notification preference toggled');
    setState(() => _notificationsEnabled = !_notificationsEnabled);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _notificationsEnabled
              ? 'Weekly notifications enabled'
              : 'Weekly notifications muted',
        ),
      ),
    );
  }

  Future<void> _syncSampleData() async {
    if (_isSyncing) return;
    _logger.i('Sample data sync started');
    setState(() => _isSyncing = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _isSyncing = false);
    _logger.i('Sample data sync completed');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dashboard data is up to date')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.sizeOf(context);   //media query--reads secreen dimension
    final isCompact = media.width < 700;  //layoutbuilder=checks width, chose layout

    return Scaffold(
      bottomNavigationBar: isCompact
          ? NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _selectTab,
              destinations: const [
                NavigationDestination(icon: Icon(Icons.grid_view_rounded), label: 'Overview'),
                NavigationDestination(icon: Icon(Icons.insights_rounded), label: 'Insights'),
                NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
              ],
            )
          : null,
      body: SafeArea(
        child: Row(
          children: [
            if (!isCompact) _SideRail(selectedIndex: _selectedIndex, onSelected: _selectTab),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 20 : constraints.maxWidth > 1100 ? 48 : 28,
                    vertical: 28,
                  ),
                  child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1280),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _DashboardPage(
                          key: ValueKey(_selectedIndex),
                          selectedIndex: _selectedIndex,
                          isCompact: isCompact,
                          isExpanded: _isExpanded,
                          isSyncing: _isSyncing,
                          onSync: _syncSampleData,
                          notificationsEnabled: _notificationsEnabled,
                          isDarkMode: widget.isDarkMode,
                          onToggleNotifications: _toggleNotifications,
                          onShowNotifications: _showNotificationStatus,
                          onToggleTheme: () {
                            _logger.i('Appearance theme toggled');
                            widget.onToggleTheme();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  widget.isDarkMode
                                      ? 'Light theme enabled'
                                      : 'Dark theme enabled',
                                ),
                              ),
                            );
                          },
                          onToggleWelcome: () {
                            _logger.i('Welcome card toggled');
                            setState(() => _isExpanded = !_isExpanded);
                          },
                        ),
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

class _DashboardPage extends StatelessWidget {
  const _DashboardPage({
    super.key,
    required this.selectedIndex,
    required this.isCompact,
    required this.isExpanded,
    required this.isSyncing,
    required this.onSync,
    required this.onToggleWelcome,
    required this.notificationsEnabled,
    required this.isDarkMode,
    required this.onToggleNotifications,
    required this.onShowNotifications,
    required this.onToggleTheme,
  });

  final int selectedIndex;
  final bool isCompact;
  final bool isExpanded;
  final bool isSyncing;
  final Future<void> Function() onSync;
  final VoidCallback onToggleWelcome;
  final bool notificationsEnabled;
  final bool isDarkMode;
  final VoidCallback onToggleNotifications;
  final VoidCallback onShowNotifications;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(isCompact: isCompact),
        const SizedBox(height: 32),
        switch (selectedIndex) {
          1 => const _InsightsPage(),
          2 => _ProfilePage(
              notificationsEnabled: notificationsEnabled,
              isDarkMode: isDarkMode,
              onToggleNotifications: onToggleNotifications,
              onShowNotifications: onShowNotifications,
              onToggleTheme: onToggleTheme,
            ),
          _ => _OverviewPage(
              isCompact: isCompact,
              isExpanded: isExpanded,
              isSyncing: isSyncing,
              onSync: onSync,
              onToggleWelcome: onToggleWelcome,
            ),
        },
      ],
    );
  }
}

class _OverviewPage extends StatelessWidget {
  const _OverviewPage({
    required this.isCompact,
    required this.isExpanded,
    required this.isSyncing,
    required this.onSync,
    required this.onToggleWelcome,
  });

  final bool isCompact;
  final bool isExpanded;
  final bool isSyncing;
  final Future<void> Function() onSync;
  final VoidCallback onToggleWelcome;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good morning, Vaishnavi',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Here is your team rhythm at a glance.',
                    style: TextStyle(color: Color(0xFF91A0B8)),
                  ),
                ],
              ),
            ),
            if (!isCompact)
              ActionChip(
                avatar: isSyncing
                    ? const SizedBox(
                        width: 10,
                        height: 10,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.circle, size: 10, color: Color(0xFF45D6B5)),
                label: Text(isSyncing ? 'Syncing...' : 'Live sync'),
                onPressed: isSyncing ? null : onSync,
              ),
          ],
        ),
        const SizedBox(height: 24),
        _WelcomeCard(
          isExpanded: isExpanded,
          onToggle: onToggleWelcome,
        ),
        const SizedBox(height: 20),
        _StatsGrid(isCompact: isCompact),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 760) {
              return _ActivityCard(isCompact: isCompact);
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(child: _FocusSummaryCard()),
                const SizedBox(width: 20),
                Expanded(child: _ActivityCard(isCompact: isCompact)),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _FocusSummaryCard extends StatelessWidget {
  const _FocusSummaryCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Focus health',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 4),
            Text(
              'A balanced week starts here.',
              style: TextStyle(color: Color(0xFF91A0B8)),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                SizedBox(
                  width: 104,
                  height: 104,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 104,
                        height: 104,
                        child: CircularProgressIndicator(
                          value: 0.84,
                          strokeWidth: 10,
                          backgroundColor: Color(0x1A45D6B5),
                          valueColor: AlwaysStoppedAnimation(Color(0xFF45D6B5)),
                        ),
                      ),
                      Text(
                        '84%',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HealthLegend(color: Color(0xFF45D6B5), label: 'Deep work', value: '6h 24m'),
                      SizedBox(height: 12),
                      _HealthLegend(color: Color(0xFFFFB86B), label: 'In meetings', value: '2h 10m'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HealthLegend extends StatelessWidget {
  const _HealthLegend({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.circle, size: 10, color: color),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(color: Color(0xFF91A0B8)))),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _InsightsPage extends StatelessWidget {
  const _InsightsPage();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Insights',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 6),
        Text(
          'Patterns from your team’s latest activity.',
          style: TextStyle(color: Color(0xFF91A0B8)),
        ),
        SizedBox(height: 20),
        Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What is working',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 16),
                _InsightRow(
                  icon: Icons.trending_up_rounded,
                  title: 'Focus time is up',
                  detail: 'Your team gained 12% focus this week.',
                  color: Color(0xFF45D6B5),
                ),
                SizedBox(height: 16),
                _InsightRow(
                  icon: Icons.groups_rounded,
                  title: 'Collaboration is steady',
                  detail: 'Team pulse is holding at a healthy 92.',
                  color: Color(0xFFB49CFF),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 20),
        Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recommended next steps',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 16),
                _InsightRow(
                  icon: Icons.schedule_rounded,
                  title: 'Protect focus blocks',
                  detail: 'Keep two uninterrupted focus sessions on the calendar.',
                  color: Color(0xFFFFB86B),
                ),
                SizedBox(height: 16),
                _InsightRow(
                  icon: Icons.forum_outlined,
                  title: 'Share the weekly wins',
                  detail: 'Celebrate the progress that is building team momentum.',
                  color: Color(0xFFB49CFF),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({
    required this.icon,
    required this.title,
    required this.detail,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String detail;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(detail, style: const TextStyle(color: Color(0xFF91A0B8))),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage({
    required this.notificationsEnabled,
    required this.isDarkMode,
    required this.onToggleNotifications,
    required this.onShowNotifications,
    required this.onToggleTheme,
  });

  final bool notificationsEnabled;
  final bool isDarkMode;
  final VoidCallback onToggleNotifications;
  final VoidCallback onShowNotifications;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Profile',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        const Text(
          'Your workspace identity and preferences.',
          style: TextStyle(color: Color(0xFF91A0B8)),
        ),
        const SizedBox(height: 20),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: Color(0xFF20304B),
                  child: Text(
                    'V',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                ),
                SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vaishnavi',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Product engineering trainee',
                        style: TextStyle(color: Color(0xFF91A0B8)),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.verified_rounded, color: Color(0xFF45D6B5)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
           children: [
              ListTile(
                onTap: onShowNotifications,
                leading: const Icon(Icons.notifications_none_rounded),
                title: const Text('Notifications'),
                subtitle: Text(
                  notificationsEnabled
                      ? 'Weekly summary enabled'
                      : 'Weekly summary muted',
                ),
                trailing: Icon(
                  notificationsEnabled
                      ? Icons.toggle_on_rounded
                      : Icons.toggle_off_rounded,
                  color: notificationsEnabled
                      ? const Color(0xFF45D6B5)
                      : const Color(0xFF70809A),
                  size: 32,
                ),
              ),
              const Divider(height: 1),
              ListTile(
                onTap: onToggleTheme,
                leading: const Icon(Icons.palette_outlined),
                title: const Text('Appearance'),
                subtitle: Text(isDarkMode ? 'Dark theme' : 'Light theme'),
                trailing: const Icon(Icons.brightness_6_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.isCompact});
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const _BrandStoryScreen(),
              ),
            );
          },
          child: Hero(
            tag: 'brand-mark',
            child: SvgPicture.asset(
              'assets/brand_mark.svg',
              width: isCompact ? 42 : 48,
              height: isCompact ? 42 : 48,
            ),
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Paper Boat', style: TextStyle(fontSize: 13, color: Color(0xFF91A0B8))),
              Text('Pulse dashboard', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
        CircleAvatar(
          radius: 22,
          backgroundColor: const Color(0xFF20304B),
          child: Text('V', style: GoogleFonts.manrope(fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }
}

class _SideRail extends StatelessWidget {
  const _SideRail({required this.selectedIndex, required this.onSelected});
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1727),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0x1AFFFFFF)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 22),
          SvgPicture.asset('assets/brand_mark.svg', width: 42, height: 42),
          const SizedBox(height: 48),
          for (var i = 0; i < 3; i++)
            IconButton(
              tooltip: ['Overview', 'Insights', 'Profile'][i],
              onPressed: () => onSelected(i),
              icon: Icon(
                [Icons.grid_view_rounded, Icons.insights_rounded, Icons.person_outline][i],
                color: selectedIndex == i ? const Color(0xFF45D6B5) : const Color(0xFF70809A),
              ),
            ),
        ],
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({required this.isExpanded, required this.onToggle});
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 560;
        final copy = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FRIDAY, 28 AUGUST',
              style: GoogleFonts.manrope(
                fontSize: 11,
                letterSpacing: 1.4,
                color: const Color(0xFF8DE8D1),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Make room for\nwhat matters.',
              style: GoogleFonts.manrope(
                fontSize: 28,
                height: 1.1,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (isExpanded) ...[
              const SizedBox(height: 12),
              const Text(
                'A calm overview of your team’s momentum this week.',
                style: TextStyle(color: Color(0xB3FFFFFF)),
              ),
            ],
            const SizedBox(height: 18),
            FilledButton.tonal(
              onPressed: onToggle,
              child: Text(isExpanded ? 'Show less' : 'View summary'),
            ),
          ],
        );
        final mark = SvgPicture.asset(
          'assets/brand_mark.svg',
          width: isExpanded ? 130 : 105,
          height: isExpanded ? 130 : 105,
        );

        return AnimatedContainer(
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.all(isExpanded ? 30 : 24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF17463F), Color(0xFF112538)],
            ),
            borderRadius: BorderRadius.circular(26),
          ),
          child: isNarrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [copy, Align(alignment: Alignment.centerRight, child: mark)],
                )
              : Row(children: [Expanded(child: copy), mark]),
        );
      },
    );
  }
}

class _BrandStoryScreen extends StatelessWidget {
  const _BrandStoryScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('The Pulse idea')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: 'brand-mark',
                child: SvgPicture.asset(
                  'assets/brand_mark.svg',
                  width: 220,
                  height: 220,
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Small signals. Clear momentum.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              const Text(
                'Paper Boat Pulse turns weekly team activity into a calm, focused snapshot.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF91A0B8), fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.isCompact});
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final stats = [
      ('Focus score', '84%', '+12%', Icons.track_changes_rounded, const Color(0xFF45D6B5)),
      ('Tasks shipped', '28', '+8', Icons.check_circle_outline_rounded, const Color(0xFFFFB86B)),
      ('Team pulse', '92', '+4', Icons.favorite_border_rounded, const Color(0xFFB49CFF)),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isCompact ? 1 : 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isCompact ? 2.7 : 1.25,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [Icon(stat.$4, color: stat.$5), const Spacer(), Text(stat.$3, style: TextStyle(color: stat.$5, fontWeight: FontWeight.w700))]),
                Text(stat.$2, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
                Text(stat.$1, style: const TextStyle(color: Color(0xFF91A0B8))),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.isCompact});
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Weekly momentum', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text('Your team is building a steady rhythm', style: TextStyle(color: Color(0xFF91A0B8))),
            const SizedBox(height: 18),
            SizedBox(
              height: isCompact ? 180 : 230,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 100,
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [FlSpot(0, 38), FlSpot(1, 52), FlSpot(2, 45), FlSpot(3, 69), FlSpot(4, 62), FlSpot(5, 81), FlSpot(6, 92)],
                      isCurved: true,
                      color: const Color(0xFF45D6B5),
                      barWidth: 4,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: true, color: const Color(0x3345D6B5)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
