import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../models/food_tracking/food_log.dart' hide NutritionSummary;
import '../../models/food_tracking/nutrition_summary.dart';
import '../../services/food_tracking_service.dart';
import '../../services/api_service.dart';

/// Food report screen - displays nutrition analytics and meal history
class FoodReportScreen extends StatefulWidget {
  const FoodReportScreen({super.key});

  @override
  State<FoodReportScreen> createState() => _FoodReportScreenState();
}

class _FoodReportScreenState extends State<FoodReportScreen> {
  DateRange _selectedRange = DateRange.today;
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  bool _isLoading = false;
  
  // Mock data - TODO: Replace with actual API calls
  final List<FoodLog> _mockMealHistory = [];
  NutritionSummary? _mockSummary;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Get API service with authentication
      final apiService = context.read<ApiService>();
      final foodTrackingService = FoodTrackingService(apiService);

      // Fetch food logs and nutrition summary from API
      final logs = await foodTrackingService.getFoodLogs(
        startDate: _getStartDate(),
        endDate: _getEndDate(),
      );

      final summary = await foodTrackingService.getNutritionSummary(
        startDate: _getStartDate(),
        endDate: _getEndDate(),
      );

      setState(() {
        _mockMealHistory.clear();
        _mockMealHistory.addAll(logs);
        _mockSummary = summary;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  DateTime _getStartDate() {
    switch (_selectedRange) {
      case DateRange.today:
        return DateTime.now().copyWith(hour: 0, minute: 0, second: 0);
      case DateRange.week:
        return DateTime.now().subtract(const Duration(days: 7));
      case DateRange.month:
        return DateTime.now().subtract(const Duration(days: 30));
      case DateRange.custom:
        return _customStartDate ?? DateTime.now().subtract(const Duration(days: 7));
    }
  }

  DateTime _getEndDate() {
    switch (_selectedRange) {
      case DateRange.today:
        return DateTime.now().copyWith(hour: 23, minute: 59, second: 59);
      case DateRange.week:
      case DateRange.month:
        return DateTime.now();
      case DateRange.custom:
        return _customEndDate ?? DateTime.now();
    }
  }

  Future<void> _selectCustomDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _customStartDate ?? DateTime.now().subtract(const Duration(days: 7)),
        end: _customEndDate ?? DateTime.now(),
      ),
    );

    if (picked != null) {
      setState(() {
        _customStartDate = picked.start;
        _customEndDate = picked.end;
        _selectedRange = DateRange.custom;
      });
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition Report'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // TODO: Implement PDF export
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('PDF export coming soon!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            tooltip: 'Export PDF',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: CustomScrollView(
                slivers: [
                  // Date range selector
                  SliverToBoxAdapter(
                    child: _buildDateRangeSelector(),
                  ),

                  // Summary cards
                  if (_mockSummary != null) ...[
                    SliverToBoxAdapter(
                      child: _buildSummaryCards(),
                    ),

                    // Calorie trend chart
                    SliverToBoxAdapter(
                      child: _buildCalorieTrendChart(),
                    ),

                    // Macro distribution
                    SliverToBoxAdapter(
                      child: _buildMacroDistribution(),
                    ),

                    // Meal breakdown
                    SliverToBoxAdapter(
                      child: _buildMealBreakdown(),
                    ),
                  ],

                  // Meal history header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                      child: Row(
                        children: [
                          const Icon(Icons.history, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Recent Meals',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Meal history list
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (_mockMealHistory.isEmpty) {
                          return _buildEmptyState();
                        }
                        return _buildMealHistoryItem(_mockMealHistory[index]);
                      },
                      childCount: _mockMealHistory.isEmpty ? 1 : _mockMealHistory.length,
                    ),
                  ),

                  // Bottom padding
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 20),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Time Period',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildRangeChip(DateRange.today, 'Today'),
              _buildRangeChip(DateRange.week, 'This Week'),
              _buildRangeChip(DateRange.month, 'This Month'),
              _buildCustomRangeChip(),
            ],
          ),
          if (_selectedRange == DateRange.custom &&
              _customStartDate != null &&
              _customEndDate != null) ...[
            const SizedBox(height: 8),
            Text(
              '${DateFormat('MMM dd, yyyy').format(_customStartDate!)} - ${DateFormat('MMM dd, yyyy').format(_customEndDate!)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRangeChip(DateRange range, String label) {
    final isSelected = _selectedRange == range;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedRange = range);
          _loadData();
        }
      },
      selectedColor: Colors.blue.withOpacity(0.2),
      checkmarkColor: Colors.blue,
    );
  }

  Widget _buildCustomRangeChip() {
    final isSelected = _selectedRange == DateRange.custom;
    return FilterChip(
      label: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today, size: 16),
          SizedBox(width: 4),
          Text('Custom'),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          _selectCustomDateRange();
        }
      },
      selectedColor: Colors.blue.withOpacity(0.2),
      checkmarkColor: Colors.blue,
    );
  }

  Widget _buildSummaryCards() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Total Calories',
                  value: _mockSummary!.totalCalories.toStringAsFixed(0),
                  unit: 'kcal',
                  icon: Icons.local_fire_department,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Avg Daily',
                  value: _mockSummary!.averageDailyCalories.toStringAsFixed(0),
                  unit: 'kcal',
                  icon: Icons.timeline,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Protein',
                  value: _mockSummary!.totalProtein.toStringAsFixed(0),
                  unit: 'g',
                  icon: Icons.fitness_center,
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Carbs',
                  value: _mockSummary!.totalCarbs.toStringAsFixed(0),
                  unit: 'g',
                  icon: Icons.cake,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Fat',
                  value: _mockSummary!.totalFat.toStringAsFixed(0),
                  unit: 'g',
                  icon: Icons.opacity,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSummaryCard(
            title: 'Total Meals Logged',
            value: _mockSummary!.mealCount.toString(),
            unit: 'meals',
            icon: Icons.restaurant,
            color: Colors.green,
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
    bool fullWidth = false,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.1),
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    unit,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalorieTrendChart() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.show_chart, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Daily Calorie Trend',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 500,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey.withOpacity(0.2),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 45,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                            if (value.toInt() >= 0 && value.toInt() < days.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  days[value.toInt()],
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: 6,
                    minY: 0,
                    maxY: 2500,
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          const FlSpot(0, 1800),
                          const FlSpot(1, 2100),
                          const FlSpot(2, 1900),
                          const FlSpot(3, 2200),
                          const FlSpot(4, 1750),
                          const FlSpot(5, 2000),
                          const FlSpot(6, 1850),
                        ],
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: Colors.blue,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.blue.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacroDistribution() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.pie_chart, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Macro Distribution',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: [
                            PieChartSectionData(
                              value: _mockSummary!.totalProtein,
                              title: '${(_mockSummary!.totalProtein / (_mockSummary!.totalProtein + _mockSummary!.totalCarbs + _mockSummary!.totalFat) * 100).toInt()}%',
                              color: Colors.red,
                              radius: 60,
                              titleStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            PieChartSectionData(
                              value: _mockSummary!.totalCarbs,
                              title: '${(_mockSummary!.totalCarbs / (_mockSummary!.totalProtein + _mockSummary!.totalCarbs + _mockSummary!.totalFat) * 100).toInt()}%',
                              color: Colors.amber,
                              radius: 60,
                              titleStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            PieChartSectionData(
                              value: _mockSummary!.totalFat,
                              title: '${(_mockSummary!.totalFat / (_mockSummary!.totalProtein + _mockSummary!.totalCarbs + _mockSummary!.totalFat) * 100).toInt()}%',
                              color: Colors.deepPurple,
                              radius: 60,
                              titleStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLegendItem('Protein', Colors.red, '${_mockSummary!.totalProtein.toInt()}g'),
                          const SizedBox(height: 8),
                          _buildLegendItem('Carbs', Colors.amber, '${_mockSummary!.totalCarbs.toInt()}g'),
                          const SizedBox(height: 8),
                          _buildLegendItem('Fat', Colors.deepPurple, '${_mockSummary!.totalFat.toInt()}g'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, String value) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildMealBreakdown() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.bar_chart, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Meals by Type',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 5,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const titles = ['🍳', '🥗', '🍽️', '🍪'];
                            if (value.toInt() >= 0 && value.toInt() < titles.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  titles[value.toInt()],
                                  style: const TextStyle(fontSize: 20),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 1,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey.withOpacity(0.2),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      BarChartGroupData(
                        x: 0,
                        barRods: [
                          BarChartRodData(
                            toY: 3,
                            color: Colors.orange,
                            width: 40,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 1,
                        barRods: [
                          BarChartRodData(
                            toY: 4,
                            color: Colors.green,
                            width: 40,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 2,
                        barRods: [
                          BarChartRodData(
                            toY: 3,
                            color: Colors.blue,
                            width: 40,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 3,
                        barRods: [
                          BarChartRodData(
                            toY: 2,
                            color: Colors.purple,
                            width: 40,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('Breakfast', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  Text('Lunch', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  Text('Dinner', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  Text('Snack', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealHistoryItem(FoodLog meal) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to meal detail/edit screen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('View/Edit ${meal.foodName}'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Meal type icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getMealTypeColor(meal.mealType).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  meal.mealType.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 16),

              // Meal info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.foodName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${meal.mealType.displayName} • ${DateFormat('MMM dd, hh:mm a').format(meal.consumedAt)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildNutrientChip(
                          '${meal.calories?.toInt() ?? 0} kcal',
                          Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        _buildNutrientChip(
                          'P: ${meal.proteinGrams?.toInt() ?? 0}g',
                          Colors.red,
                        ),
                        const SizedBox(width: 8),
                        _buildNutrientChip(
                          'C: ${meal.carbsGrams?.toInt() ?? 0}g',
                          Colors.amber,
                        ),
                        const SizedBox(width: 8),
                        _buildNutrientChip(
                          'F: ${meal.fatGrams?.toInt() ?? 0}g',
                          Colors.deepPurple,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow icon
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutrientChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color _getMealTypeColor(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return Colors.orange;
      case MealType.lunch:
        return Colors.green;
      case MealType.dinner:
        return Colors.blue;
      case MealType.snack:
        return Colors.purple;
    }
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No meals logged yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your meals to see analytics here',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Date range options
enum DateRange {
  today,
  week,
  month,
  custom,
}
