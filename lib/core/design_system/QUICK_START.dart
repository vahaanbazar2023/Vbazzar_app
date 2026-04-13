// ══════════════════════════════════════════════════════════════
// QUICK START GUIDE - Design System Integration
// ══════════════════════════════════════════════════════════════

/*

STEP 1: Initialize ScreenUtil in main.dart
------------------------------------------

Add this to your main app widget's build method:

```dart
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),  // iPhone X size (adjust if needed)
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Vahaan Bazar',
          theme: ThemeData(
            scaffoldBackgroundColor: AppColors.background,
            fontFamily: 'PlusJakartaSans',
          ),
          initialRoute: AppPages.INITIAL,
          getPages: AppPages.routes,
        );
      },
    );
  }
}
```

STEP 2: Import Design System
------------------------------

In any screen/widget file:

```dart
import 'package:vahaan_mobile_2_0/core/design_system/design_system.dart';
import 'package:vahaan_mobile_2_0/core/constants/app_colors.dart';
```

STEP 3: Use Components
-----------------------

// Typography
AppText.headingLarge('Welcome'),

// Buttons
PrimaryButton.large(
  text: 'Get Started',
  onPressed: () => Get.toNamed('/home'),
),

// Text Fields
AppTextField(
  label: 'Email',
  hint: 'Enter your email',
  prefixIcon: Icons.email,
  controller: emailController,
),

// Layouts
DashboardLayout(
  title: 'Dashboard',
  body: PageLayout(
    title: 'My Content',
    child: YourContent(),
  ),
),

STEP 4: Spacing & Sizing
--------------------------

// Use tokens for consistent spacing
padding: EdgeInsets.all(AppSpacing.md),
SizedBox(height: AppSpacing.lg),
borderRadius: AppRadius.borderRadiusMd,
Icon(Icons.star, size: AppSizes.iconMd),

COMPLETE EXAMPLE
----------------

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vahaan_mobile_2_0/core/design_system/design_system.dart';
import 'package:vahaan_mobile_2_0/core/constants/app_colors.dart';

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      title: 'My Screen',
      body: PageLayout(
        title: 'Welcome',
        subtitle: 'Start using the design system',
        child: Column(
          children: [
            // Card with content
            AppCard(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  AppText.headingMedium('Hello World'),
                  SizedBox(height: AppSpacing.md),
                  AppText.bodyMedium('This uses the design system'),
                ],
              ),
            ),
            
            SizedBox(height: AppSpacing.lg),
            
            // Button
            PrimaryButton.large(
              text: 'Continue',
              icon: Icons.arrow_forward,
              onPressed: () => Get.toNamed('/next'),
            ),
          ],
        ),
      ),
    );
  }
}
```

TIPS
----

1. Always use AppSpacing for spacing (never hardcode numbers)
2. Use AppSizes for component sizes
3. Use AppRadius for border radius
4. Use AppTextStyles or AppText components for typography
5. Leverage factory constructors (.large, .small, etc.)
6. Use the barrel export: import '.../design_system.dart'

TROUBLESHOOTING
---------------

Q: Sizes look wrong?
A: Make sure ScreenUtil is initialized in main.dart

Q: Fonts not loading?
A: Check pubspec.yaml has the font declarations

Q: Import errors?
A: Use the barrel export: 'package:vahaan_mobile_2_0/core/design_system/design_system.dart'

For full documentation, see:
- lib/core/design_system/README.md
- lib/core/design_system/examples/design_system_example.dart

*/
