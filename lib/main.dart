import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
// Supabase initialization
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://noytsdkyxxhhtbhfedva.supabase.co', 
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5veXRzZGt5eHhoaHRiaGZlZHZhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU0Nzc3MzYsImV4cCI6MjA4MTA1MzczNn0.PmEQhLVBcKA_xKMGC1vqpJe_rG1BMXIQsY4jQ8ASsEY', 
  );

  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: OcrScannerScreen()
  ));
}

class OcrScannerScreen extends StatefulWidget {
  const OcrScannerScreen({super.key});

  @override
  State<OcrScannerScreen> createState() => _OcrScannerScreenState();
}

class _OcrScannerScreenState extends State<OcrScannerScreen> {
  File? _imageFile;
  String _resultTitle = "Bereit zum Scannen"; 
  String _resultBody = "Bitte fotografieren Sie die Zutatenliste.";
  String _debugText = "";
  Color _statusColor = Colors.grey;

  //Get Supabase client instance
  final _supabase = Supabase.instance.client;

  Future<void> _scanImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);
      
      if (photo == null) return; 

      setState(() {
        _resultTitle = "Analyse läuft...";
        _resultBody = "Bitte warten... Uploading to Frankfurt...";
        _statusColor = Colors.blue; 
        _imageFile = File(photo.path);
        _debugText = ""; 
      });

      final inputImage = InputImage.fromFilePath(photo.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      
      String rawText = recognizedText.text.toLowerCase(); 

      // --- V3.1 Regex Logic (Rewe Tested) ---
      final Map<String, RegExp> dangerPatterns = {
        "PHOSPHAT/SÄURE": RegExp(r"phosph[a|o]", caseSensitive: false), 
        "E450 (Diphosphat)": RegExp(r"e[\s:-]*450", caseSensitive: false), 
        "E338": RegExp(r"e[\s:-]*338", caseSensitive: false),
        "E339": RegExp(r"e[\s:-]*339", caseSensitive: false),
        "E340": RegExp(r"e[\s:-]*340", caseSensitive: false),
        "E341": RegExp(r"e[\s:-]*341", caseSensitive: false),
        "E451": RegExp(r"e[\s:-]*451", caseSensitive: false),
        "E452": RegExp(r"e[\s:-]*452", caseSensitive: false),
        "KALIUM": RegExp(r"k.lium", caseSensitive: false),
        "GESCHMACKSVERSTÄRKER": RegExp(r"geschmacksverstärker", caseSensitive: false),
        "NATRIUMNITRIT": RegExp(r"natriumnitrit", caseSensitive: false),
      };

      List<String> foundDangers = [];
      dangerPatterns.forEach((name, pattern) {
        if (pattern.hasMatch(rawText)) {
          foundDangers.add(name);
        }
      });
      
      // --- UI Logic ---
      if (foundDangers.isNotEmpty) {
        setState(() {
          _statusColor = Colors.red;
          _resultTitle = "ACHTUNG: KRITISCH";
          _resultBody = "Gefundene Risikostoffe:\n ${foundDangers.join(", ")}";
        });
      } else if (rawText.length < 10) {
        setState(() {
          _statusColor = Colors.orange;
          _resultTitle = "Scan unsicher";
          _resultBody = "Zu wenig Text erkannt.";
        });
      } else {
        setState(() {
          _statusColor = Colors.green;
          _resultTitle = "Unbedenklich";
          _resultBody = "Keine kritischen Stoffe erkannt.";
        });
      }

      setState(() {
        _debugText = "[RAW DATA]:\n$rawText";
      });

      // --- CLOUD UPLOAD (Data Collection) ---
      // This code quietly uploads what you scanned to Frankfurt
      await _uploadToSupabase(rawText, foundDangers.join(", "));

      textRecognizer.close();

    } catch (e) {
      setState(() {
        _statusColor = Colors.grey;
        _resultTitle = "Fehler";
        _resultBody = e.toString();
      });
    }
  }

  // Upload scanned data to Supabase
  Future<void> _uploadToSupabase(String rawText, String detected) async {
    try {
      await _supabase.from('field_test_data').insert({
        'ocr_raw_text': rawText,
        'detected_keywords': detected,
        'material_type': 'Unknown (App Scan)', 
        'product_name': 'Scan at ${DateTime.now().hour}:${DateTime.now().minute}',
      });
      debugPrint("Data uploaded to Supabase!");
    } catch (e) {
      debugPrint("Upload failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("MedicalSnap Cloud v1"), backgroundColor: Colors.teal),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_imageFile != null) 
              Image.file(_imageFile!, height: 250, width: double.infinity, fit: BoxFit.cover,
                errorBuilder: (c,e,s) => Container(height: 250, color: Colors.grey, child: const Icon(Icons.broken_image))),
            
            const SizedBox(height: 20),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.1), 
                  border: Border.all(color: _statusColor, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      _statusColor == Colors.red ? Icons.warning_amber_rounded : 
                      _statusColor == Colors.green ? Icons.check_circle_outline : Icons.help_outline,
                      size: 48,
                      color: _statusColor,
                    ),
                    Text(_resultTitle, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _statusColor)),
                    Text(_resultBody, textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
             Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ExpansionTile(
                title: const Text("Raw Data", style: TextStyle(fontSize: 12)),
                children: [Text(_debugText, style: const TextStyle(fontSize: 10))],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _scanImage,
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.cloud_upload),
        label: const Text("Scan & Upload"),
      ),
    );
  }
}