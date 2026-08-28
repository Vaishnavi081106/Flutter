import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';

void main() {
  runApp(const PulseApp());
}

class PulseApp extends StatelessWidget {
  const PulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paper Boat Pulse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF080D18),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF45D6B5),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.manropeTextTheme(ThemeData.dark().textTheme),
        cardTheme: CardTheme(
          color: const Color(0xFF111A2B),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Color(0x1AFFFFFF)),
          ),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _logger = Logger();
  int _selectedIndex = 0;
  bool _isExpanded = false;

  void _selectTab(int index) {
    _logger.i('Navigation tab selected: $index');
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.sizeOf(context);
    final isCompact = media.width < 700;
    _logger.d('Dashboard built: ${media.width}x${media.height}');

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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Header(isCompact: isCompact),
                        const SizedBox(height: 32),
                        _WelcomeCard(
                          isExpanded: _isExpanded,
                          onToggle: () {
                            _logger.i('Welcome card toggled');
                            setState(() => _isExpanded = !_isExpanded);
                          },
                        ),
                        const SizedBox(height: 20),
                        _StatsGrid(isCompact: isCompact),
                        const SizedBox(height: 20),
                        _ActivityCard(isCompact: isCompact),
                      ],
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

class _Header extends StatelessWidget {
  const _Header({required this.isCompact});
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Hero(
          tag: 'brand-mark',
          child: SvgPicture.asset('assets/brand_mark.svg', width: isCompact ? 42 : 48, height: isCompact ? 42 : 48),
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.all(isExpanded ? 30 : 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF17463F), Color(0xFF112538)]),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('FRIDAY, 28 AUGUST', style: GoogleFonts.manrope(fontSize: 11, letterSpacing: 1.4, color: const Color(0xFF8DE8D1), fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Text('Make room for\nwhat matters.', style: GoogleFonts.manrope(fontSize: 28, height: 1.1, fontWeight: FontWeight.w800)),
                if (isExpanded) ...[
                  const SizedBox(height: 12),
                  const Text('A calm overview of your team’s momentum this week.', style: TextStyle(color: Color(0xB3FFFFFF))),
                ],
                const SizedBox(height: 18),
                FilledButton.tonal(
                  onPressed: onToggle,
                  child: Text(isExpanded ? 'Show less' : 'View summary'),
                ),
              ],
            ),
          ),
          if (MediaQuery.sizeOf(context).width > 450)
            SvgPicture.asset('assets/brand_mark.svg', width: isExpanded ? 130 : 105, height: isExpanded ? 130 : 105),
        ],
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
