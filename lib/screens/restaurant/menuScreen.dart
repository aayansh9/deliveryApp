import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescueeats/core/appTheme/appColors.dart';
import 'package:rescueeats/core/model/menuModel.dart';
import 'package:rescueeats/features/providers/cartNotifier.dart';

class RestaurantMenuScreen extends ConsumerWidget {
  const RestaurantMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuItems = ref.watch(menuProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Menu"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(item.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              title: Text(
                item.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              // UPDATED DISPLAY TO RS.
              subtitle: Text(
                "Rs. ${item.price.toStringAsFixed(0)} • ${item.isAvailable ? 'Available' : 'Sold Out'}",
              ),
              trailing: Switch(
                value: item.isAvailable,
                activeThumbColor: AppColors.primary,
                onChanged: (val) {
                  ref.read(menuProvider.notifier).toggleAvailability(item.id);
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddFoodDialog(context, ref),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text("Add Item"),
      ),
    );
  }

  void _showAddFoodDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add New Food Item"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "Item Name"),
              ),
              const SizedBox(height: 12),
              // UPDATED HINT TO RS.
              TextField(
                controller: priceCtrl,
                decoration: const InputDecoration(labelText: "Price (Rs.)"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final newItem = MenuItem(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameCtrl.text,
                description: descCtrl.text,
                price: double.tryParse(priceCtrl.text) ?? 0.0,
                imageUrl: 'https://via.placeholder.com/150',
              );
              ref.read(menuProvider.notifier).addMenuItem(newItem);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text("Add", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
