/// Utility class for phone number operations
class PhoneUtils {
  PhoneUtils._();

  /// Masks a phone number for privacy display
  /// Example: "0901234567" -> "090****567"
  static String maskPhoneNumber(String? phone) {
    if (phone == null || phone.length < 4) return '098****232';
    final cleaned = phone.replaceAll(' ', '');
    if (cleaned.length >= 7) {
      return '${cleaned.substring(0, 3)}****${cleaned.substring(cleaned.length - 3)}';
    }
    return '098****232';
  }

  /// Formats a virtual number for display
  /// Example: "1900636999" -> "1900 636 999"
  static String formatVirtualNumber(String number) {
    if (number.length == 10) {
      return '${number.substring(0, 4)} ${number.substring(4, 7)} ${number.substring(7)}';
    }
    return number;
  }

  /// Validates if a phone number is valid Vietnamese format
  static bool isValidVietnamesePhone(String phone) {
    final cleaned = phone.replaceAll(' ', '');
    // Vietnamese phone: starts with 0, 10 digits
    final regex = RegExp(r'^0[35789]\d{8}$');
    return regex.hasMatch(cleaned);
  }
}

