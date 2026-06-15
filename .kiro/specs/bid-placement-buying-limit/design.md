# Technical Design Document
# Bid Placement Flow with Buying Limit Subscription (SUBT002)

---

## 1. Architecture Overview

### 1.1 Existing Classes — What Changes

| Class | File | Change |
|---|---|---|
| `VehicleListingController` | `lib/features/auction/controllers/vehicle_listing_controller.dart` | Add `pendingBid` storage fields; add `revalidatePendingBid()` method; add guard in `placeBid` to prevent re-entry while `isPlacingBid` is true |
| `SubscriptionConfirmController` | `lib/features/subscription/controllers/subscription_confirm_controller.dart` | Add `SUBT002` case to `_handlePostPaymentNavigation`; replace raw `Get.snackbar` calls with `CustomSnackbar.show`; call `VehicleListingController.revalidatePendingBid()` after cache refresh |
| `SubscriptionGuardService` | `lib/features/subscription/services/subscription_guard_service.dart` | No changes needed — `invalidateAndReload()` already exists and works correctly |
| `UserSubscription` / `MySubscriptionsData` | `lib/features/subscription/models/user_subscription.dart` | No changes needed — `planAvailableBidAmount` already exists |

### 1.2 New Classes / Files Added

| Class | File | Purpose |
|---|---|---|
| `PendingBid` | `lib/features/auction/models/pending_bid.dart` | Immutable value object holding `vehicleId` + `bidAmount` to be preserved across navigation |

### 1.3 Unchanged Classes (read-only during this feature)

- `VehicleListing` — `availableBalance` field already present
- `AuctionRepository` / `AuctionRepositoryImpl` — `placeBid` API call already exists
- `CustomSnackbar` — `show()` method already matches requirements
- `AppRoutes` — all required route constants already exist
- `_BidSheet` (in `acution_vechile_detail.dart`) — no change required; existing `__navigated__` sentinel handling is sufficient

---

## 2. New Model: `PendingBid`

```dart
// lib/features/auction/models/pending_bid.dart

/// Immutable value object that survives navigation to the Subscription screen.
/// Stored in-memory on [VehicleListingController].
/// Cleared immediately before any auto-submission attempt (Req 6.1).
class PendingBid {
  final String vehicleId;
  final int bidAmount;

  const PendingBid({
    required this.vehicleId,
    required this.bidAmount,
  });
}
```

---

## 3. State Management — New Observable Fields on `VehicleListingController`

```dart
// Added to VehicleListingController

/// Holds the bid the user attempted before being redirected to SUBT002.
/// Null means no pending bid exists.
/// Must be cleared before any auto-submission (Req 6.1).
final pendingBid = Rxn<PendingBid>();
```

The field is `Rxn<PendingBid>` (nullable reactive) so that:
- UI layers can `Obx`-watch it if needed in the future.
- Null clearly signals "no pending work", avoiding sentinel values.
- Clearing is a single `pendingBid.value = null` assignment.

No additional observable fields are required beyond the existing `isPlacingBid`.

---

## 4. Pending Bid Storage — How `vehicleId` + `bidAmount` Are Preserved

### 4.1 Storage Location

`pendingBid` lives on `VehicleListingController`, which is registered as a `GetX` service for the lifetime of the vehicle-listings session. Because GetX keeps the controller alive until the binding is disposed (i.e., the user leaves the `vehicleListings` route stack entirely), the value survives:

- Navigation to `AppRoutes.subscription`
- Navigation to `AppRoutes.subscriptionConfirm`
- Navigation to `AppRoutes.walletPayment`
- Back navigation through those screens

### 4.2 Write — When the pending bid is stored

Inside `placeBid()`, immediately before calling `Get.toNamed(AppRoutes.subscription, ...)` for either the "no plan" or "limit exceeded" paths:

```dart
pendingBid.value = PendingBid(
  vehicleId: vehicle.vehicleId,
  bidAmount: bidAmount,
);
```

### 4.3 Read — Where it is consumed

`SubscriptionConfirmController._handlePostPaymentNavigation()` (SUBT002 case) calls `revalidatePendingBid()` on the live `VehicleListingController` instance.

### 4.4 Clear — When the pending bid is discarded

| Trigger | Action |
|---|---|
| Auto-submission succeeds (Case A) | Cleared **before** the API call |
| Auto-submission fails (Case A, API error) | Already cleared before attempt; no re-clear needed |
| Still-exceeds-limit (Case B) | Cleared **after** showing the snackbar (user may re-subscribe) |
| User presses Back on Subscription Screen | `WillPopScope` / `GetX` back-press handler in `SubscriptionScreen` clears it |
| User dismisses SubscriptionConfirm without paying | `onCancelled` callback clears it |

---

## 5. Data Flow Diagram

```
User taps "Place Bid" (BidSheet._submit)
        │
        ▼
VehicleListingController.placeBid(vehicle, bidAmount)
        │
        ├─ [bidAmount < minimumPrice] ──────────────────► return error string (shown in sheet)
        │
        ├─ [bidAmount ≤ currentHighestBid] ─────────────► return error string (shown in sheet)
        │
        ├─ await SubscriptionGuardService.ensureLoaded()
        │
        ├─ [!hasBidLimit (no SUBT002)] ─────────────────► store PendingBid
        │                                                  Get.back() (close sheet)
        │                                                  Get.toNamed(subscription, SUBT002 args)
        │                                                  return '__navigated__'
        │
        ├─ [availableBalance == 0 OR bidAmount > balance] ► store PendingBid
        │                                                   Get.back() (close sheet)
        │                                                   Get.toNamed(subscription, SUBT002 args)
        │                                                   return '__navigated__'
        │
        └─ [all checks pass]
                │
                ▼
        _repository.placeBid(userId, vehicleId, auctionId, bidAmount)
                │
                ├─ [success] ──► _load() (refresh list) ──► return null
                └─ [error]  ──► return error message


── On Subscription Screen ──────────────────────────────────────────────────

User selects a SUBT002 plan ──► Get.toNamed(subscriptionConfirm, plan, source='SUBT002')

── On SubscriptionConfirm Screen ───────────────────────────────────────────

User taps "Proceed to Pay"
        │
        ▼
PaymentController.initiatePayment(userId, planCode)
        │
        ├─ [failure/cancel] ──► show snackbar, stay on screen
        │
        └─ [success]
                │
                ▼
        SubscriptionGuardService.invalidateAndReload()
                │
                ▼
        SubscriptionConfirmController._handlePostPaymentNavigation('SUBT002')
                │
                ▼
        VehicleListingController.revalidatePendingBid()
                │
                ├─ [pendingBid == null] ──► Get.until (pop sub screens) ──► stay on vehicle listings
                │
                ├─ [bidAmount ≤ refreshed availableBalance]  ── CASE A ──────────────────────────┐
                │        pendingBid.value = null (clear before call)                             │
                │        await _repository.placeBid(...)                                         │
                │        ├─ [API success]                                                        │
                │        │       Get.until (pop subscription + confirm + walletPayment)          │
                │        │       CustomSnackbar.show(success, 'Bid placed successfully!')       │
                │        │       _load() (refresh vehicle list)                                  │
                │        └─ [API error]                                                          │
                │                CustomSnackbar.show(error, errorMessage)                       │
                │                stay on current screen                                          │
                │                                                                                │
                └─ [bidAmount > refreshed availableBalance]  ── CASE B ──────────────────────────┘
                         CustomSnackbar.show(error, 'Your bid amount exceeds...')
                         pendingBid.value = null (clear after snackbar)
                         Get.back() (pop subscriptionConfirm, stay on subscription screen)
```

---

## 6. Sequence of Operations

### 6.1 Case A — New Limit Covers the Pending Bid

```
BidSheet           VehicleListingCtrl    SubscriptionConfirmCtrl    SubGuardService    AuctionRepository
   │                      │                        │                      │                    │
   │── _submit() ────────►│                        │                      │                    │
   │                      │── ensureLoaded() ─────────────────────────►  │                    │
   │                      │◄────────────────────────────────────────────  │                    │
   │                      │                        │                      │                    │
   │   [limit exceeded]   │                        │                      │                    │
   │                      │── pendingBid = PendingBid(vehicleId, amount)  │                    │
   │                      │── Get.back() (close sheet)                    │                    │
   │                      │── Get.toNamed(AppRoutes.subscription, ...)    │                    │
   │◄── '__navigated__' ──│                        │                      │                    │
   │                                               │                      │                    │
   │   [User picks SUBT002 plan, taps Confirm]     │                      │                    │
   │                                               │── initiatePayment() ►│                    │
   │                                               │   [PayU gateway]     │                    │
   │                                               │◄─ onSuccess ─────────│                    │
   │                                               │                      │                    │
   │                                               │── invalidateAndReload() ─────────────────►│
   │                                               │◄─────────────────────────────────────────-│
   │                                               │                      │                    │
   │                   [source == 'SUBT002']       │                      │                    │
   │                                               │── revalidatePendingBid()                  │
   │                                               │         │            │                    │
   │                                               │   fetch refreshed availableBalance         │
   │                                               │   from SubscriptionGuardService            │
   │                                               │         │            │                    │
   │                                               │   [bidAmount ≤ newBalance]                │
   │                                               │   pendingBid = null (clear)               │
   │                                               │── placeBid API call ────────────────────►│
   │                                               │◄── success ─────────────────────────────│
   │                                               │                      │                    │
   │                                               │── Get.until(pop sub routes)               │
   │                                               │── CustomSnackbar.success(...)             │
   │                                               │── _load() (refresh vehicle list)          │
```

### 6.2 Case B — New Limit Still Insufficient

```
   [After invalidateAndReload() — same as Case A up to revalidatePendingBid()]

   VehicleListingCtrl
          │
          │   [bidAmount > newAvailableBalance]
          │── CustomSnackbar.error('Your bid amount exceeds your available buying limit...')
          │── pendingBid = null (clear)
          │── Get.back()   ← pops subscriptionConfirm, returns to subscription screen
          │
   [User sees Subscription Screen with SUBT002 plans in ascending order]
   [User may select a higher tier and repeat the payment flow]
```

---

## 7. Navigation Stack Changes

### 7.1 Stack State Before Bid Attempt

```
Stack (bottom → top):
  /home
  /auction
  /auction/category
  /auction/vehicle-listings       ← VehicleListingController lives here
  /auction/vehicle-detail
  [modal: BidSheet]
```

### 7.2 After Redirect to Subscription (insufficient limit)

```
  /home
  /auction
  /auction/category
  /auction/vehicle-listings
  /auction/vehicle-detail          ← sheet is closed via Get.back()
  /subscription                    ← pushed by VehicleListingController.placeBid()
```

### 7.3 After User Selects Plan → Confirm Screen

```
  /home
  /auction
  /auction/category
  /auction/vehicle-listings
  /auction/vehicle-detail
  /subscription
  /subscription/confirm            ← pushed by SubscriptionScreen on plan tap
  [optionally: /subscription/wallet-payment]
```

### 7.4 Case A — After Successful Bid (via `Get.until`)

```dart
// In SubscriptionConfirmController._handlePostPaymentNavigation (SUBT002 case)
// After revalidatePendingBid() confirms bid success:

Get.until(
  (route) =>
      route.settings.name != AppRoutes.subscription &&
      route.settings.name != AppRoutes.subscriptionConfirm &&
      route.settings.name != AppRoutes.walletPayment,
);
// Stack becomes:
//   /home
//   /auction
//   /auction/category
//   /auction/vehicle-listings    ← top of stack, user lands here
//   /auction/vehicle-detail      ← remains if detail is below subscription
```

> **Note on `Get.until` semantics**: `Get.until` pops routes from the top until the predicate returns `true` (i.e., a route it should *keep*). The predicate must return `true` for routes to keep and `false` for routes to pop — which is the inverse of what the condition reads. The existing SUBT001 pattern in `SubscriptionConfirmController` uses this correctly; the SUBT002 case uses the same pattern.

### 7.5 Case B — After Limit Still Insufficient

```dart
Get.back(); // Pops /subscription/confirm (or /subscription/wallet-payment first)
// Stack becomes:
//   /home
//   /auction
//   /auction/category
//   /auction/vehicle-listings
//   /auction/vehicle-detail
//   /subscription               ← user lands here to pick a higher-tier plan
```

### 7.6 User Presses Back on Subscription Screen (without purchasing)

The `SubscriptionScreen` must register a back-press handler (via `WillPopScope` or `onWillPop` equivalent) that calls `VehicleListingController.pendingBid.value = null` before allowing the pop. Alternatively, `VehicleListingController` can implement `onSubscriptionScreenPopped()` which `SubscriptionScreen` calls on dispose.

---

## 8. API Calls Involved

| Step | Caller | Endpoint / Method | Purpose |
|---|---|---|---|
| Load subscription cache | `SubscriptionGuardService.ensureLoaded()` | `GET /subscriptions/my` (via `SubscriptionService.fetchMySubscriptions`) | Retrieve current SUBT002 subscription + `planAvailableBidAmount` |
| Refresh after payment | `SubscriptionGuardService.invalidateAndReload()` | Same as above (force refresh) | Get updated `planAvailableBidAmount` from new SUBT002 plan |
| Place bid | `AuctionRepository.placeBid(userId, vehicleId, auctionId, bidAmount)` | `POST /auctions/{auctionId}/bids` (existing) | Submit the pending bid after limit revalidation |
| Initiate payment | `PaymentController.initiatePayment(userId, planCode)` | PayU gateway (existing) | Purchase the SUBT002 plan |

> **Refreshed `availableBalance`**: After `invalidateAndReload()` completes, the refreshed Available Buying Limit is obtained from `SubscriptionGuardService.bestSubscription(SubscriptionTypeCode.auctionBidLimit)?.planAvailableBidAmount`. It is **not** taken from `VehicleListing.availableBalance` (which is stale from the earlier vehicle-listings API call). The revalidation compares `pendingBid.bidAmount` against this freshly-fetched value.

---

## 9. Detailed Method Signatures

### 9.1 `VehicleListingController` additions

```dart
// ── Pending bid storage ───────────────────────────────────────────────────
final pendingBid = Rxn<PendingBid>();

/// Called by SubscriptionConfirmController after a successful SUBT002
/// payment and guard cache refresh.
///
/// Reads the updated Available Buying Limit from [SubscriptionGuardService],
/// then either auto-submits the pending bid (Case A) or shows an error
/// and clears the pending bid (Case B).
///
/// Must NOT be called while [isPlacingBid] is true (re-entry guard).
Future<void> revalidatePendingBid() async {
  final bid = pendingBid.value;
  if (bid == null) return;                         // nothing to do
  if (isPlacingBid.value) return;                  // Req 6.2: re-entry guard

  // Get refreshed limit from guard cache (already refreshed by caller)
  final guard = SubscriptionGuardService.to;
  final sub = guard.bestSubscription(SubscriptionTypeCode.auctionBidLimit);
  final newLimit = (sub?.planAvailableBidAmount ?? 0).toInt();

  if (bid.bidAmount <= newLimit) {
    // ── Case A: Limit now sufficient ──────────────────────────────────────
    pendingBid.value = null;          // clear BEFORE API call (Req 6.1)
    isPlacingBid.value = true;
    try {
      final uid = await SecureStorageService.to.read(StorageKeys.userId) ?? '';
      // Find the current VehicleListing for the stored vehicleId
      final vehicle = vehicles.firstWhereOrNull((v) => v.vehicleId == bid.vehicleId);
      if (vehicle == null) {
        CustomSnackbar.show(
          message: 'Vehicle not found. Please refresh and try again.',
          type: SnackbarType.error,
        );
        return;
      }
      await _repository.placeBid(
        userId: uid,
        vehicleId: vehicle.vehicleId,
        auctionId: vehicle.auctionId,
        bidAmount: bid.bidAmount,
      );
      // Pop all subscription routes
      Get.until(
        (route) =>
            route.settings.name != AppRoutes.subscription &&
            route.settings.name != AppRoutes.subscriptionConfirm &&
            route.settings.name != AppRoutes.walletPayment,
      );
      CustomSnackbar.show(
        message: 'Bid placed successfully!',
        type: SnackbarType.success,
      );
      _load(); // refresh vehicle list
    } on BidException catch (e) {
      CustomSnackbar.show(
        message: e.message.isNotEmpty ? e.message : 'Bid could not be placed.',
        type: SnackbarType.error,
      );
    } catch (_) {
      CustomSnackbar.show(
        message: 'Something went wrong. Please try again.',
        type: SnackbarType.error,
      );
    } finally {
      isPlacingBid.value = false;
    }
  } else {
    // ── Case B: Still exceeds limit ───────────────────────────────────────
    CustomSnackbar.show(
      message:
          'Your bid amount exceeds your available buying limit. '
          'Please upgrade your buying limit to continue.',
      type: SnackbarType.error,
    );
    pendingBid.value = null;   // clear; user will re-enter bid amount after upgrade
    Get.back();                // pop subscriptionConfirm, stay on subscription screen
  }
}
```

### 9.2 `placeBid` modification — store pending bid before navigating

Replace the two existing `Get.toNamed(AppRoutes.subscription, ...)` calls with:

```dart
// Before navigating (both the "no plan" and "limit exceeded" branches):
pendingBid.value = PendingBid(
  vehicleId: vehicle.vehicleId,
  bidAmount: bidAmount,
);
Get.back(); // dismiss bid sheet
await Future.delayed(const Duration(milliseconds: 300));
Get.toNamed(AppRoutes.subscription, arguments: { /* existing args */ });
return '__navigated__';
```

The existing re-entry guard for `isPlacingBid` already satisfies Req 6.2 for in-flight API calls. No additional guard is needed at the top of `placeBid` — the `_BidSheet` disables the button while `_isSubmitting` is true.

### 9.3 `SubscriptionConfirmController._handlePostPaymentNavigation` — add SUBT002 case

```dart
void _handlePostPaymentNavigation(String src) {
  switch (src) {
    case SubscriptionTypeCode.auction:          // SUBT001
      Get.until(
        (route) =>
            route.settings.name != AppRoutes.subscription &&
            route.settings.name != AppRoutes.subscriptionConfirm &&
            route.settings.name != AppRoutes.walletPayment,
      );
      Get.toNamed(AppRoutes.auctionType);
      CustomSnackbar.show(             // replace raw Get.snackbar
        message: 'Auction Access Activated! You can now browse and bid on auctions.',
        type: SnackbarType.success,
      );
      break;

    case SubscriptionTypeCode.auctionBidLimit:  // SUBT002 ← NEW CASE
      // Delegate navigation and snackbar to VehicleListingController
      // because only it knows whether Case A or Case B applies.
      if (Get.isRegistered<VehicleListingController>()) {
        Get.find<VehicleListingController>().revalidatePendingBid();
      } else {
        // No controller found: just pop subscription screens
        Get.until(
          (route) =>
              route.settings.name != AppRoutes.subscription &&
              route.settings.name != AppRoutes.subscriptionConfirm &&
              route.settings.name != AppRoutes.walletPayment,
        );
        CustomSnackbar.show(
          message: 'Buying limit updated!',
          type: SnackbarType.success,
        );
      }
      break;

    default:
      Get.offAllNamed(AppRoutes.mySubscriptions);
      CustomSnackbar.show(
        message: 'Your plan is now active.',
        type: SnackbarType.success,
      );
      break;
  }
}
```

> **Why delegate to `VehicleListingController`?** Only `VehicleListingController` has the `pendingBid` state and knowledge of which vehicle was involved. Putting Case A/B logic in `SubscriptionConfirmController` would couple it to auction domain concerns. The `SubscriptionConfirmController` stays concerned with payment; the auction controller handles bid revalidation.

---

## 10. Component Interaction Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  UI Layer                                                                   │
│                                                                             │
│  ┌──────────────────────┐   tap      ┌─────────────────────────┐           │
│  │  _BidSheet           │──────────► │  VehicleListingController│           │
│  │  (StatefulWidget)    │           │  .placeBid()             │           │
│  └──────────────────────┘           └──────────┬──────────────-┘           │
│                                                │                            │
│  ┌──────────────────────┐            stores    │  navigates                 │
│  │  AuctionVehicleDetail│            PendingBid│  to subscription           │
│  │  Screen              │                      ▼                            │
│  └──────────────────────┘     ┌─────────────────────────────┐              │
│                                │  SubscriptionScreen          │              │
│  ┌──────────────────────┐     │  (plan list, SUBT002 source) │              │
│  │  AuctionVehicleListing│    └─────────────┬───────────────-┘              │
│  │  Screen              │                   │ tap plan                      │
│  │  (landing after      │                   ▼                               │
│  │   successful bid)    │     ┌─────────────────────────────┐              │
│  └──────────────────────┘     │  SubscriptionConfirmScreen  │              │
│                                │  + SubscriptionConfirm      │              │
│                                │    Controller               │              │
│                                └─────────────┬───────────────┘              │
└─────────────────────────────────────────────-│─────────────────────────────┘
                                               │ onSuccess
          ┌────────────────────────────────────▼────────────────────────────┐
          │  Service / Domain Layer                                          │
          │                                                                  │
          │  ┌──────────────────────┐     ┌──────────────────────────────┐  │
          │  │ SubscriptionConfirm  │────►│ SubscriptionGuardService     │  │
          │  │ Controller           │     │ .invalidateAndReload()        │  │
          │  │ ._handlePostPayment  │     │                              │  │
          │  │   Navigation()       │     │ fetches:                     │  │
          │  └──────────┬───────────┘     │  GET /subscriptions/my       │  │
          │             │                 └──────────────────────────────┘  │
          │             │ calls                                               │
          │             ▼                                                     │
          │  ┌──────────────────────────────────────┐                        │
          │  │ VehicleListingController              │                        │
          │  │ .revalidatePendingBid()               │                        │
          │  │                                       │                        │
          │  │  reads: SubscriptionGuardService      │                        │
          │  │         .bestSubscription(SUBT002)    │                        │
          │  │         .planAvailableBidAmount        │                        │
          │  │                                       │                        │
          │  │  [Case A] clears pendingBid            │                        │
          │  │           calls AuctionRepository      │                        │
          │  │           .placeBid()                  │                        │
          │  │           Get.until(pop sub routes)    │                        │
          │  │           CustomSnackbar.success       │                        │
          │  │                                       │                        │
          │  │  [Case B] CustomSnackbar.error         │                        │
          │  │           clears pendingBid            │                        │
          │  │           Get.back()                   │                        │
          │  └──────────────────────────────────────┘                        │
          └──────────────────────────────────────────────────────────────────┘
```

---

## 11. Subscription Screen — Back Navigation Handling

When the user presses Back on `SubscriptionScreen` while it was entered from the SUBT002 bid-limit flow, the pending bid must be discarded.

**Implementation options (choose one):**

**Option A — Controller-side (recommended):** Override `onDetached` or use `Get.back` result in `VehicleListingController`. Since `SubscriptionScreen` is navigated to (not `offNamedTo`), the `VehicleListingController` is still alive. Register a route observer that calls `pendingBid.value = null` when `AppRoutes.subscription` is popped.

**Option B — View-side:** In `SubscriptionScreen.dispose()`, check if the controller is registered and call `pendingBid.value = null`.

```dart
// SubscriptionScreen (StatefulWidget override)
@override
void dispose() {
  if (Get.isRegistered<VehicleListingController>()) {
    Get.find<VehicleListingController>().pendingBid.value = null;
  }
  super.dispose();
}
```

Option B is simpler and avoids introducing a route observer. It covers:
- User taps the system Back button
- User taps the AppBar back chevron
- Screen is disposed for any other reason

---

## 12. Edge Cases and Guards

| Scenario | Behaviour |
|---|---|
| `revalidatePendingBid()` called with `pendingBid == null` | Early-return, no-op |
| `isPlacingBid == true` when `revalidatePendingBid()` is called | Early-return (Req 6.2) |
| `SubscriptionGuardService.invalidateAndReload()` throws / API fails | `revalidatePendingBid()` is never called; `SubscriptionConfirmController` should catch the error, show `CustomSnackbar.error`, and NOT navigate (Req 3.4) |
| Vehicle no longer in the loaded `vehicles` list when auto-submitting | Show error snackbar "Vehicle not found. Please refresh and try again." — do not crash |
| Multiple subscriptions of type SUBT002 | `SubscriptionGuardService.bestSubscription()` already picks the one with the latest end date (maximum limit effectively) |
| User purchases SUBT002 from the "My Subscriptions" screen (not from bid flow) | `source` will not be `'SUBT002'` for that path; no `revalidatePendingBid()` is triggered; existing `default` case handles it |
| `VehicleListingController` was disposed before payment completes | `Get.isRegistered<VehicleListingController>()` returns `false`; `_handlePostPaymentNavigation` falls through to the fallback branch that pops subscription screens cleanly |

---

## 13. Snackbar Usage Summary

All buying-limit feedback is routed through `CustomSnackbar.show()`:

| Scenario | Type | Message |
|---|---|---|
| Bid placed successfully (Case A auto-submit) | `SnackbarType.success` | `"Bid placed successfully!"` |
| Bid still exceeds limit after upgrade (Case B) | `SnackbarType.error` | `"Your bid amount exceeds your available buying limit. Please upgrade your buying limit to continue."` |
| Auto-submit API error | `SnackbarType.error` | API error message, or `"Something went wrong. Please try again."` |
| Subscription cache refresh failed | `SnackbarType.error` | `"Failed to refresh subscription. Please try again."` |
| Vehicle not found during auto-submit | `SnackbarType.error` | `"Vehicle not found. Please refresh and try again."` |

No raw `Get.snackbar()` calls for buying-limit scenarios (Req 8.1).

---

## 14. Files to Create / Modify

| Action | File |
|---|---|
| **CREATE** | `lib/features/auction/models/pending_bid.dart` |
| **MODIFY** | `lib/features/auction/controllers/vehicle_listing_controller.dart` |
| **MODIFY** | `lib/features/subscription/controllers/subscription_confirm_controller.dart` |
| **MODIFY** | `lib/features/subscription/views/subscription_screen.dart` (dispose handler) |
