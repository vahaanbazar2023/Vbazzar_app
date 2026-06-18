class ApiEndpoints {
  ApiEndpoints._();

  static const String subscriptionPrefix = '/api/v1/subscription';

  // ─── Auth ────────────────────────────────────────────────────
  static const String login = '/api/v2/auth/login';
  static const String verifyOtp = '/api/v2/auth/verify-otp';
  static const String completeProfile = '/api/v2/auth/complete-profile';
  static const String logout = '/api/v1/auth/logout';
  static const String refreshToken = '/api/v1/auth/refresh-token';

  // ─── User / Profile ──────────────────────────────────────────
  static const String profile = '/api/v1/dashboard/profile';
  static const String updateProfile = '/api/v1/dashboard/profile-update';
  static const String changePassword = '/api/v1/dashboard/change-password';

  // ─── Dashboard ───────────────────────────────────────────────
  static const String categoriesHome = '/api/v1/dashboard/categories-home';
  static const String dashboardHome = '/api/v2/dashboard/home';

  // ─── Subscription ───────────────────────────────────────────────
  static const String mySubscriptions = '$subscriptionPrefix/my-subscriptions';
  static const String subscriptionListing =
      '$subscriptionPrefix/subscription-listing';
  static const String walletEligibility = '/api/v1/wallet/eligibility';
  static const String walletDashboard = '/api/v1/wallet/dashboard';

  // ─── Vehicles ────────────────────────────────────────────────
  static const String vehicles = '/vehicles';
  static String vehicleById(String id) => '/vehicles/$id';

  // ─── Payments ─────────────────────────────────────────────────
  static const String paymentPrefix = '/api/v1/payments';
  static const String paymentInitiate = '$paymentPrefix/initiate';
  static const String paymentSuccess = '$paymentPrefix/success';
  static const String paymentFailure = '$paymentPrefix/failure';

  // ─── Notifications ───────────────────────────────────────────
  static const String notifications = '/notifications';

  // ─── Buy & Sell ─────────────────────────────────────────────
  static const String buySellPrefix = '/api/v1/sell-buy';
  static const String vehicleCategories = '$buySellPrefix/vehicle-categories';
  static const String vehicleBrands = '$buySellPrefix/vehicle-brands';
  static const String vehicleListings = '$buySellPrefix/vehicle-listings';
  static const String vehicleTyres = '$buySellPrefix/tyres';
  static const String sellVehicle = '$buySellPrefix/sell-vehicle';
  static const String listSellVehicles = '$buySellPrefix/list-sell-vehicles';
  static const String updateSellVehicles =
      '$buySellPrefix/update-sell-vehicles';
  static const String listBuySubscribedVehicles =
      '$buySellPrefix/list-buy-subscribed-vehicles';
  static const String vehicleCategoryFormFields =
      '$buySellPrefix/vehicle-category-form-fields';
  static const String vehicleCategoryFilters =
      '$buySellPrefix/vehicle-category-filters';
  static const String vehicleCategoryListByFilters =
      '$buySellPrefix/vehicle-category-list-by-filters';
  static const String sbVehicleSold = '$buySellPrefix/sb-vehicle-sold';
  static const String userInterest = '$buySellPrefix/user-interest';

  // ─── Locations ────────────────────────────────────────────────
  static const String locationPrefix = '/api/v1/locations';
  static const String states = '$locationPrefix/states';
  static const String cities = '$locationPrefix/cities';

  // ─── Auction ──────────────────────────────────────────────────
  static const String auctionPrefix = '/api/v1/auctions';
  static const String auctionListings =
      '$auctionPrefix/auction-listings-pagination';
  static const String auctionVehicleListings =
      '$auctionPrefix/vehicle-listings-pagination';
  static const String placeBid = '$auctionPrefix/auction-vehicle-bid';

  static const String myBids = '$auctionPrefix/my-bids';
  static const String myWins = '$auctionPrefix/my-wins';
  static const String myBidsPaginated =
      '$auctionPrefix/auction-my-bids-pagination';
  static const String myWinsPaginated =
      '$auctionPrefix/auction-my-wins-pagination';
  static const String winningLetter = '$auctionPrefix/winning-letter';
  static const String updateInsuranceInterest =
      '$auctionPrefix/update-insurance-interest';
  static const String regions = '$locationPrefix/regions';
  static String statesByRegion(String regionId) =>
      '$locationPrefix/regions/$regionId/states';
  static const String vehicleSearch = '$auctionPrefix/vehicle-search';
  static const String auctionRefundInitiate =
      '/api/v1/dashboard/auction-refund-initiate';
  static const String vehicleExcelDownload =
      '$auctionPrefix/vehicle-excel-download';

  // ─── Spare & FMS ────────────────────────────────────────────
  static const String spareFmsPrefix = '/api/v1/spares-fms';
  static const String listSpares = '$spareFmsPrefix/list-spares';
  static const String listShops = '$spareFmsPrefix/list-shops';
  static const String userSpareInterest = '$spareFmsPrefix/user-spare-interest';
  static const String userShopSubscription =
      '$spareFmsPrefix/user-shop-subscription';
  static const String userShopNumberAccess =
      '$spareFmsPrefix/user-shop-subscription'; // same endpoint, number_access_subscription: yes
  static const String userSparesOrdersListing =
      '$spareFmsPrefix/user-spares-orders-listing';

  // ─── Service Support ─────────────────────────────────────────
  static const String serviceSupportPrefix = '/api/v1/service-support';
  static const String listMechanics = '$serviceSupportPrefix/list-mechanics';
  static const String userMechanicSubscription =
      '$serviceSupportPrefix/user-mechanic-subscription';

  // ─── Insurance & Finance ────────────────────────────────────
  static const String insuranceFinancePrefix = '/api/v1/insurance-finance';
  static const String insuranceRequest =
      '$insuranceFinancePrefix/insurance-request';
  static const String financeRequest =
      '$insuranceFinancePrefix/finance-request';
  static const String vehicleQuotes = '$insuranceFinancePrefix/vehicle-quotes';
  static const String vehicleListingsQuotes =
      '$insuranceFinancePrefix/vehicle-listings-quotes';

  // ─── Inspection & Valuation ────────────────────────────────
  static const String inspectionValuationPrefix =
      '/api/v1/inspection-valuation';
  static const String valuationDropdownOptions =
      '$inspectionValuationPrefix/valuation-dropdown-options';
  static const String customerInspectionForm =
      '$inspectionValuationPrefix/customer-inspection-form';
  static const String agentValuationForm =
      '$inspectionValuationPrefix/agent-valuation-form';
  static const String myInspections =
      '$inspectionValuationPrefix/my-inspections';
}
