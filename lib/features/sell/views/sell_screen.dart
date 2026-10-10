import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';

/// Sell screen - post a vehicle listing
class SellScreen extends StatelessWidget {
  const SellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          context.l10n.coreSellYourVehicle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.ctaGradientStart,
                      AppColors.ctaGradientEnd,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add, size: 40, color: AppColors.white),
              ),
              const SizedBox(height: 24),
              Text(
                context.l10n.coreSellYourVehicle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.coreListYourVehicleForSale,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.grey500),
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.coreComingSoon,
                style: TextStyle(
                  color: AppColors.grey400,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
