import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

import 'pnm_config.dart';

/// Response model for AX Binding
class AxBindingResponse {
  final int code;
  final String message;
  final String? subid;
  final String? telX;

  AxBindingResponse({
    required this.code,
    required this.message,
    this.subid,
    this.telX,
  });

  bool get isSuccess => code == 0;

  factory AxBindingResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return AxBindingResponse(
      code: json['code'] as int? ?? -1,
      message: json['message'] as String? ?? 'Unknown error',
      subid: data?['subid'] as String?,
      telX: data?['telX'] as String?,
    );
  }
}

/// PNM Platform API Service
/// 
/// Handles communication with PNM platform for phone number masking.
/// Implements MD5 signature generation as per API specification.
class PnmService {
  final Dio _dio;

  PnmService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: PnmConfig.baseUrl,
              connectTimeout: Duration(seconds: PnmConfig.timeoutSeconds),
              receiveTimeout: Duration(seconds: PnmConfig.timeoutSeconds),
              headers: {
                'Accept': 'application/json;charset=utf-8',
                'Content-Type': 'application/json;charset=utf-8',
              },
            ));

  /// Create AX binding to get masked number (telX)
  /// 
  /// [telA] - User's real phone number
  /// [telB] - Callee's real phone number (optional for initial binding)
  /// [areacode] - Area code for number allocation (e.g., "010" for Beijing)
  /// 
  /// Returns [AxBindingResponse] with subid and telX on success
  Future<AxBindingResponse> createBinding({
    required String telA,
    String? telB,
    String areacode = '010',
    String expiration = '360',
    String anucode = ',,0',
    String? remark,
    Map<String, String>? extra,
  }) async {
    try {
      final ts = _generateTimestamp();
      final subts = ts.substring(0, 14); // yyyyMMddHHmmss
      final requestId = _generateRequestId();

      // Build request body
      final Map<String, dynamic> body = {
        'requestId': requestId,
        'telA': telA,
        'subts': subts,
        'anucode': anucode,
        'areacode': areacode,
        'expiration': expiration,
      };

      if (telB != null && telB.isNotEmpty) {
        body['telB'] = telB;
      }

      if (remark != null && remark.isNotEmpty) {
        body['remark'] = remark;
      }

      // Default extra parameters
      final extraParams = extra ?? {
        'calldisplay': '0,0',
        'callrecording': '1',
      };
      body['extra'] = extraParams;

      // Generate signature
      final msgdgt = _generateMsgdgt(
        ts: ts,
        body: body,
        extraParams: extraParams,
      );

      // Make API request
      final response = await _dio.post(
        '/v2/ax/mode102',
        data: body,
        options: Options(
          headers: {
            'appkey': PnmConfig.appKey,
            'ts': ts,
            'msgdgt': msgdgt,
          },
        ),
      );

      return AxBindingResponse.fromJson(response.data);
    } on DioException catch (e) {
      return AxBindingResponse(
        code: -1,
        message: 'Network error: ${e.message}',
      );
    } catch (e) {
      return AxBindingResponse(
        code: -1,
        message: 'Error: $e',
      );
    }
  }

  /// Create AXB binding to link Driver(A) ↔ X ↔ Customer(B)
  /// 
  /// [telA] - Driver's real phone number
  /// [telB] - Customer's real phone number
  /// [areacode] - Area code for X number allocation (mode102)
  /// [expiration] - Binding expiration in seconds
  /// 
  /// Returns [AxBindingResponse] with subid and telX on success
  Future<AxBindingResponse> createAxbBinding({
    required String telA,
    required String telB,
    String areacode = '010',
    String expiration = '360',
    String anucode = ',,0',
    String? remark,
    Map<String, String>? extra,
  }) async {
    try {
      final ts = _generateTimestamp();
      final subts = ts.substring(0, 14); // yyyyMMddHHmmss
      final requestId = _generateRequestId();

      // Build request body for AXB mode102
      final Map<String, dynamic> body = {
        'requestId': requestId,
        'telA': telA,
        'telB': telB,
        'subts': subts,
        'anucode': anucode,
        'areacode': areacode,
        'expiration': expiration,
      };

      if (remark != null && remark.isNotEmpty) {
        body['remark'] = remark;
      }

      // Default extra parameters for AXB (matching production)
      final extraParams = extra ?? {
        'callrecording': '1',
        'calldisplay': '0,0',
      };
      body['extra'] = extraParams;

      // Generate signature
      final msgdgt = _generateMsgdgt(
        ts: ts,
        body: body,
        extraParams: extraParams,
      );

      print('[PNM] Creating AXB binding: telA=$telA, telB=$telB');

      // Make API request - AXB mode102
      final response = await _dio.post(
        '/v2/axb/mode102',
        data: body,
        options: Options(
          headers: {
            'appkey': PnmConfig.appKey,
            'ts': ts,
            'msgdgt': msgdgt,
          },
        ),
      );

      final result = AxBindingResponse.fromJson(response.data);
      print('[PNM] AXB binding result: code=${result.code}, telX=${result.telX}, subid=${result.subid}');
      
      return result;
    } on DioException catch (e) {
      print('[PNM] AXB binding network error: ${e.message}');
      return AxBindingResponse(
        code: -1,
        message: 'Network error: ${e.message}',
      );
    } catch (e) {
      print('[PNM] AXB binding error: $e');
      return AxBindingResponse(
        code: -1,
        message: 'Error: $e',
      );
    }
  }

  /// Online call through masked number
  /// 
  /// [subid] - Binding ID from createBinding
  /// [telB] - Callee's real phone number
  Future<bool> onlineCall({
    required String subid,
    required String telB,
  }) async {
    try {
      final ts = _generateTimestamp();
      final requestId = _generateRequestId();

      final body = {
        'requestId': requestId,
        'telB': telB,
      };

      final msgdgt = _generateMsgdgt(
        ts: ts,
        body: body,
        extraParams: {},
      );

      final response = await _dio.put(
        '/v2/ax/onlinecall/$subid',
        data: body,
        options: Options(
          headers: {
            'appkey': PnmConfig.appKey,
            'ts': ts,
            'msgdgt': msgdgt,
          },
        ),
      );

      final code = response.data['code'] as int?;
      return code == 0;
    } catch (e) {
      return false;
    }
  }

  /// Unbind AXB relationship
  /// 
  /// [subid] - Binding ID from createAxbBinding
  /// 
  /// Returns true if unbinding was successful
  Future<bool> unbindAxb({
    required String subid,
  }) async {
    try {
      final ts = _generateTimestamp();

      // For DELETE request, only header params are used for signature
      final msgdgt = _generateMsgdgtHeaderOnly(ts: ts);

      print('[PNM] Unbinding AXB: subid=$subid');

      final response = await _dio.delete(
        '/v2/axb/$subid',
        options: Options(
          headers: {
            'appkey': PnmConfig.appKey,
            'ts': ts,
            'msgdgt': msgdgt,
          },
        ),
      );

      final code = response.data['code'] as int?;
      final success = code == 0;
      print('[PNM] Unbind result: code=$code, success=$success');
      
      return success;
    } on DioException catch (e) {
      print('[PNM] Unbind network error: ${e.message}');
      return false;
    } catch (e) {
      print('[PNM] Unbind error: $e');
      return false;
    }
  }

  /// Generate MD5 signature for header-only requests (like DELETE)
  String _generateMsgdgtHeaderOnly({required String ts}) {
    final Map<String, String> allParams = {
      'appkey': PnmConfig.appKey,
      'ts': ts,
    };

    final sortedKeys = allParams.keys.toList()..sort();

    final buffer = StringBuffer(PnmConfig.secretKey);
    for (final key in sortedKeys) {
      buffer.write(key);
      buffer.write(allParams[key]);
    }

    final plainText = buffer.toString();
    print('[PNM] Plain text for MD5 (unbind): $plainText');

    final bytes = utf8.encode(plainText);
    final digest = md5.convert(bytes);
    final result = digest.toString().toUpperCase();

    print('[PNM] Generated msgdgt (unbind): $result');
    return result;
  }

  /// Generate MD5 message digest (msgdgt)
  /// 
  /// Algorithm:
  /// 1. Sort all keys alphabetically (header + body + extracted extra fields)
  /// 2. Concatenate: secretKey + key1 + value1 + key2 + value2 + ...
  /// 3. Generate uppercase MD5 hash
  String _generateMsgdgt({
    required String ts,
    required Map<String, dynamic> body,
    required Map<String, String> extraParams,
  }) {
    // Collect all key-value pairs
    final Map<String, String> allParams = {};

    // Add header params
    allParams['appkey'] = PnmConfig.appKey;
    allParams['ts'] = ts;

    // Add body params (except 'extra')
    body.forEach((key, value) {
      if (key != 'extra' && value != null) {
        allParams[key] = value.toString();
      }
    });

    // Add extracted extra params
    extraParams.forEach((key, value) {
      allParams[key] = value;
    });

    // Sort by key alphabetically
    final sortedKeys = allParams.keys.toList()..sort();

    // Build plain text: secretKey + key1 + value1 + key2 + value2 + ...
    final buffer = StringBuffer(PnmConfig.secretKey);
    for (final key in sortedKeys) {
      buffer.write(key);
      buffer.write(allParams[key]);
    }

    final plainText = buffer.toString();
    
    // Debug logging
    print('[PNM] Plain text for MD5: $plainText');

    // Generate MD5 and convert to uppercase
    final bytes = utf8.encode(plainText);
    final digest = md5.convert(bytes);
    final result = digest.toString().toUpperCase();
    
    print('[PNM] Generated msgdgt: $result');
    
    return result;
  }

  /// Generate timestamp in Beijing time format: yyyyMMddHHmmssSSS
  String _generateTimestamp() {
    // Beijing is UTC+8
    final now = DateTime.now().toUtc().add(const Duration(hours: 8));
    
    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final second = now.second.toString().padLeft(2, '0');
    final millisecond = now.millisecond.toString().padLeft(3, '0');

    return '$year$month$day$hour$minute$second$millisecond';
  }

  /// Generate unique request ID
  String _generateRequestId() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final random = now.hashCode.toRadixString(16).toUpperCase();
    return '${now}$random';
  }
}
