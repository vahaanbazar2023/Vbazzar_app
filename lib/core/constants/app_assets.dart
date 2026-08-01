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
  static const String CE = '${_images}CE.png';
  static const String CV = '${_images}CV.png';
  static const String CC = '${_images}cc.png';
  static const String homeCE = '${_images}excavators_img.png';
  static const String homeCV = '${_images}icv_img.png';

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
  static const String iconNotification = '${_icons}ion_notifications.svg';
  static const String iconCustomerSupport = '${_icons}cc.svg';
  static const String customerCare = '${_images}cc.png';

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

  // ── Bottom nav bar icons ──────────────────────────────────────────────────
  static const String navHome = '${_images}home.png';
  static const String navSubscriptions = '${_images}subscriptions.png';
  static const String navCategory = '${_images}category.png';
  static const String navRewards = '${_images}rewards.png';
  static const String navSettings = '${_images}settings.png';

  // ── Subscription tier badges ──────────────────────────────────────────────
  static const String tierGold = '${_images}gold.png';
  static const String tierSilver = '${_images}silver.png';
  static const String tierBronze = '${_images}bronze.png';

  // ── Service Support ──────────────────────────────────────────────────────
  static const String serviceSupport = '${_images}contact_us.png';

  // ── Dashboard banner images ───────────────────────────────────────────────
  static const String inspectionDashboardIcon =
      '${_images}inspection_dasboard_icon.png';
  static const String insuranceDashboardIcon =
      '${_images}insurance_dashboard_icon.png';
  static const String financeDashboardIcon =
      '${_images}insurance_dashboard_icon.png'; // swap to dedicated asset when available
  static const String yellowBulldoser = '${_images}yellow_bulldoser.png';

  // ── Mechanic icons ────────────────────────────────────────────────────────
  static const List<String> mechanicIcons = [
    '${_images}m2.png',
    '${_images}m3.png',
    '${_images}m4.png',
    '${_images}m5.png',
    '${_images}m6.png',
  ];

  // ── Promo posters ─────────────────────────────────────────────────────────
  static const String poster1 = '${_images}Poster1.png';
  static const String poster2 = '${_images}Poster2.png';
  static const String poster3 = '${_images}Poster3.png';

  static const List<String> promoPosterImages = [poster1, poster2, poster3];

  // ── Miscellaneous images ──────────────────────────────────────────────────
  static const String vbLogo = '${_images}vb_logo.png';
  static const String vahaanBazarText = '${_images}vahaan_bazar_text.png';
  static const String taglineText = '${_images}tagline_text.png';
  static const String vehicleIllustrations =
      '${_images}vehicle_illustrations.png';
  static const String liveBidding = '${_images}live_bidding.png';
  static const String govInventory = '${_images}goverment_inventory.png';
  static const String forgotPasswordIllus =
      '${_images}forgotpassword_illus.png';
}
