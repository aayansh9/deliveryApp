import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescueeats/core/appTheme/appColors.dart';
import 'package:rescueeats/core/model/orderModel.dart';
import 'package:rescueeats/screens/order/orderLogic.dart';
import 'package:rescueeats/screens/user/customerHomeTab.dart';
import 'package:rescueeats/screens/user/profileScreen.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const CustomerHomeTab(),
    const CustomerOrdersTab(),
    const CustomerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[200]!)),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) =>
              setState(() => _selectedIndex = index),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          indicatorColor: AppColors.primary.withOpacity(0.1), // Orange tint
          elevation: 0,
          height: 65,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(
                Icons.explore,
                color: AppColors.primary,
              ), // Orange
              label: 'Explore',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(
                Icons.receipt_long,
                color: AppColors.primary,
              ), // Orange
              label: 'Orders',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(
                Icons.person,
                color: AppColors.primary,
              ), // Orange
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// --- TAB 2: ORDERS SCREEN ---
class CustomerOrdersTab extends ConsumerWidget {
  const CustomerOrdersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncOrders = ref.watch(orderControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Orders",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black54),
            onPressed: () => ref.refresh(orderControllerProvider),
          ),
        ],
      ),
      body: asyncOrders.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
        ), // Orange Loader
        error: (error, stack) => Center(child: Text("Error loading orders")),
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 48,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "No past orders",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final sortedOrders = List<OrderModel>.from(orders)
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: sortedOrders.length,
            separatorBuilder: (context, index) => const SizedBox(height: 24),
            itemBuilder: (context, index) {
              final order = sortedOrders[index];
              return _buildMinimalOrderRow(order);
            },
          );
        },
      ),
    );
  }

  Widget _buildMinimalOrderRow(OrderModel order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Row: Restaurant & Price
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                order.restaurantName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              "Rs. ${order.totalAmount.toStringAsFixed(0)}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ), // Orange Price
            ),
          ],
        ),
        const SizedBox(height: 4),

        // Date & Status
        Row(
          children: [
            Text(
              _formatDate(order.createdAt),
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
            const SizedBox(width: 8),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            _buildSimpleStatus(order.status),
          ],
        ),

        const SizedBox(height: 12),

        // Items
        Text(
          order.items.join(" • "),
          style: TextStyle(color: Colors.grey[700], fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 16),

        // Action Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: AppColors.primary,
                  ), // Orange Border
                  foregroundColor: AppColors.primary, // Orange Text
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 0),
                ),
                child: const Text("Reorder"),
              ),
            ),
            const SizedBox(width: 12),
            if (order.status != OrderStatus.delivered &&
                order.status != OrderStatus.cancelled)
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary, // Orange Background
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Track",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Divider(height: 1, color: Colors.grey[100]),
      ],
    );
  }

  Widget _buildSimpleStatus(OrderStatus status) {
    Color color;
    String text = status.name[0].toUpperCase() + status.name.substring(1);

    switch (status) {
      case OrderStatus.pending:
        color = Colors.orange;
        break;
      case OrderStatus.cooking:
        color = Colors.blue;
        break;
      case OrderStatus.ready:
        color = Colors.purple;
        break;
      case OrderStatus.pickedUp:
        color = Colors.indigo;
        break;
      case OrderStatus.delivered:
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return Row(
      children: [
        Icon(Icons.circle, size: 8, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    return "${dt.day}/${dt.month} • ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
  }
}
