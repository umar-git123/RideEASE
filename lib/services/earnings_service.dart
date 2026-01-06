import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ride_model.dart';

class EarningsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get all completed rides for a driver
  Future<List<RideModel>> getCompletedRides(String driverId) async {
    try {
      final response = await _supabase
          .from('rides')
          .select()
          .eq('driver_id', driverId)
          .eq('status', 'completed')
          .order('created_at', ascending: false);

      return (response as List).map((e) => RideModel.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching completed rides: $e');
      return [];
    }
  }

  /// Calculate total earnings from completed rides
  Future<double> getTotalEarnings(String driverId) async {
    final rides = await getCompletedRides(driverId);
    return rides.fold<double>(0, (sum, ride) => sum + (ride.fare ?? 0));
  }

  /// Get earnings for a specific period
  Future<EarningsSummary> getEarningsSummary(String driverId, {EarningsPeriod period = EarningsPeriod.week}) async {
    final rides = await getCompletedRides(driverId);
    
    final now = DateTime.now();
    DateTime startDate;
    
    switch (period) {
      case EarningsPeriod.today:
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case EarningsPeriod.week:
        startDate = now.subtract(const Duration(days: 7));
        break;
      case EarningsPeriod.month:
        startDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case EarningsPeriod.all:
        startDate = DateTime(2000);
        break;
    }

    final periodRides = rides.where((r) => r.createdAt.isAfter(startDate)).toList();
    final totalEarnings = periodRides.fold<double>(0, (sum, ride) => sum + (ride.fare ?? 0));
    final tripCount = periodRides.length;
    
    // Calculate average per trip
    final avgPerTrip = tripCount > 0 ? totalEarnings / tripCount : 0.0;
    
    // Calculate hours (estimate based on average ride time of 25 mins)
    final estimatedHours = (tripCount * 25) / 60;

    return EarningsSummary(
      totalEarnings: totalEarnings,
      tripCount: tripCount,
      estimatedHours: estimatedHours,
      avgPerTrip: avgPerTrip,
      period: period,
      recentRides: periodRides.take(10).toList(),
    );
  }

  /// Get daily breakdown for the week
  Future<List<DailyEarning>> getWeeklyBreakdown(String driverId) async {
    final rides = await getCompletedRides(driverId);
    final now = DateTime.now();
    
    List<DailyEarning> dailyEarnings = [];
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));
      
      final dayRides = rides.where((r) => 
        r.createdAt.isAfter(dayStart) && r.createdAt.isBefore(dayEnd)
      ).toList();
      
      final dayTotal = dayRides.fold<double>(0, (sum, ride) => sum + (ride.fare ?? 0));
      
      dailyEarnings.add(DailyEarning(
        date: dayStart,
        amount: dayTotal,
        tripCount: dayRides.length,
      ));
    }
    
    return dailyEarnings;
  }
}

enum EarningsPeriod { today, week, month, all }

class EarningsSummary {
  final double totalEarnings;
  final int tripCount;
  final double estimatedHours;
  final double avgPerTrip;
  final EarningsPeriod period;
  final List<RideModel> recentRides;

  EarningsSummary({
    required this.totalEarnings,
    required this.tripCount,
    required this.estimatedHours,
    required this.avgPerTrip,
    required this.period,
    required this.recentRides,
  });
}

class DailyEarning {
  final DateTime date;
  final double amount;
  final int tripCount;

  DailyEarning({
    required this.date,
    required this.amount,
    required this.tripCount,
  });
}
