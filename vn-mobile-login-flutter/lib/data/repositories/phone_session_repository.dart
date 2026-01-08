/// Repository for phone session/PNM operations
abstract class PhoneSessionRepository {
  Future<String> createSession(String phoneNumber);
  Future<String> getVirtualNumber(String sessionId);
}

/// Implementation of PhoneSessionRepository with mock data
class PhoneSessionRepositoryImpl implements PhoneSessionRepository {
  // Mock virtual number
  static const String _virtualNumber = '1900636999';

  @override
  Future<String> createSession(String phoneNumber) async {
    // Simulate API call to create PNM session
    await Future.delayed(const Duration(milliseconds: 500));
    return 'session_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<String> getVirtualNumber(String sessionId) async {
    // Simulate API call to get virtual number
    await Future.delayed(const Duration(milliseconds: 300));
    return _virtualNumber;
  }
}

