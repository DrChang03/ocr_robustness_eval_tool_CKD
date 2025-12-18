import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/ocr_scanner_screen.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://noytsdkyxxhhtbhfedva.supabase.co', 
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5veXRzZGt5eHhoaHRiaGZlZHZhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU0Nzc3MzYsImV4cCI6MjA4MTA1MzczNn0.PmEQhLVBcKA_xKMGC1vqpJe_rG1BMXIQsY4jQ8ASsEY', 
  );

   runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'MedicalSnap',
    home: OcrScannerScreen(), // 启动 UI
  ));
}
