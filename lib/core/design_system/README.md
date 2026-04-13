# Design System Documentation

## Overview
This is a comprehensive Design System built using Atomic Design principles for scalability and consistency.

## Architecture

### Tokens
Design tokens are the smallest pieces of the design system - the fundamental values.

- **app_spacing.dart**: 8-point spacing system
- **app_radius.dart**: Border radius values
- **app_sizes.dart**: Component sizing (icons, buttons, inputs, etc.)

All token values use `flutter_screenutil` for responsive design.

### Typography
**app_text_styles.dart** contains the complete typography system using local Plus Jakarta Sans fonts.

Styles include:
- Headings (XLarge, Large, Medium, Small, XSmall)
- Body text (Large, Medium, Small)
- Buttons (Large, Medium, Small)
- Labels, Captions, Overline
- Special styles (Link, Error)

### Atomic Design Layers

#### Atoms (Smallest components)
- **AppText**: Text rendering with design system styles
- **AppIcon**: Icon component with consistent sizing
- **AppDivider**: Horizontal and vertical dividers

#### Molecules (Combinations of atoms)
- **PrimaryButton**: Main CTA button with variants
- **SecondaryButton**: Outlined button style
- **AppTextButton**: Minimal text-only button
- **AppTextField**: Input field with label and validation
- **PasswordTextField**: Password field with show/hide toggle
- **AppSearchBar**: Search input with clear and filter actions

#### Organisms (Complex components)
- **LoginForm**: Complete login form with validation
- **AppCard**: Reusable card container with variants
- **InfoCard**: Card with icon and text content
- **StatCard**: Metrics display card
- **ProductTile**: Grid view product/vehicle card
- **ProductListTile**: List view product/vehicle card

#### Templates (Page layouts)
- **AuthLayout**: Authentication screens layout
- **DashboardLayout**: Main app screens layout
- **PageLayout**: Generic page with header/content
- **ListLayout**: List view with search functionality

## Usage

### Import the design system:
```dart
import 'package:vahaan_mobile_2_0/core/design_system/design_system.dart';
```

### Using Tokens:
```dart
// Spacing
padding: EdgeInsets.all(AppSpacing.md),
margin: EdgeInsets.symmetric(vertical: AppSpacing.lg),
SizedBox(height: AppSpacing.xl),

// Radius
borderRadius: AppRadius.borderRadiusMd,

// Sizes
Icon(Icons.home, size: AppSizes.iconMd),
height: AppSizes.buttonLg,
```

### Using Typography:
```dart
// With AppText component (recommended)
AppText.headingLarge('Welcome'),
AppText.bodyMedium('Description text'),
AppText.caption('Helper text'),

// Direct style usage
Text('Custom', style: AppTextStyles.headingMedium),
```

### Using Components:
```dart
// Button
PrimaryButton.large(
  text: 'Submit',
  onPressed: () {},
  icon: Icons.arrow_forward,
),

// Text field
AppTextField(
  label: 'Email',
  hint: 'Enter your email',
  prefixIcon: Icons.email,
  onChanged: (value) {},
),

// Search bar
AppSearchBar(
  hint: 'Search vehicles...',
  showFilter: true,
  onChanged: (query) {},
  onFilterTap: () {},
),

// Product card
ProductTile(
  imageUrl: 'https://...',
  title: 'Toyota Camry 2020',
  price: '₹25,00,000',
  location: 'Mumbai, Maharashtra',
  isFavorite: true,
  onTap: () {},
  tags: ['Featured', 'New'],
),
```

### Using Layouts:
```dart
// Auth screen
AuthLayout(
  title: 'Welcome Back',
  subtitle: 'Login to continue',
  child: LoginForm(
    onLoginPressed: () {},
  ),
  bottomWidget: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      AppText.bodyMedium('Don\'t have an account?'),
      AppTextButton(text: 'Sign Up', onPressed: () {}),
    ],
  ),
),

// Dashboard screen
DashboardLayout(
  title: 'Home',
  body: PageLayout(
    title: 'My Vehicles',
    child: ListView(...),
  ),
),
```

## Naming Conventions

- **Sizes**: xs, sm, md, lg, xl, xxl, xxxl
- **Colors**: Use `AppColors` from constants
- **Spacing**: Use 8-point system (4, 8, 16, 24, 32, 48, 64)
- **Components**: Prefix with `App` (AppText, AppIcon, etc.)

## Best Practices

1. **Always use tokens** instead of hardcoded values
2. **Use ScreenUtil** for all sizes (.w, .h, .sp, .r)
3. **Follow the atomic hierarchy** (Atoms → Molecules → Organisms → Templates)
4. **Reuse existing components** before creating new ones
5. **Keep components stateless** when possible
6. **Use factory constructors** for variants
7. **Document complex components** with code comments

## Responsive Design

All sizes are responsive using flutter_screenutil:
- `.w` for width
- `.h` for height  
- `.sp` for font size
- `.r` for radius

Initialize ScreenUtil in main.dart:
```dart
ScreenUtil.init(context, designSize: const Size(375, 812));
```

## Extensions

To add new components:
1. Determine the atomic level (atom/molecule/organism/template)
2. Create file in appropriate folder
3. Export in `design_system.dart`
4. Follow existing naming and structure conventions
5. Use design tokens throughout
6. Add factory constructors for common variants
