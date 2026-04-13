import 'package:flutter/material.dart';
import 'package:vahaan_mobile_2_0/core/design_system/design_system.dart';
import 'package:vahaan_mobile_2_0/core/constants/app_colors.dart';

/// Example demonstrating Design System usage
/// This file shows how to use all design system components
class DesignSystemExample extends StatelessWidget {
  const DesignSystemExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DashboardLayout(
        title: 'Design System Demo',
        body: PageLayout(
          title: 'Components Showcase',
          subtitle: 'Examples of all design system components',
          scrollable: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Typography Examples ────────────────────────────
              _buildSection(
                'Typography',
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.headingXLarge('Heading XL'),
                    SizedBox(height: AppSpacing.sm),
                    AppText.headingLarge('Heading Large'),
                    SizedBox(height: AppSpacing.sm),
                    AppText.headingMedium('Heading Medium'),
                    SizedBox(height: AppSpacing.sm),
                    AppText.bodyLarge('Body Large Text'),
                    SizedBox(height: AppSpacing.sm),
                    AppText.bodyMedium('Body Medium Text'),
                    SizedBox(height: AppSpacing.sm),
                    AppText.caption('Caption text for helper info'),
                  ],
                ),
              ),

              // ── Buttons Examples ───────────────────────────────
              _buildSection(
                'Buttons',
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PrimaryButton.large(
                      text: 'Primary Large',
                      onPressed: () {},
                      icon: Icons.arrow_forward,
                    ),
                    SizedBox(height: AppSpacing.md),
                    PrimaryButton.medium(
                      text: 'Primary Medium',
                      onPressed: () {},
                    ),
                    SizedBox(height: AppSpacing.md),
                    SecondaryButton(
                      text: 'Secondary Button',
                      onPressed: () {},
                      icon: Icons.edit,
                    ),
                    SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppTextButton(text: 'Text Button', onPressed: () {}),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Text Fields Examples ───────────────────────────
              _buildSection(
                'Text Fields',
                Column(
                  children: [
                    AppTextField(
                      label: 'Email',
                      hint: 'Enter your email',
                      prefixIcon: Icons.email_outlined,
                    ),
                    SizedBox(height: AppSpacing.md),
                    PasswordTextField(
                      label: 'Password',
                      hint: 'Enter password',
                    ),
                    SizedBox(height: AppSpacing.md),
                    AppSearchBar(
                      hint: 'Search vehicles...',
                      showFilter: true,
                      onFilterTap: () {},
                    ),
                  ],
                ),
              ),

              // ── Cards Examples ─────────────────────────────────
              _buildSection(
                'Cards',
                Column(
                  children: [
                    AppCard.elevated(
                      child: Column(
                        children: [
                          AppText.headingSmall('Elevated Card'),
                          SizedBox(height: AppSpacing.sm),
                          AppText.bodyMedium(
                            'This is an elevated card with shadow',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    InfoCard(
                      icon: Icons.notifications,
                      title: 'Notifications',
                      subtitle: '5 new messages',
                      onTap: () {},
                    ),
                    SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            label: 'Total Sales',
                            value: '₹2.5M',
                            icon: Icons.trending_up,
                            trend: '+12%',
                            isTrendPositive: true,
                          ),
                        ),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: StatCard(
                            label: 'Active Listings',
                            value: '42',
                            icon: Icons.list_alt,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Product Tiles Examples ─────────────────────────
              _buildSection(
                'Product Tiles',
                Column(
                  children: [
                    ProductTile(
                      imageUrl: 'https://via.placeholder.com/400x300',
                      title: 'Toyota Camry 2020',
                      subtitle: 'Sedan • Automatic • Petrol',
                      price: '₹25,00,000',
                      location: 'Mumbai, Maharashtra',
                      isFavorite: true,
                      tags: ['Featured', 'Verified'],
                      onTap: () {},
                      onFavoriteTap: () {},
                    ),
                    SizedBox(height: AppSpacing.md),
                    ProductListTile(
                      imageUrl: 'https://via.placeholder.com/200x200',
                      title: 'Honda City 2019',
                      subtitle: 'Sedan • Manual',
                      price: '₹12,50,000',
                      location: 'Delhi, India',
                      isFavorite: false,
                      onTap: () {},
                      onFavoriteTap: () {},
                    ),
                  ],
                ),
              ),

              // ── Icons and Dividers ─────────────────────────────
              _buildSection(
                'Icons & Dividers',
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        AppIcon.xs(Icons.star, color: AppColors.warning),
                        AppIcon.sm(Icons.favorite, color: AppColors.error),
                        AppIcon.md(Icons.home, color: AppColors.primary),
                        AppIcon.lg(Icons.settings, color: AppColors.grey500),
                        AppIcon.xl(Icons.notifications, color: AppColors.info),
                      ],
                    ),
                    SizedBox(height: AppSpacing.lg),
                    AppDivider.thin(),
                    SizedBox(height: AppSpacing.md),
                    AppDivider.bold(),
                    SizedBox(height: AppSpacing.md),
                    AppDivider.primary(),
                  ],
                ),
              ),

              SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.headingMedium(title),
        SizedBox(height: AppSpacing.md),
        child,
        SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

/// Example of Auth Screen using Design System
class LoginScreenExample extends StatelessWidget {
  const LoginScreenExample({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Welcome Back',
      subtitle: 'Sign in to continue',
      child: LoginForm(
        onLoginPressed: () {
          // Handle login
        },
        onForgotPasswordPressed: () {
          // Handle forgot password
        },
      ),
      bottomWidget: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppText.bodyMedium('Don\'t have an account?'),
          SizedBox(width: AppSpacing.xs),
          AppTextButton(text: 'Sign Up', onPressed: () {}),
        ],
      ),
    );
  }
}

/// Example of List Screen using Design System
class VehicleListScreenExample extends StatelessWidget {
  const VehicleListScreenExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ListLayout(
      title: 'Vehicles',
      searchBar: AppSearchBar(
        hint: 'Search vehicles...',
        showFilter: true,
        onFilterTap: () {},
      ),
      listView: ListView.separated(
        padding: EdgeInsets.all(AppSpacing.md),
        itemCount: 10,
        separatorBuilder: (_, __) => SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          return ProductListTile(
            imageUrl: 'https://via.placeholder.com/200x200',
            title: 'Vehicle ${index + 1}',
            subtitle: 'Description',
            price: '₹${(index + 1) * 100000}',
            location: 'Mumbai, India',
            isFavorite: index % 3 == 0,
            onTap: () {},
            onFavoriteTap: () {},
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
