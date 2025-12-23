import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nutriary_fe/src/core/di/injection.dart';
import 'bloc/statistics_bloc.dart';
import 'bloc/statistics_event.dart';
import 'bloc/statistics_state.dart';
import '../../group/presentation/bloc/group_bloc.dart';
import '../../group/presentation/bloc/group_state.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late StatisticsBloc _bloc;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _bloc = getIt<StatisticsBloc>();
    _loadData();
  }

  void _loadData([int? groupId]) {
    final from = _dateRange?.start.toIso8601String().split('T').first;
    final to = _dateRange?.end.toIso8601String().split('T').first;

    // Try to get groupId from context if not provided
    int? effectiveGroupId = groupId;
    if (effectiveGroupId == null) {
      try {
        effectiveGroupId = context.read<GroupBloc>().state.selectedGroupId;
      } catch (e) {
        // GroupBloc might not be available in tests or some contexts
        debugPrint('GroupBloc not found or error accessing state: $e');
      }
    }

    _bloc.add(
      LoadConsumptionStats(from: from, to: to, groupId: effectiveGroupId),
    );
    _bloc.add(LoadShoppingStats(from: from, to: to, groupId: effectiveGroupId));
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange:
          _dateRange ??
          DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 30)),
            end: DateTime.now(),
          ),
    );
    if (picked != null) {
      setState(() => _dateRange = picked);
      _loadData();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocListener<GroupBloc, GroupState>(
        listenWhen: (previous, current) =>
            previous.selectedGroupId != current.selectedGroupId,
        listener: (context, state) {
          _loadData(state.selectedGroupId);
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Thống kê'),
            actions: [
              IconButton(
                icon: const Icon(LucideIcons.calendar),
                onPressed: _selectDateRange,
                tooltip: 'Chọn khoảng thời gian',
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(LucideIcons.pieChart), text: 'Tiêu thụ'),
                Tab(icon: Icon(LucideIcons.shoppingCart), text: 'Mua sắm'),
              ],
            ),
          ),
          body: Column(
            children: [
              // Date range indicator
              if (_dateRange != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withAlpha(50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.calendar, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        '${_formatDate(_dateRange!.start)} - ${_formatDate(_dateRange!.end)}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          setState(() => _dateRange = null);
                          _loadData();
                        },
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [_ConsumptionTab(), _ShoppingTab()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _ConsumptionTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatisticsBloc, StatisticsState>(
      builder: (context, state) {
        if (state.status == StatisticsStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.consumptionStats.isEmpty) {
          return _EmptyState(
            icon: LucideIcons.pieChart,
            message: 'Chưa có dữ liệu tiêu thụ',
            subMessage: 'Hãy thêm thực phẩm vào tủ lạnh và sử dụng chúng',
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pie Chart
              _buildSectionTitle(context, 'Tổng quan tiêu thụ'),
              const SizedBox(height: 16),
              SizedBox(
                height: 220,
                child: _ConsumptionPieChart(stats: state.consumptionStats),
              ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),

              const SizedBox(height: 24),

              // Bar Chart
              _buildSectionTitle(context, 'Chi tiết theo món'),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: _ConsumptionBarChart(
                  stats: state.consumptionStats.take(8).toList(),
                ),
              ).animate().slideX(begin: 0.3, duration: 400.ms),

              const SizedBox(height: 24),

              // List
              _buildSectionTitle(context, 'Danh sách chi tiết'),
              const SizedBox(height: 8),
              ...state.consumptionStats.asMap().entries.map((entry) {
                final stat = entry.value;
                return _StatCard(
                      icon: stat.action == 'consume'
                          ? LucideIcons.utensils
                          : LucideIcons.plus,
                      iconColor: stat.action == 'consume'
                          ? Colors.orange
                          : Colors.green,
                      title: stat.foodName,
                      subtitle:
                          '${stat.action == 'consume' ? 'Đã tiêu thụ' : 'Đã thêm'}: ${stat.count} lần',
                      trailing: '${stat.totalQuantity.toStringAsFixed(1)}',
                    )
                    .animate(delay: Duration(milliseconds: 50 * entry.key))
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.2);
              }),
            ],
          ),
        );
      },
    );
  }
}

class _ShoppingTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatisticsBloc, StatisticsState>(
      builder: (context, state) {
        if (state.status == StatisticsStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.shoppingStats.isEmpty) {
          return _EmptyState(
            icon: LucideIcons.shoppingCart,
            message: 'Chưa có dữ liệu mua sắm',
            subMessage: 'Hãy tạo danh sách mua sắm và thêm các món',
          );
        }

        final totalQuantity = state.shoppingStats.fold<double>(
          0,
          (sum, s) => sum + s.totalQuantity,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Card
              _SummaryCard(
                    title: 'Tổng số lượng mua',
                    value: totalQuantity.toStringAsFixed(0),
                    subtitle: '${state.shoppingStats.length} loại thực phẩm',
                    icon: LucideIcons.shoppingBag,
                    color: Colors.blue,
                  )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .scale(begin: const Offset(0.9, 0.9)),

              const SizedBox(height: 24),

              // Pie Chart
              _buildSectionTitle(context, 'Phân bổ mua sắm'),
              const SizedBox(height: 16),
              SizedBox(
                height: 220,
                child: _ShoppingPieChart(stats: state.shoppingStats),
              ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),

              const SizedBox(height: 24),

              // Bar Chart
              _buildSectionTitle(context, 'Top món mua nhiều'),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: _ShoppingBarChart(
                  stats: state.shoppingStats.take(8).toList(),
                ),
              ).animate().slideX(begin: 0.3, duration: 400.ms),

              const SizedBox(height: 24),

              // List
              _buildSectionTitle(context, 'Danh sách chi tiết'),
              const SizedBox(height: 8),
              ...state.shoppingStats.asMap().entries.map((entry) {
                final stat = entry.value;
                return _StatCard(
                      icon: LucideIcons.shoppingBag,
                      iconColor: Colors.blue,
                      title: stat.foodName,
                      subtitle: 'Số lượng đã mua',
                      trailing: '${stat.totalQuantity.toStringAsFixed(1)}',
                    )
                    .animate(delay: Duration(milliseconds: 50 * entry.key))
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.2);
              }),
            ],
          ),
        );
      },
    );
  }
}

// Charts
class _ConsumptionPieChart extends StatelessWidget {
  final List stats;
  const _ConsumptionPieChart({required this.stats});

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.orange,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.amber,
      Colors.pink,
    ];

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: stats.asMap().entries.take(8).map((entry) {
                final stat = entry.value;
                return PieChartSectionData(
                  value: stat.totalQuantity,
                  color: colors[entry.key % colors.length],
                  radius: 50,
                  title: '',
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: stats.take(5).toList().asMap().entries.map((entry) {
            final stat = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[entry.key % colors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    stat.foodName.length > 10
                        ? '${stat.foodName.substring(0, 10)}...'
                        : stat.foodName,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ShoppingPieChart extends StatelessWidget {
  final List stats;
  const _ShoppingPieChart({required this.stats});

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.blue,
      Colors.cyan,
      Colors.indigo,
      Colors.lightBlue,
      Colors.blueAccent,
      Colors.tealAccent,
      Colors.lightBlueAccent,
      Colors.indigoAccent,
    ];

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: stats.asMap().entries.take(8).map((entry) {
                final stat = entry.value;
                return PieChartSectionData(
                  value: stat.totalQuantity,
                  color: colors[entry.key % colors.length],
                  radius: 50,
                  title: '',
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: stats.take(5).toList().asMap().entries.map((entry) {
            final stat = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[entry.key % colors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    stat.foodName.length > 10
                        ? '${stat.foodName.substring(0, 10)}...'
                        : stat.foodName,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ConsumptionBarChart extends StatelessWidget {
  final List stats;
  const _ConsumptionBarChart({required this.stats});

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) return const SizedBox.shrink();

    final maxY = stats.fold<double>(
      0,
      (max, s) => s.totalQuantity > max ? s.totalQuantity : max,
    );

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY * 1.2,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${stats[groupIndex].foodName}\n${rod.toY.toStringAsFixed(1)}',
                const TextStyle(color: Colors.white, fontSize: 12),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= stats.length) return const SizedBox.shrink();
                final name = stats[index].foodName;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    name.length > 4 ? '${name.substring(0, 4)}.' : name,
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: false),
        barGroups: stats.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.totalQuantity,
                gradient: LinearGradient(
                  colors: [Colors.orange.shade300, Colors.orange.shade600],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 20,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _ShoppingBarChart extends StatelessWidget {
  final List stats;
  const _ShoppingBarChart({required this.stats});

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) return const SizedBox.shrink();

    final maxY = stats.fold<double>(
      0,
      (max, s) => s.totalQuantity > max ? s.totalQuantity : max,
    );

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY * 1.2,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${stats[groupIndex].foodName}\n${rod.toY.toStringAsFixed(1)}',
                const TextStyle(color: Colors.white, fontSize: 12),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= stats.length) return const SizedBox.shrink();
                final name = stats[index].foodName;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    name.length > 4 ? '${name.substring(0, 4)}.' : name,
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: false),
        barGroups: stats.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.totalQuantity,
                gradient: LinearGradient(
                  colors: [Colors.blue.shade300, Colors.blue.shade600],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 20,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// UI Components
Widget _buildSectionTitle(BuildContext context, String title) {
  return Text(
    title,
    style: Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
  );
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String subMessage;

  const _EmptyState({
    required this.icon,
    required this.message,
    required this.subMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 64, color: Colors.grey[400]),
          ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 24),
          Text(
            message,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 8),
          Text(
            subMessage,
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withAlpha(200), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(80),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(50),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withAlpha(200),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withAlpha(180),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String trailing;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withAlpha(30),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: iconColor.withAlpha(20),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            trailing,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }
}
