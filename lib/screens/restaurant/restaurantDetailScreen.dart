import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rescueeats/core/appTheme/appColors.dart';
import 'package:rescueeats/core/utils/responsive_utils.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final String restaurantId;
  final String? restaurantName;
  final String? imageUrl;
  final String? heroTag;

  const RestaurantDetailScreen({
    super.key,
    required this.restaurantId,
    this.restaurantName,
    this.imageUrl,
    this.heroTag,
  });

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // 1. Header Image (Standard Hero)
          SliverAppBar(
            expandedHeight: context.isMobile ? 200.0 : 250.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, size: 20),
                onPressed: () => context.pop(),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.search, size: 20),
                  onPressed: () {},
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: widget.heroTag ?? widget.restaurantId,
                child: Image.network(
                  widget.imageUrl ??
                      "https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=800&q=80",
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(color: Colors.grey[300]),
                ),
              ),
            ),
          ),

          // 2. Restaurant Info (Distinct Card Style)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(context.padding.medium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.restaurantName ?? "Burger King",
                    style: TextStyle(
                    fontSize: context.text.h1,
                    fontWeight:
                        FontWeight.w900, // Heavier font for distinct look
                    letterSpacing: -0.5,
                    height: 1.1,
                  ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        "Fast Food",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(
                          Icons.circle,
                          size: 4,
                          color: Colors.grey[300],
                        ),
                      ),
                      Text(
                        "Burger",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      const Text(
                        "4.5",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        " (500+)",
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Distinct Info Container
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB), // Very subtle grey
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[100]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoColumn(Icons.access_time, "20-30", "min"),
                        Container(
                          width: 1,
                          height: 30,
                          color: Colors.grey[300],
                        ),
                        _buildInfoColumn(
                          Icons.delivery_dining,
                          "Rs. 50",
                          "Delivery",
                        ),
                        Container(
                          width: 1,
                          height: 30,
                          color: Colors.grey[300],
                        ),
                        _buildInfoColumn(
                          Icons.local_offer,
                          "Rs. 100",
                          "Min Off",
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: context.spacing.section),
                Text(
                  "Menu",
                  style: TextStyle(
                    fontSize: context.text.h3,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                ],
              ),
            ),
          ),

          // 3. Menu Items (Text Only, No Images)
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: context.padding.medium),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return _buildTextOnlyMenuItem(index);
              }, childCount: 8),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),

      // 4. Floating Cart Button
      floatingActionButton: Container(
        width: context.widthPercent(90),
        constraints: BoxConstraints(
          maxWidth: 600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: FloatingActionButton.extended(
          onPressed: () {},
          backgroundColor: AppColors.primary,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          label: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "2 Items",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              SizedBox(width: 16),
              Text(
                "View Cart",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(width: 16),
              Text(
                "Rs. 1,450",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildInfoColumn(IconData icon, String top, String bottom) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          top,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Text(
          bottom,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTextOnlyMenuItem(int index) {
    // Mock Data for Display
    final names = [
      "Double Cheese Burger",
      "Spicy Chicken Wings",
      "French Fries (L)",
      "Coke Zero",
      "Veggie Delight Pizza",
      "Chicken Momo",
      "Buff Momo",
      "Chocolate Shake",
    ];
    final prices = ["450", "350", "200", "100", "550", "250", "220", "180"];
    final descs = [
      "Two flame-grilled beef patties, melted American cheese, pickles, and mustard.",
      "6 pcs wings tossed in spicy buffalo sauce.",
      "Golden crispy fries with sea salt.",
      "Chilled 500ml bottle.",
      "Mushrooms, onions, peppers, and olives.",
      "Steamed dumplings served with spicy achar.",
      "Steamed buffalo meat dumplings.",
      "Thick chocolate milkshake with whipped cream.",
    ];

    final safeIndex = index % names.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text Content Area
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  names[safeIndex],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  descs[safeIndex],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Rs. ${prices[safeIndex]}",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Minimal Add Button
          Center(
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "ADD",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
