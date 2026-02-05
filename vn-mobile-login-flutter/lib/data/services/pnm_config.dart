/// PNM Platform API Configuration
/// 
/// Contains credentials for connecting to PNM platform.
/// Update these values for different environments (dev/staging/prod).
class PnmConfig {
  PnmConfig._();

  /// Base URL for PNM API server
  static const String baseUrl = 'http://10.211.31.2';

  /// Application key provided by PNM platform
  static const String appKey = 'PLKBT';

  /// Secret key for signature generation (keep secure!)
  static const String secretKey = 'oiw3vd5r2tdz58zs';

  /// Default masked number when API fails
  static const String defaultMaskedNumber = '098999999';

  /// Default AXB masked number for order calls when API fails
  static const String defaultAxbMaskedNumber = '1900636999';

  /// API timeout in seconds
  static const int timeoutSeconds = 30;
}
