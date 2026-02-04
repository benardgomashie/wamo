class AppConstants {
  // App Identity
  static const String appName = 'Wamo';
  static const String appTagline = 'Give. Help. Reach.';
  static const String appMeaning = '"Wamo" means "help" in Ga';
  static const String appUrl = 'https://wamo.app';
  
  // API Keys (Paystack TEST keys - DO NOT use in production)
  static const String paystackPublicKey = String.fromEnvironment(
    'PAYSTACK_PUBLIC_KEY',
    defaultValue: 'pk_test_7569b1d11aa4376124c69b17244e010b47526a2f',
  );
  
  static const String paystackSecretKey = String.fromEnvironment(
    'PAYSTACK_SECRET_KEY',
    defaultValue: 'sk_test_af8737674f197fc295215be2270ced06d26f60cf',
  );
  
  // App Configuration
  static const int maxImageSizeMB = 2;
  static const int maxImagesPerCampaign = 5;
  static const double platformFeePercentage = 4.0;
  static const int campaignCreationTimeoutMinutes = 5;
  static const int donationTimeoutSeconds = 30;
  
  // Campaign Limits
  static const double minCampaignAmount = 50.0;
  static const double maxCampaignAmount = 100000.0;
  static const int maxCampaignTitleLength = 80;
  static const int maxCampaignStoryLength = 2000;
  static const int minCampaignStoryLength = 100;
  
  // Donation Limits
  static const double minDonationAmount = 5.0;
  static const double maxDonationAmount = 50000.0;
  
  // Timeouts
  static const int verificationTimeoutHours = 24;
  static const int payoutDelayHours = 48;
  
  // URLs
  static const String privacyPolicyUrl = 'https://wamo.app/privacy';
  static const String termsOfServiceUrl = 'https://wamo.app/terms';
  static const String supportEmail = 'support@wamo.app';
  static const String supportWhatsApp = '+233XXXXXXXXX';
  
  // Storage Paths
  static const String campaignProofPath = 'campaigns/proof/';
  static const String campaignUpdatesPath = 'campaigns/updates/';
  static const String userProfilesPath = 'users/profiles/';
  
  // Collection Names
  static const String usersCollection = 'users';
  static const String campaignsCollection = 'campaigns';
  static const String donationsCollection = 'donations';
  static const String updatesCollection = 'updates';
  static const String payoutsCollection = 'payouts';
  static const String notificationsCollection = 'notifications';
  
  // Campaign Causes
  static const List<String> campaignCauses = [
    'Medical',
    'Education',
    'Funeral',
    'Emergency',
    'Community',
  ];
  
  // Campaign Statuses
  static const String statusDraft = 'draft';
  static const String statusPending = 'pending';
  static const String statusActive = 'active';
  static const String statusCompleted = 'completed';
  static const String statusRejected = 'rejected';
  static const String statusFrozen = 'frozen';
  
  // Payment Methods
  static const String paymentMobileMoney = 'mobile_money';
  static const String paymentCard = 'card';
  
  // User Roles
  static const String roleCreator = 'creator';
  static const String roleDonor = 'donor';
  static const String roleAdmin = 'admin';
  
  // Payout Statuses
  static const String payoutFundsAvailable = 'funds_available';
  static const String payoutPendingReview = 'pending_review';
  static const String payoutApproved = 'approved';
  static const String payoutProcessing = 'processing';
  static const String payoutCompleted = 'completed';
  static const String payoutFailed = 'failed';
  static const String payoutOnHold = 'on_hold';
  
  // Validation Messages
  static const String errorInvalidPhone = 'Please enter a valid phone number';
  static const String errorInvalidAmount = 'Please enter a valid amount';
  static const String errorMinAmount = 'Amount must be at least GHS ';
  static const String errorMaxAmount = 'Amount cannot exceed GHS ';
  static const String errorRequiredField = 'This field is required';
  static const String errorNetworkError = 'Network error. Please check your connection.';
  static const String errorUnknown = 'An unexpected error occurred. Please try again.';
}
