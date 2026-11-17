import '../../../core/constants/app_assets.dart';
import '../../../routes/app_routes.dart';

/// The user's activity per module, from POST /api/v1/dashboard/activity-summary.
/// Drives the Profile stats card and the "Explore more" card.
class ActivitySummary {
  final int wins;
  final int activeBids;
  final int wishlist;
  final int vehiclesListed;
  final int sellerContacts;
  final String? primaryModule;
  final List<String> usedModules;
  final List<String> unusedModules;

  const ActivitySummary({
    this.wins = 0,
    this.activeBids = 0,
    this.wishlist = 0,
    this.vehiclesListed = 0,
    this.sellerContacts = 0,
    this.primaryModule,
    this.usedModules = const [],
    this.unusedModules = const [],
  });

  static int _int(dynamic m, String key) {
    final v = m is Map ? m[key] : null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse('${v ?? ''}') ?? 0;
  }

  static List<String> _list(dynamic v) =>
      v is List ? v.map((e) => '$e').toList() : const [];

  factory ActivitySummary.fromJson(Map<String, dynamic> json) {
    return ActivitySummary(
      wins: _int(json['auction'], 'wins'),
      activeBids: _int(json['auction'], 'active_bids'),
      wishlist: _int(json['auction'], 'wishlist'),
      vehiclesListed: _int(json['buy_sell'], 'listed'),
      sellerContacts: _int(json['buy_sell'], 'contacts'),
      primaryModule: json['primary_module'] as String?,
      usedModules: _list(json['used_modules']),
      unusedModules: _list(json['unused_modules']),
    );
  }

  /// Which untried module to suggest: the one that best follows what the user already does.
  /// An auction customer is pointed at Buy & Sell first, a Buy & Sell customer at auctions, and so on.
  /// Null when the user has tried everything.
  String? get suggestedModule {
    const next = <String?, List<String>>{
      'auction': [
        'buy_sell',
        'approved_vehicles',
        'inspection',
        'insurance_finance',
        'spares',
      ],
      'buy_sell': [
        'auction',
        'inspection',
        'insurance_finance',
        'approved_vehicles',
        'spares',
      ],
      'approved_vehicles': [
        'auction',
        'buy_sell',
        'insurance_finance',
        'inspection',
        'spares',
      ],
      'spares': [
        'buy_sell',
        'auction',
        'inspection',
        'insurance_finance',
        'approved_vehicles',
      ],
      'inspection': [
        'buy_sell',
        'auction',
        'insurance_finance',
        'approved_vehicles',
        'spares',
      ],
      'insurance_finance': [
        'buy_sell',
        'auction',
        'inspection',
        'approved_vehicles',
        'spares',
      ],
      null: [
        'auction',
        'buy_sell',
        'approved_vehicles',
        'inspection',
        'insurance_finance',
        'spares',
      ],
    };
    final order = next[primaryModule] ?? next[null]!;
    for (final m in order) {
      if (unusedModules.contains(m)) return m;
    }
    return null;
  }
}

/// Where each module's explore card leads, and its picture.
const Map<String, ({String route, String image})> kExploreModules = {
  'auction': (route: AppRoutes.auctionType, image: AppAssets.auction),
  'buy_sell': (route: AppRoutes.buySellHome, image: AppAssets.buySell),
  'approved_vehicles': (
    route: AppRoutes.approvedVehicleBuySell,
    image: AppAssets.homeCV,
  ),
  'spares': (route: AppRoutes.spareFms, image: AppAssets.spareParts),
  'inspection': (route: AppRoutes.inspectionHome, image: AppAssets.inspection),
  'insurance_finance': (
    route: AppRoutes.insuranceFinance,
    image: AppAssets.insuranceFinance,
  ),
};

/// Explore card copy per language: eyebrow, button, and title/body per module.
const Map<String, Map<String, String>> kExploreCopy = {
  'en': {
    'eyebrow': 'Explore more',
    'cta': 'Explore',
    'auction.title': 'Bid in live bank auctions',
    'auction.body':
        'Repossessed vehicles from banks, below market prices. Place your first bid.',
    'buy_sell.title': 'Sell your vehicle on Buy & Sell',
    'buy_sell.body':
        'List it in minutes and reach thousands of buyers, or find your next vehicle.',
    'approved_vehicles.title': 'Buy approved vehicles',
    'approved_vehicles.body':
        'Checked vehicles with clear documents, ready to book.',
    'spares.title': 'Find spare parts nearby',
    'spares.body': 'Order genuine spares from shops near you.',
    'inspection.title': 'Get your vehicle inspected',
    'inspection.body':
        'Know the real condition and value before you buy or sell.',
    'insurance_finance.title': 'Insurance & finance quotes',
    'insurance_finance.body': 'Compare quotes for your vehicle in one place.',
  },
  'hi': {
    'eyebrow': 'और देखें',
    'cta': 'देखें',
    'auction.title': 'लाइव बैंक नीलामी में बोली लगाएँ',
    'auction.body':
        'बैंकों से ज़ब्त वाहन, बाज़ार से कम दाम पर। अपनी पहली बोली लगाएँ।',
    'buy_sell.title': 'खरीदें-बेचें पर अपना वाहन बेचें',
    'buy_sell.body':
        'मिनटों में लिस्ट करें और हज़ारों खरीदारों तक पहुँचें, या अपना अगला वाहन खोजें।',
    'approved_vehicles.title': 'अप्रूव्ड वाहन खरीदें',
    'approved_vehicles.body':
        'जाँचे हुए वाहन, साफ़ दस्तावेज़ों के साथ, बुकिंग के लिए तैयार।',
    'spares.title': 'पास में स्पेयर पार्ट्स खोजें',
    'spares.body': 'अपने नज़दीकी दुकानों से असली स्पेयर पार्ट्स मँगवाएँ।',
    'inspection.title': 'अपने वाहन की जाँच करवाएँ',
    'inspection.body': 'खरीदने या बेचने से पहले असली हालत और कीमत जानें।',
    'insurance_finance.title': 'बीमा और फाइनेंस कोटेशन',
    'insurance_finance.body': 'अपने वाहन के कोटेशन एक ही जगह तुलना करें।',
  },
  'te': {
    'eyebrow': 'మరిన్ని చూడండి',
    'cta': 'చూడండి',
    'auction.title': 'లైవ్ బ్యాంక్ వేలంలో బిడ్ చేయండి',
    'auction.body':
        'బ్యాంకుల నుండి వచ్చిన వాహనాలు మార్కెట్ కంటే తక్కువ ధరకు. మీ మొదటి బిడ్ వేయండి.',
    'buy_sell.title': 'కొనండి-అమ్మండిలో మీ వాహనాన్ని అమ్మండి',
    'buy_sell.body':
        'నిమిషాల్లో లిస్ట్ చేసి వేలాది కొనుగోలుదారులను చేరండి, లేదా మీ తదుపరి వాహనాన్ని కనుగొనండి.',
    'approved_vehicles.title': 'ఆమోదిత వాహనాలు కొనండి',
    'approved_vehicles.body':
        'తనిఖీ చేసిన వాహనాలు, స్పష్టమైన పత్రాలతో, బుకింగ్‌కు సిద్ధం.',
    'spares.title': 'దగ్గరలో స్పేర్ పార్ట్స్ కనుగొనండి',
    'spares.body': 'మీ దగ్గరి షాపుల నుండి అసలైన స్పేర్ పార్ట్స్ ఆర్డర్ చేయండి.',
    'inspection.title': 'మీ వాహనాన్ని తనిఖీ చేయించండి',
    'inspection.body': 'కొనే లేదా అమ్మే ముందు అసలు స్థితి, విలువ తెలుసుకోండి.',
    'insurance_finance.title': 'బీమా & ఫైనాన్స్ కోట్స్',
    'insurance_finance.body': 'మీ వాహనానికి కోట్స్‌ను ఒకే చోట పోల్చండి.',
  },
  'kn': {
    'eyebrow': 'ಇನ್ನಷ್ಟು ನೋಡಿ',
    'cta': 'ನೋಡಿ',
    'auction.title': 'ಲೈವ್ ಬ್ಯಾಂಕ್ ಹರಾಜಿನಲ್ಲಿ ಬಿಡ್ ಮಾಡಿ',
    'auction.body':
        'ಬ್ಯಾಂಕ್‌ಗಳಿಂದ ಬಂದ ವಾಹನಗಳು ಮಾರುಕಟ್ಟೆಗಿಂತ ಕಡಿಮೆ ಬೆಲೆಗೆ. ನಿಮ್ಮ ಮೊದಲ ಬಿಡ್ ಮಾಡಿ.',
    'buy_sell.title': 'ಖರೀದಿ-ಮಾರಾಟದಲ್ಲಿ ನಿಮ್ಮ ವಾಹನ ಮಾರಿ',
    'buy_sell.body':
        'ನಿಮಿಷಗಳಲ್ಲಿ ಲಿಸ್ಟ್ ಮಾಡಿ ಸಾವಿರಾರು ಖರೀದಿದಾರರನ್ನು ತಲುಪಿ, ಅಥವಾ ನಿಮ್ಮ ಮುಂದಿನ ವಾಹನ ಹುಡುಕಿ.',
    'approved_vehicles.title': 'ಅನುಮೋದಿತ ವಾಹನಗಳನ್ನು ಖರೀದಿಸಿ',
    'approved_vehicles.body':
        'ಪರಿಶೀಲಿಸಿದ ವಾಹನಗಳು, ಸ್ಪಷ್ಟ ದಾಖಲೆಗಳೊಂದಿಗೆ, ಬುಕಿಂಗ್‌ಗೆ ಸಿದ್ಧ.',
    'spares.title': 'ಹತ್ತಿರದ ಸ್ಪೇರ್ ಪಾರ್ಟ್ಸ್ ಹುಡುಕಿ',
    'spares.body': 'ನಿಮ್ಮ ಹತ್ತಿರದ ಅಂಗಡಿಗಳಿಂದ ಅಸಲಿ ಸ್ಪೇರ್ ಪಾರ್ಟ್ಸ್ ಆರ್ಡರ್ ಮಾಡಿ.',
    'inspection.title': 'ನಿಮ್ಮ ವಾಹನವನ್ನು ಪರಿಶೀಲಿಸಿ',
    'inspection.body':
        'ಖರೀದಿಸುವ ಅಥವಾ ಮಾರುವ ಮೊದಲು ನಿಜವಾದ ಸ್ಥಿತಿ ಮತ್ತು ಮೌಲ್ಯ ತಿಳಿಯಿರಿ.',
    'insurance_finance.title': 'ವಿಮೆ ಮತ್ತು ಫೈನಾನ್ಸ್ ಕೋಟ್‌ಗಳು',
    'insurance_finance.body': 'ನಿಮ್ಮ ವಾಹನಕ್ಕೆ ಕೋಟ್‌ಗಳನ್ನು ಒಂದೇ ಕಡೆ ಹೋಲಿಸಿ.',
  },
  'ml': {
    'eyebrow': 'കൂടുതൽ കാണൂ',
    'cta': 'കാണൂ',
    'auction.title': 'ലൈവ് ബാങ്ക് ലേലത്തിൽ ബിഡ് ചെയ്യൂ',
    'auction.body':
        'ബാങ്കുകളിൽ നിന്നുള്ള വാഹനങ്ങൾ വിപണി വിലയേക്കാൾ കുറഞ്ഞ വിലയ്ക്ക്. നിങ്ങളുടെ ആദ്യ ബിഡ് നൽകൂ.',
    'buy_sell.title': 'വാങ്ങൽ-വിൽപ്പനയിൽ നിങ്ങളുടെ വാഹനം വിൽക്കൂ',
    'buy_sell.body':
        'മിനിറ്റുകൾക്കുള്ളിൽ ലിസ്റ്റ് ചെയ്ത് ആയിരക്കണക്കിന് വാങ്ങുന്നവരിലേക്ക് എത്തൂ, അല്ലെങ്കിൽ അടുത്ത വാഹനം കണ്ടെത്തൂ.',
    'approved_vehicles.title': 'അംഗീകൃത വാഹനങ്ങൾ വാങ്ങൂ',
    'approved_vehicles.body':
        'പരിശോധിച്ച വാഹനങ്ങൾ, വ്യക്തമായ രേഖകളോടെ, ബുക്കിംഗിന് തയ്യാർ.',
    'spares.title': 'അടുത്തുള്ള സ്പെയർ പാർട്സ് കണ്ടെത്തൂ',
    'spares.body':
        'അടുത്തുള്ള കടകളിൽ നിന്ന് ഒറിജിനൽ സ്പെയർ പാർട്സ് ഓർഡർ ചെയ്യൂ.',
    'inspection.title': 'നിങ്ങളുടെ വാഹനം പരിശോധിപ്പിക്കൂ',
    'inspection.body':
        'വാങ്ങുന്നതിനോ വിൽക്കുന്നതിനോ മുമ്പ് യഥാർത്ഥ അവസ്ഥയും വിലയും അറിയൂ.',
    'insurance_finance.title': 'ഇൻഷുറൻസ് & ഫിനാൻസ് ക്വോട്ടുകൾ',
    'insurance_finance.body':
        'നിങ്ങളുടെ വാഹനത്തിനുള്ള ക്വോട്ടുകൾ ഒരിടത്ത് താരതമ്യം ചെയ്യൂ.',
  },
  'ta': {
    'eyebrow': 'மேலும் பாருங்கள்',
    'cta': 'பாருங்கள்',
    'auction.title': 'நேரடி வங்கி ஏலத்தில் ஏலம் கேளுங்கள்',
    'auction.body':
        'வங்கிகளின் வாகனங்கள் சந்தை விலையை விடக் குறைவாக. உங்கள் முதல் ஏலத்தைக் கேளுங்கள்.',
    'buy_sell.title': 'வாங்கு-விற்பனையில் உங்கள் வாகனத்தை விற்கவும்',
    'buy_sell.body':
        'நிமிடங்களில் பட்டியலிட்டு ஆயிரக்கணக்கான வாங்குபவர்களை அடையுங்கள், அல்லது அடுத்த வாகனத்தைக் கண்டறியுங்கள்.',
    'approved_vehicles.title': 'அங்கீகரிக்கப்பட்ட வாகனங்களை வாங்குங்கள்',
    'approved_vehicles.body':
        'சரிபார்க்கப்பட்ட வாகனங்கள், தெளிவான ஆவணங்களுடன், முன்பதிவுக்குத் தயார்.',
    'spares.title': 'அருகில் உதிரி பாகங்களைக் கண்டறியுங்கள்',
    'spares.body':
        'அருகிலுள்ள கடைகளிலிருந்து அசல் உதிரி பாகங்களை ஆர்டர் செய்யுங்கள்.',
    'inspection.title': 'உங்கள் வாகனத்தைப் பரிசோதியுங்கள்',
    'inspection.body':
        'வாங்கும் முன் அல்லது விற்கும் முன் உண்மையான நிலையும் மதிப்பும் அறியுங்கள்.',
    'insurance_finance.title': 'காப்பீடு & நிதி மேற்கோள்கள்',
    'insurance_finance.body':
        'உங்கள் வாகனத்துக்கான மேற்கோள்களை ஒரே இடத்தில் ஒப்பிடுங்கள்.',
  },
};
