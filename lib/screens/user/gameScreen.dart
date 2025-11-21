import 'package:flutter/material.dart';
import 'package:rescueeats/core/appTheme/appColors.dart';
import 'package:rescueeats/core/utils/responsive_utils.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Play & Win",
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
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.games_outlined,
              size: context.sizes.iconExtraLarge,
              color: AppColors.primary.withOpacity(0.5),
            ),
            SizedBox(height: context.spacing.medium),
            Text(
              "Coming Soon!",
              style: TextStyle(
                fontSize: context.text.h2,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: context.spacing.small),
            Text(
              "Play games to earn rewards.",
              style: TextStyle(
                fontSize: context.text.bodyMedium,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
