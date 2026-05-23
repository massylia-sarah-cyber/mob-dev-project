import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ambient_background.dart';
import '../../widgets/glass_card.dart';
import '../../core/services/stats_service.dart';
import '../../core/services/firebase_auth_service.dart';
import 'package:provider/provider.dart';
import '../../core/providers/music_provider.dart';
import '../../navigation/main_scaffold.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _totalSeconds = 0;
  int _goalHours = 20;
  Map<int, double> _dailyMinutes = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final total = await StatsService.instance.getTotalListeningSeconds();
      final goal = await StatsService.instance.getMonthlyGoalHours();
      final daily = await StatsService.instance.getDailyMinutesThisMonth();
      if (mounted) {
        setState(() {
          _totalSeconds = total;
          _goalHours = goal;
          _dailyMinutes = daily;
        });
      }
    } catch (e) {
      debugPrint('⚠️ Stats loading failed (offline?): $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AmbientBackground(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              pinned: true,
              leading: IconButton(
                icon: const Icon(Icons.menu, color: AppColors.primary), 
                onPressed: () => MainScaffold.of(context)?.openDrawer(),
              ),
              title: const Text('MELODY', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, letterSpacing: 2)),
              actions: [
                const CircleAvatar(
                  backgroundColor: AppColors.surfaceContainerHighest,
                  backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuD2RUf0361taIWjap8pCT6E9xx_aPCETtzPol369lfjNcA-cgOMVGcJFkU7R7cNKPR0U28Yfy-xSZI2yWO32Sukd7lBT4q2-kXnQQ0Qo9ZKtbyFuPOhpKEkKPbSZn8iPLxfOiQEOLlLowfTG6-38AUKi0k860xkkLCNP7ULg9aigjg0KsjKB3It2166Ods4-JM4NNVUkbcJzqMNgY8occF9FiK0KTFaVASMo_98dTU_eYqmcMQAL0bK9xLZeSv4Fk5erAybwrjH5e0'),
                ),
                const SizedBox(width: 24),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.all(24.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary, width: 2),
                          image: const DecorationImage(
                            image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuD2RUf0361taIWjap8pCT6E9xx_aPCETtzPol369lfjNcA-cgOMVGcJFkU7R7cNKPR0U28Yfy-xSZI2yWO32Sukd7lBT4q2-kXnQQ0Qo9ZKtbyFuPOhpKEkKPbSZn8iPLxfOiQEOLlLowfTG6-38AUKi0k860xkkLCNP7ULg9aigjg0KsjKB3It2166Ods4-JM4NNVUkbcJzqMNgY8occF9FiK0KTFaVASMo_98dTU_eYqmcMQAL0bK9xLZeSv4Fk5erAybwrjH5e0'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(FirebaseAuthService.instance.currentUser?.displayName ?? 'Melody User', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(FirebaseAuthService.instance.currentUser?.email ?? 'user@melody.app', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.primary)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: AppColors.outline),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),

                  // Stats Grid Let's make it responsive
                  if (MediaQuery.of(context).size.width > 800)
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(flex: 1, child: _buildListeningTimeCard(context)),
                          const SizedBox(width: 24),
                          Expanded(flex: 2, child: _buildActivityChartCard(context)),
                        ],
                      ),
                    )
                  else
                    Column(
                      children: [
                        _buildListeningTimeCard(context),
                        const SizedBox(height: 24),
                        _buildActivityChartCard(context),
                      ],
                    ),
                  
                  const SizedBox(height: 24),
                  _buildGoalCard(context),

                  const SizedBox(height: 48),
                  
                  // Most played tracks
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Most Played Tracks', style: Theme.of(context).textTheme.headlineMedium),
                      TextButton(onPressed: () {}, child: const Text('SEE ALL', style: TextStyle(color: AppColors.primary, letterSpacing: 2, fontSize: 12))),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  Consumer<MusicProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      final tracks = provider.currentTracks.take(4).toList();
                      if (tracks.isEmpty) {
                        return const Text('No tracks available yet.', style: TextStyle(color: AppColors.outlineVariant));
                      }
                      
                      return GridView.count(
                        crossAxisCount: MediaQuery.of(context).size.width > 800 ? 4 : 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 24,
                        mainAxisSpacing: 24,
                        childAspectRatio: 0.8,
                        children: tracks.map((track) {
                          return _buildTrackCard(
                            context,
                            track.name,
                            track.artistName,
                            track.image.isNotEmpty ? track.image : 'https://fakeimg.pl/400x400/282828/eae0d0/'
                          );
                        }).toList(),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 120), // Bottom padding for nav bar
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListeningTimeCard(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TOTAL LISTENING TIME', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.primary)),
              const Icon(Icons.schedule, color: AppColors.outlineVariant, size: 48),
            ],
          ),
          const SizedBox(height: 16),
          Text(StatsService.formatSeconds(_totalSeconds), style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.trending_up, color: AppColors.secondary, size: 16),
              const SizedBox(width: 8),
              Text('Keep it up!', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.secondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityChartCard(BuildContext context) {
    // Convert daily stats to normalized heights for the histogram (max 60 mins)
    final last30Days = List.generate(30, (index) {
      final day = DateTime.now().subtract(Duration(days: 29 - index));
      return _dailyMinutes[day.day] ?? 0.0;
    });
    
    final maxMins = last30Days.reduce((a, b) => a > b ? a : b);
    final normalizationFactor = maxMins > 0 ? maxMins : 60.0;
    final heights = last30Days.map((m) => (m / normalizationFactor).clamp(0.0, 1.0)).toList();
    
    return GlassCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Activity', style: Theme.of(context).textTheme.headlineSmall),
              Text('LAST 30 DAYS', style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(heights.length, (index) {
                final isPeak = heights[index] > 0.9;
                return Container(
                  width: 4, // thin bars for 30 items
                  height: (120 * heights[index].toDouble()).clamp(2.0, 120.0),
                  decoration: BoxDecoration(
                    color: isPeak ? AppColors.primary : AppColors.surfaceContainerHighest,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context) {
    final progress = _totalSeconds / (_goalHours * 3600);
    final percentage = (progress * 100).clamp(0, 100).toInt();

    return GlassCard(
      padding: const EdgeInsets.all(32),
      child: Flex(
        direction: MediaQuery.of(context).size.width > 600 ? Axis.horizontal : Axis.vertical,
        children: [
          Flexible(
            flex: MediaQuery.of(context).size.width > 600 ? 1 : 0,
            fit: MediaQuery.of(context).size.width > 600 ? FlexFit.tight : FlexFit.loose,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Monthly Goal ', style: Theme.of(context).textTheme.headlineSmall),
                    DropdownButton<int>(
                      value: _goalHours,
                      dropdownColor: AppColors.surfaceContainerHigh,
                      underline: const SizedBox(),
                      icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                      items: [10, 20, 30, 50].map((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text('${value}h', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.primary)),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _goalHours = newValue;
                          });
                          StatsService.instance.setMonthlyGoalHours(newValue);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(percentage >= 100 ? "Goal Met!" : "Keep listening!", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.width > 600 ? 0 : 24, width: 24),
          Flexible(
            flex: MediaQuery.of(context).size.width > 600 ? 2 : 0,
            fit: MediaQuery.of(context).size.width > 600 ? FlexFit.tight : FlexFit.loose,
            child: Container(
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.width > 600 ? 0 : 24, width: 24),
          Text('$percentage%', style: Theme.of(context).textTheme.headlineMedium),
        ],
      ),
    );
  }

  Widget _buildTrackCard(BuildContext context, String title, String subtitle, String imageUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant)),
      ],
    );
  }
}
