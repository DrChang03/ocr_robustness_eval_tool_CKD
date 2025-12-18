// lib/services/supabase_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart'; //debugPrint

class SupabaseService {
  // --- Singleton Pattern ---
  // Ensures only one instance of SupabaseService exists
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final _client = Supabase.instance.client;

  //
  Future<void> uploadScanLog(String rawText, String detectedKeywords) async {
    try {
      await _client.from('field_test_data').insert({
        'ocr_raw_text': rawText,
        'detected_keywords': detectedKeywords,
        'material_type': 'Unknown (App Scan)',
        'product_name': 'Scan at ${DateTime.now().hour}:${DateTime.now().minute}',
        // 'manual_verification': null // Data cleaning later HitL process
      });
      debugPrint(" [SupabaseService] Data uploaded to Frankfurt!");
    } catch (e) {
      debugPrint(" [SupabaseService] Upload failed: $e");
    }
  }
}