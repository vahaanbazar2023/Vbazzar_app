import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../routes/app_routes.dart';
import '../controllers/auction_controller.dart';

class AuctionTypeScreen extends StatelessWidget {
  const AuctionTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: context.l10n.auctionZone,
      subtitle: context.l10n.chooseAnyOne,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        children: [
          SizedBox(height: AppSpacing.md),
          _TypeCard(
            tabIndex: 0,
            image: Image.asset('assets/images/png/live_bidding.png'),
            title: AuctionType.label(AuctionType.live),
            subtitle: context.l10n.liveAuctionSubtitle,
            badgeColor: const Color(0xFFD41F1F),
            badgeLabel: context.l10n.liveBadge,
          ),

          _TypeCard(
            tabIndex: 1,
            image: Image.asset('assets/images/png/goverment_inventory.png'),
            title: AuctionType.label('Approved Vehicles'),
            subtitle: context.l10n.liveAuctionSubtitle,
            badgeColor: const Color(0xFFD41F1F),
            badgeLabel: context.l10n.liveBadge,
          ),
        ],
      ),
    );
  }
}

class _TypeCard extends StatelessWidget {
  final int tabIndex;
  final Image image;
  final String title;
  final String subtitle;
  final Color badgeColor;
  final String badgeLabel;

  const _TypeCard({
    required this.tabIndex,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.badgeColor,
    required this.badgeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (tabIndex == 1) {
          // Navigate to Approved Vehicles module
          Get.toNamed(AppRoutes.approvedVehicleCategory);
        } else {
          // Navigate to Auction category screen first
          Get.toNamed(AppRoutes.auctionCategory);
        }
      },
      child: Container(
        height: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Color(0xFF1A1A1A),
                  height: 1.2,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.md),
            Image(image: image.image, width: 350, height: 200),

            SizedBox(height: AppSpacing.sm),
            Text(
              subtitle,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w400,
                fontSize: 13,
                color: Color(0xFF6B6B6B),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
