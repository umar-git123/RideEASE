import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/earnings_service.dart';
import 'package:intl/intl.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({Key? key}) : super(key: key);

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  final EarningsService _earningsService = EarningsService();
  EarningsSummary? _summary;
  List<DailyEarning>? _weeklyBreakdown;
  EarningsPeriod _selectedPeriod = EarningsPeriod.week;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEarnings();
  }

  Future<void> _loadEarnings() async {
    setState(() => _isLoading = true);
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final driverId = authProvider.currentUserData?.id;
    
    if (driverId != null) {
      final summary = await _earningsService.getEarningsSummary(driverId, period: _selectedPeriod);
      final breakdown = await _earningsService.getWeeklyBreakdown(driverId);
      
      if (mounted) {
        setState(() {
          _summary = summary;
          _weeklyBreakdown = breakdown;
          _isLoading = false;
        });
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Earnings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            )
          : RefreshIndicator(
              onRefresh: _loadEarnings,
              color: AppTheme.primaryColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Period Selector
                    _buildPeriodSelector(),
                    const SizedBox(height: 20),
                    
                    // Main Earnings Card
                    _buildEarningsCard(theme),
                    const SizedBox(height: 24),
                    
                    // Weekly Chart
                    if (_weeklyBreakdown != null) ...[
                      Text(
                        'This Week',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildWeeklyChart(),
                      const SizedBox(height: 24),
                    ],
                    
                    // Recent Trips Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Trips',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('See All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildRecentTripsList(),
                    
                    const SizedBox(height: 24),
                    
                    // Withdrawal Card
                    _buildWithdrawalCard(theme),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      decoration: AppTheme.cardDecoration(borderRadius: 12),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: EarningsPeriod.values.map((period) {
          final isSelected = period == _selectedPeriod;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedPeriod = period);
                _loadEarnings();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppTheme.primaryGradient : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _getPeriodLabel(period),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.black : AppTheme.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getPeriodLabel(EarningsPeriod period) {
    switch (period) {
      case EarningsPeriod.today:
        return 'Today';
      case EarningsPeriod.week:
        return 'Week';
      case EarningsPeriod.month:
        return 'Month';
      case EarningsPeriod.all:
        return 'All Time';
    }
  }

  Widget _buildEarningsCard(ThemeData theme) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Total Earnings',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currencyFormat.format(_summary?.totalEarnings ?? 0),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 42,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Trips',
                  '${_summary?.tripCount ?? 0}',
                  Icons.directions_car_outlined,
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: Colors.black.withOpacity(0.1),
                ),
                _buildStatItem(
                  'Hours',
                  (_summary?.estimatedHours ?? 0).toStringAsFixed(1),
                  Icons.access_time_outlined,
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: Colors.black.withOpacity(0.1),
                ),
                _buildStatItem(
                  'Avg/Trip',
                  '\$${(_summary?.avgPerTrip ?? 0).toStringAsFixed(0)}',
                  Icons.trending_up_outlined,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.black54, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.black.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyChart() {
    if (_weeklyBreakdown == null || _weeklyBreakdown!.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxAmount = _weeklyBreakdown!
        .map((e) => e.amount)
        .reduce((a, b) => a > b ? a : b);
    final chartHeight = 120.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        children: [
          SizedBox(
            height: chartHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _weeklyBreakdown!.map((daily) {
                final barHeight = maxAmount > 0
                    ? (daily.amount / maxAmount) * chartHeight
                    : 0.0;
                final isToday = DateFormat('EEE').format(daily.date) ==
                    DateFormat('EEE').format(DateTime.now());

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (daily.amount > 0)
                          Text(
                            '\$${daily.amount.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 10,
                              color: isToday
                                  ? AppTheme.primaryColor
                                  : AppTheme.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: barHeight > 8 ? barHeight : (daily.amount > 0 ? 8 : 4),
                          decoration: BoxDecoration(
                            gradient: isToday
                                ? AppTheme.primaryGradient
                                : const LinearGradient(
                                    colors: [
                                      AppTheme.surfaceGlass,
                                      AppTheme.backgroundElevated,
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: _weeklyBreakdown!.map((daily) {
              final isToday = DateFormat('EEE').format(daily.date) ==
                  DateFormat('EEE').format(DateTime.now());
              return Expanded(
                child: Text(
                  DateFormat('EEE').format(daily.date).substring(0, 1),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: isToday ? AppTheme.primaryColor : AppTheme.textMuted,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTripsList() {
    if (_summary == null || _summary!.recentRides.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: AppTheme.cardDecoration(),
        child: Column(
          children: [
            Icon(
              Icons.directions_car_outlined,
              size: 48,
              color: AppTheme.textMuted.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No completed trips yet',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Complete rides to see your earnings here',
              style: TextStyle(
                color: AppTheme.textMuted.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _summary!.recentRides.length,
      itemBuilder: (context, index) {
        final ride = _summary!.recentRides[index];
        final fare = ride.fare ?? 0;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: AppTheme.cardDecoration(),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.directions_car,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
            title: Text(
              ride.destinationAddress ?? 'Trip to destination',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              DateFormat('MMM d, h:mm a').format(ride.createdAt),
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 12,
              ),
            ),
            trailing: Text(
              '+\$${fare.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppTheme.successColor,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWithdrawalCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glassDecoration(),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AppTheme.goldGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.account_balance_wallet,
              color: Colors.black87,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ready to withdraw?',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'Transfer earnings to your bank',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Withdraw',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
