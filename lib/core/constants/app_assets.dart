class AppAssets {
  AppAssets._();

  // ── Base paths ───────────────────────────────────────────────
  static const String _images = 'assets/images/png/';
  static const String _icons = 'assets/images/svg/';
  static const String _lottie = 'assets/lottie/';

  // ── Images ───────────────────────────────────────────────────
  static const String logo = '${_images}logo.png';
  static const String logoWhite = '${_images}logo_white.png';
  static const String splash = '${_images}splash_bg.png';
  static const String placeholder = '${_images}placeholder.png';

  // category Images
  static const String auction = '${_images}auction.png';
  static const String buySell = '${_images}buy_sell.png';
  static const String fms = '${_images}fms.png';
  static const String insuranceFinance = '${_images}insurance_finance.png';
  static const String inspection = '${_images}inspection.png';
  static const String spareParts = '${_images}spare_parts.png';

  // Intro screen vehicle images
  static const String intro1 = '${_images}white_truck.png';
  static const String intro2 = '${_images}red_car.png';
  static const String intro3 = '${_images}yellow_jcb.png';

  // Aliases used by intro controller
  static const String introSlide1 = intro1;
  static const String introSlide2 = intro2;
  static const String introSlide3 = intro3;

  // ── Lottie ───────────────────────────────────────────────────
  static const String lottieLoading = '${_lottie}loading.json';
  static const String lottieSuccess = '${_lottie}success.json';
  static const String lottieError = '${_lottie}error.json';
  static const String lottieEmpty = '${_lottie}empty.json';

  // ── Icons ─────────────────────────────────────────────────────

  static const String arrowBack = '${_icons}arrowBack.svg';
  static const String cancel = '${_icons}cancel.svg';
  static const String clock = '${_icons}clock.svg';
  static const String iconHome = '${_icons}home.svg';
  static const String iconProfile = '${_icons}profile.svg';
  static const String iconVehicle = '${_icons}vehicle.svg';

  // ── Auction icons ─────────────────────────────────────────────────────────
  static const String auctionIcon = '${_icons}auction.svg';
  static const String calendarIcon = '${_icons}calander.svg';
  static const String hourglassIcon = '${_icons}hourglass.svg';
  static const String bidIcon = '${_icons}bid.svg';

  // ── PNG icons ─────────────────────────────────────────────────────────────
  static const String bidPng = '${_images}bid.png';
  static const String hourglassPng = '${_images}hourglass.png';
  static const String calendarPng = '${_images}calender.png';
  static const String filterPng = '${_images}filter.png';
}
