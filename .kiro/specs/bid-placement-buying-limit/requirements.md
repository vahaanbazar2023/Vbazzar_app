# Requirements Document

# Requirements: Bid Placement Flow with Buying Limit Subscription (SUBT002)

## Introduction

When a user places a bid on a vehicle in an auction, the system must validate their Available Buying Limit before allowing the bid to proceed. If the user's limit is insufficient, they are redirected to purchase the SUBT002 (Auction Bid Limit) subscription plan. After a successful purchase, the system refreshes the user's limit, retrieves the pending bid, and either places it automatically or prompts the user to upgrade again — all without allowing duplicate bids or leaving stale subscription screens on the navigation stack.

---

## Requirements

### Requirement 1: Pre-Bid Buying Limit Validation

**User Story:** As an auction participant, I want the app to check my available buying limit before my bid is submitted, so that I am aware of my limit and not allowed to place a bid I cannot cover.

#### Acceptance Criteria

1. GIVEN a user has entered a bid amount and tapped "Place Bid" WHEN the bid amount is ≥ the vehicle minimum price THEN the system checks the user's Available Buying Limit (`availableBalance` on `VehicleListing`) before calling the bid API.

2. GIVEN the user's Available Buying Limit is greater than zero AND the bid amount ≤ Available Buying Limit THEN the system proceeds directly to bid submission without showing any subscription prompt.

3. GIVEN the user's Available Buying Limit is zero OR the bid amount > Available Buying Limit THEN the system does NOT submit the bid and instead redirects the user to the Buying Limit Subscription Screen (SUBT002).

4. GIVEN the user has no active SUBT002 subscription at all THEN the system redirects the user to the Buying Limit Subscription Screen with the message "Subscribe to a bid limit plan to place bids in auctions."

5. GIVEN the bid amount validation fails (cases 3 or 4 above) THEN the bid bottom sheet is dismissed before navigating to the Subscription Screen so that no duplicate submission is possible from the still-open sheet.

---

### Requirement 2: Pending Bid Preservation

**User Story:** As an auction participant, I want my original bid amount and vehicle to be remembered when I am redirected to purchase a subscription, so that I do not have to re-enter them after upgrading.

#### Acceptance Criteria

1. GIVEN the system redirects the user to the Subscription Screen due to an insufficient buying limit THEN the system stores the pending vehicle ID and the original bid amount in memory before navigation.

2. GIVEN the pending bid is stored THEN the stored vehicle ID and bid amount are not modified by subsequent navigation events (e.g., back navigation, tab switches).

3. GIVEN the user dismisses the Subscription Screen without purchasing THEN the pending bid data is cleared and no automatic bid is attempted.

---

### Requirement 3: Subscription Purchase and Limit Refresh

**User Story:** As an auction participant, I want my buying limit to be updated automatically after I purchase the SUBT002 plan, so that I do not need to manually refresh before my pending bid is revalidated.

#### Acceptance Criteria

1. GIVEN the user completes a successful SUBT002 subscription payment on the Subscription Confirm screen THEN `SubscriptionGuardService.invalidateAndReload()` is called immediately after the payment success callback.

2. GIVEN `invalidateAndReload()` is called THEN the system fetches the latest user profile / subscription data from the API, replacing the cached subscription list.

3. GIVEN the refresh is complete THEN the updated `planAvailableBidAmount` value from the newly activated `UserSubscription` (type code `SUBT002`) is used as the new Available Buying Limit for all subsequent checks in the same session.

4. GIVEN the refresh API call fails THEN the system does not proceed with bid revalidation and shows an appropriate error message instead of silently using stale data.

---

### Requirement 4: Post-Subscription Bid Revalidation — Case A (Bid Valid)

**User Story:** As an auction participant who has just purchased a SUBT002 subscription, I want my pending bid to be placed automatically when my new limit is sufficient, so that the purchase-to-bid experience is seamless.

#### Acceptance Criteria

1. GIVEN a successful subscription refresh AND the stored pending bid amount ≤ the updated Available Buying Limit THEN the system automatically submits the pending bid without requiring the user to re-open the bid sheet.

2. GIVEN the bid is submitted automatically and succeeds THEN the Subscription Screen is removed from the navigation stack (via `Get.until(...)` matching `AppRoutes.subscription` and `AppRoutes.subscriptionConfirm`).

3. GIVEN the automatic bid succeeds THEN the app navigates the user back to the Vehicle Cards / Listings screen.

4. GIVEN the automatic bid succeeds THEN a `CustomSnackbar` with `SnackbarType.success` and the message "Bid placed successfully!" is shown to the user.

5. GIVEN the automatic bid API call fails THEN the error message from the API (or a generic fallback) is shown using `CustomSnackbar` with `SnackbarType.error`, and the user is NOT navigated away from their current screen.

---

### Requirement 5: Post-Subscription Bid Revalidation — Case B (Bid Still Exceeds Limit)

**User Story:** As an auction participant, I want to be clearly informed when my new buying limit is still insufficient for my pending bid, so that I can decide whether to upgrade further or change my bid.

#### Acceptance Criteria

1. GIVEN a successful subscription refresh AND the stored pending bid amount > the updated Available Buying Limit THEN the system does NOT submit the bid.

2. GIVEN the bid is still invalid after refresh THEN a `CustomSnackbar` with `SnackbarType.error` and the message "Your bid amount exceeds your available buying limit. Please upgrade your buying limit to continue." is displayed.

3. GIVEN the snackbar is displayed THEN the user remains on (or is returned to) the Subscription Screen so they can choose a higher-tier SUBT002 plan.

4. GIVEN the user is shown the Subscription Screen again THEN the available SUBT002 plans are displayed in ascending order of buying limit so the user can select an appropriate tier.

---

### Requirement 6: Duplicate Bid Prevention

**User Story:** As a system operator, I want to ensure that the same pending bid is never submitted more than once, so that auction integrity is maintained.

#### Acceptance Criteria

1. GIVEN a pending bid is stored and automatic submission is triggered THEN the pending bid data is cleared immediately before the bid API call is made, preventing a second automatic trigger.

2. GIVEN `isPlacingBid` is `true` on `VehicleListingController` THEN any further call to `placeBid` for the same controller instance is a no-op until the in-flight request completes.

3. GIVEN a successful auto-submission navigates the user away from the subscription flow THEN subsequent re-entry to the Subscription Screen does not carry over the previously cleared pending bid.

---

### Requirement 7: Navigation Stack Management

**User Story:** As an auction participant, I want the subscription screens to be cleanly removed from the back-stack after a successful bid, so that pressing Back takes me directly to the vehicle listing rather than back into the subscription flow.

#### Acceptance Criteria

1. GIVEN a bid is placed successfully after SUBT002 subscription THEN all routes matching `AppRoutes.subscription`, `AppRoutes.subscriptionConfirm`, and `AppRoutes.walletPayment` are removed from the navigation stack before navigating to the vehicle listing.

2. GIVEN the user completes payment but the subsequent bid revalidation results in Case B (limit still insufficient) THEN the Subscription Confirm route is popped but the Subscription Screen route remains on the stack so the user can select a new plan.

3. GIVEN the user presses Back on the Subscription Screen during the buying-limit flow THEN any stored pending bid data is discarded and the user is returned to the Vehicle Detail screen.

---

### Requirement 8: Error Feedback — Consistent Snackbar Usage

**User Story:** As an auction participant, I want all buying-limit-related errors to be surfaced through the same visual component, so that error messages are consistent and easy to recognise.

#### Acceptance Criteria

1. GIVEN any buying-limit validation error occurs (insufficient limit, bid exceeds limit after subscription, API failure during refresh) THEN the `CustomSnackbar.show(...)` method from `lib/core/design_system/molecules/custom_snackbar.dart` is used — no raw `Get.snackbar(...)` calls are made for these cases.

2. GIVEN a limit-related error is shown THEN `SnackbarType.error` is used so the snackbar uses the warning/amber colour palette defined in `_getSnackbarConfig`.

3. GIVEN a successful bid placement is shown THEN `SnackbarType.success` is used.

4. GIVEN a snackbar is already visible THEN the new snackbar replaces it (default GetX behavior — no stacking required).

---

## Glossary

| Term | Definition |
|---|---|
| **Available Buying Limit** | The monetary ceiling up to which a user may place bids in auctions, derived from their active SUBT002 subscription (`planAvailableBidAmount` on `UserSubscription`). |
| **SUBT002** | The Auction Bid Limit subscription type code (`SubscriptionTypeCode.auctionBidLimit`). Purchasing a SUBT002 plan grants or increases the user's Available Buying Limit. |
| **Pending Bid** | The vehicle ID and bid amount the user originally attempted to place before being redirected to the Subscription Screen. |
| **Bid Revalidation** | The process of comparing the stored pending bid amount against the refreshed Available Buying Limit after a successful SUBT002 subscription purchase. |
| **SubscriptionGuardService** | The singleton GetX service (`lib/features/subscription/services/subscription_guard_service.dart`) that caches and refreshes the user's subscription list. |
| **CustomSnackbar** | The shared feedback component (`lib/core/design_system/molecules/custom_snackbar.dart`) used for success and error notifications throughout the app. |
| **VehicleListingController** | The GetX controller (`lib/features/auction/controllers/vehicle_listing_controller.dart`) responsible for the bid placement flow including limit checks and API calls. |
| **Navigation Stack** | The in-memory route history managed by GetX (`Get.until`, `Get.back`, `Get.toNamed`). Subscription routes must be removed after a successful bid to prevent back-navigation into the payment flow. |
