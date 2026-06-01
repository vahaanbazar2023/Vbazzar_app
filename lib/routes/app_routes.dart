class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const introduction = '/introduction';
  static const languageSelection = '/language-selection';
  static const login = '/login';
  static const loginWithOtp = '/login-with-otp';
  static const verifyOtp = '/verify-otp';
  static const completeProfile = '/complete-profile';
  static const home = '/home';
  static const profile = '/profile';
  static const subscription = '/subscription';
  static const subscriptionConfirm = '/subscription/confirm';
  static const mySubscriptions = '/my-subscriptions';
  static const auctionType = '/auction';
  static const auctionListings = '/auction/listings';
  static const vehicleListings = '/auction/vehicle-listings';
  static const vehicleDetail = '/auction/vehicle-detail';
  static const walletPayment = '/subscription/wallet-payment';

  // Buy & Sell
  static const buySellHome = '/buy-sell-home';
  static const sellVehicle = '/sell-vehicle';
  static const buyVehicleListings = '/buy-vehicle-listings';
  static const buyVehicleDetail = '/buy-vehicle-detail';

  // Approved Vehicles
  static const approvedVehicleBuySell = '/approved-vehicle-buy-sell';
  static const approvedVehicleCategory = '/approved-vehicle-category';
  static const approvedVehicleListings = '/approved-vehicle-listings';
  static const approvedVehicleDetail = '/approved-vehicle-detail';
  static const approvedVehicleSellForm = '/approved-vehicle-sell-form';
  static const approvedVehicleMyBookings = '/approved-vehicle-my-bookings';
  static const approvedVehicleMyInspections =
      '/approved-vehicle-my-inspections';
}
