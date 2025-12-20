import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:nutriary_fe/src/core/di/injection.dart';
import 'bloc/statistics_bloc.dart';
import 'bloc/statistics_event.dart';
import 'bloc/statistics_state.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late StatisticsBloc _bloc;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _bloc = getIt<StatisticsBloc>();
    _bloc.add(const LoadConsumptionStats());
    _bloc.add(const LoadShoppingStats());
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
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Thống kê'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(LucideIcons.pieChart), text: 'Tiêu thụ'),
              Tab(icon: Icon(LucideIcons.shoppingCart), text: 'Mua sắm'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [_ConsumptionTab(), _ShoppingTab()],
        ),
      ),
    );
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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.pieChart, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text(
                  'Chưa có dữ liệu tiêu thụ',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: state.consumptionStats.length,
          itemBuilder: (context, index) {
            final stat = state.consumptionStats[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: stat.action == 'consume'
                      ? Colors.orange
                      : Colors.green,
                  child: Icon(
                    stat.action == 'consume'
                        ? LucideIcons.utensils
                        : LucideIcons.plus,
                    color: Colors.white,
                  ),
                ),
                title: Text(stat.foodName),
                subtitle: Text(
                  '${stat.action == 'consume' ? 'Đã tiêu thụ' : 'Đã thêm'}: ${stat.count} lần',
                ),
                trailing: Text(
                  '${stat.totalQuantity.toStringAsFixed(1)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          },
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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.shoppingCart,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Chưa có dữ liệu mua sắm',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: state.shoppingStats.length,
          itemBuilder: (context, index) {
            final stat = state.shoppingStats[index];
            return Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(LucideIcons.shoppingBag, color: Colors.white),
                ),
                title: Text(stat.foodName),
                trailing: Text(
                  '${stat.totalQuantity.toStringAsFixed(1)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
