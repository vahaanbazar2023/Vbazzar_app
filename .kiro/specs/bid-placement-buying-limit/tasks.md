# Implementation Plan

- [ ] 1. Create `PendingBid` model
  - Create the immutable value object `PendingBid` with `vehicleId` (String) and `bidAmount` (int) fields and a `const` constructor.
  - No serialization needed — this is an in-memory-only model.
  - Satisfies: Req 2.1, Req 2.2
  - **Files:** `lib/features/auction/models/pending_bid.dart`

- [ ] 2. Add `pendingBid` reactive field to `VehicleListingController`
  - Import `PendingBid` and add `final pendingBid = Rxn<PendingBid>();` as a class member on `VehicleListingController`.
  - No other logic changes in this task — just the field declaration.
  - Satisfies: Req 2.1, Req 2.2
  - **Files:** `lib/features/auction/controllers/vehicle_listing_controller.dart`

- [ ] 3. Store pending bid before navigating to subscription in `placeBid`
  - In the "no SUBT002 plan" branch (step 3 of `placeBid`): before calling `Get.back()` and `Get.toNamed(AppRoutes.subscription, ...)`, assign `pendingBid.value = PendingBid(vehicleId: vehicle.vehicleId, bidAmount: bidAmount)`.
  - Do the same in the "limit exceeded / zero balance" branch (step 4 of `placeBid`).
  - The existing `Get.back()` + `Future.delayed` + `Get.toNamed` + `return '__navigated__'` pattern is already correct; only the `pendingBid` assignment is being added before the `Get.back()` call.
  - Satisfies: Req 1.3, Req 1.4, Req 1.5, Req 2.1
  - **Files:** `lib/features/auction/controllers/vehicle_listing_controller.dart`

- [ ] 4. Implement `revalidatePendingBid()` on `VehicleListingController` — Case A (bid now valid)
  - Add the `Future<void> revalidatePendingBid()` method.
  - Early-return if `pendingBid.value == null` or `isPlacingBid.value == true`.
  - Read the refreshed `planAvailableBidAmount` from `SubscriptionGuardService.to.bestSubscription(SubscriptionTypeCode.auctionBidLimit)?.planAvailableBidAmount ?? 0`.
  - **Case A** (`bid.bidAmount <= newLimit`): clear `pendingBid.value = null` first (Req 6.1), set `isPlacingBid.value = true`, look up the vehicle by ID in `vehicles`, call `_repository.placeBid(...)`, on success call `Get.until(...)` to pop `AppRoutes.subscription`, `AppRoutes.subscriptionConfirm`, and `AppRoutes.walletPayment`, then `CustomSnackbar.show(message: 'Bid placed successfully!', type: SnackbarType.success)`, then `_load()`.
  - On `BidException` or general exception show `CustomSnackbar.show(type: SnackbarType.error, ...)` with appropriate message and do NOT navigate.
  - Always set `isPlacingBid.value = false` in a `finally` block.
  - Satisfies: Req 4.1, Req 4.2, Req 4.3, Req 4.4, Req 4.5, Req 6.1, Req 6.2, Req 7.1, Req 8.1, Req 8.3
  - **Files:** `lib/features/auction/controllers/vehicle_listing_controller.dart`

- [ ] 5. Implement `revalidatePendingBid()` — Case B (bid still exceeds limit)
  - Within the same `revalidatePendingBid()` method added in task 4, handle the `else` branch where `bid.bidAmount > newLimit`.
  - Show `CustomSnackbar.show(message: 'Your bid amount exceeds your available buying limit. Please upgrade your buying limit to continue.', type: SnackbarType.error)`.
  - Clear `pendingBid.value = null` after showing the snackbar.
  - Call `Get.back()` to pop `AppRoutes.subscriptionConfirm`, leaving `AppRoutes.subscription` on the stack.
  - Satisfies: Req 5.1, Req 5.2, Req 5.3, Req 6.1, Req 7.2, Req 8.1, Req 8.2
  - **Files:** `lib/features/auction/controllers/vehicle_listing_controller.dart`

- [ ] 6. Add SUBT002 case to `SubscriptionConfirmController._handlePostPaymentNavigation`
  - Add a `case SubscriptionTypeCode.auctionBidLimit:` branch in the `switch` inside `_handlePostPaymentNavigation`.
  - If `Get.isRegistered<VehicleListingController>()` is true, call `Get.find<VehicleListingController>().revalidatePendingBid()` and return.
  - Fallback (controller not registered): call `Get.until(...)` to pop subscription routes then `CustomSnackbar.show(message: 'Buying limit updated!', type: SnackbarType.success)`.
  - Add the required import for `VehicleListingController`.
  - Satisfies: Req 3.1, Req 4.1, Req 5.1, Req 7.1
  - **Files:** `lib/features/subscription/controllers/subscription_confirm_controller.dart`

- [ ] 7. Replace raw `Get.snackbar` calls in `SubscriptionConfirmController` with `CustomSnackbar.show`
  - Replace `_showSnack` (uses `Get.snackbar`) and `_showSuccessSnack` (uses `Get.snackbar`) with calls to `CustomSnackbar.show(message: ..., type: SnackbarType.error/success)`.
  - Update the SUBT001 success call in `_handlePostPaymentNavigation` to use `CustomSnackbar.show(message: 'Auction Access Activated! You can now browse and bid on auctions.', type: SnackbarType.success)`.
  - Update the default-case success call similarly.
  - Update the `onFailure` and guard-refresh-error paths to use `CustomSnackbar.show(type: SnackbarType.error, ...)`.
  - Add the import for `CustomSnackbar` and `SnackbarType`.
  - Satisfies: Req 8.1, Req 8.2, Req 8.3
  - **Files:** `lib/features/subscription/controllers/subscription_confirm_controller.dart`

- [ ] 8. Handle `invalidateAndReload` failure in `SubscriptionConfirmController.onProceedPayment`
  - Wrap the `await SubscriptionGuardService.to.invalidateAndReload()` call in a try/catch inside the `onSuccess` callback.
  - On failure: show `CustomSnackbar.show(message: 'Failed to refresh subscription. Please try again.', type: SnackbarType.error)` and return without calling `_handlePostPaymentNavigation` (so bid revalidation is not attempted on stale data).
  - Satisfies: Req 3.4, Req 8.1, Req 8.2
  - **Files:** `lib/features/subscription/controllers/subscription_confirm_controller.dart`

- [ ] 9. Clear pending bid when `SubscriptionScreen` is disposed (back-press handling)
  - Convert `SubscriptionScreen` from a `StatelessWidget` to a `StatefulWidget` (or add a `dispose` override if it is already stateful via a sub-widget).
  - In `dispose()`, check `Get.isRegistered<VehicleListingController>()` and if true call `Get.find<VehicleListingController>().pendingBid.value = null`.
  - Add the required import for `VehicleListingController`.
  - Satisfies: Req 2.3, Req 7.3
  - **Files:** `lib/features/subscription/views/subscription_screen.dart`

- [ ] 10. Sort SUBT002 plans in ascending bid-limit order on `SubscriptionScreen`
  - In `SubscriptionController` (or the plan-fetch logic it uses), after the plan list is fetched for `SubscriptionTypeCode.auctionBidLimit`, sort it by `planAvailableBidAmount` ascending before assigning to the observable list.
  - If `SubscriptionPlan` does not expose `planAvailableBidAmount` directly, sort by `price` ascending as the proxy (lower price = lower limit tier).
  - Satisfies: Req 5.4
  - **Files:** `lib/features/subscription/controllers/subscription_controller.dart`
