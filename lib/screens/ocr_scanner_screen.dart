// lib/screens/home_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../utils/ingredient_analyzer.dart';
import '../services/supabase_service.dart';

// --- OCR Scanner Screen ---
class OcrScannerScreen extends StatefulWidget {
  const OcrScannerScreen({super.key});

  @override
  State<OcrScannerScreen> createState() => _OcrScannerScreenState();
}

// --- OCR Scanner State ---
class _OcrScannerScreenState extends State<OcrScannerScreen> {
  File? _imageFile;
  String _resultTitle = "Bereit zum Scannen"; 
  String _resultBody = "Bitte fotografieren Sie die Zutatenliste.";
  String _debugText = "";
  Color _statusColor = Colors.grey;

// --- Image Scanning & Analysis ---
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

      
      List<String> foundDangers = IngredientAnalyzer.analyze(rawText);
      
      // --- UI Logic ---
      // Update UI based on analysis results
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
await SupabaseService().uploadScanLog(rawText, foundDangers.join(", "));
      textRecognizer.close();

    } catch (e) {
      setState(() {
        _statusColor = Colors.grey;
        _resultTitle = "Fehler";
        _resultBody = e.toString();
      });
    }
  }

  // --- UI BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("MedicalSnap Cloud v1.2"), backgroundColor: Colors.teal),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_imageFile != null) 
              Image.file(_imageFile!, height: 250, width: double.infinity, fit: BoxFit.cover,
                errorBuilder: (c,e,s) => Container(height: 250, color: Colors.grey, child: const Icon(Icons.broken_image))),
            
            const SizedBox(height: 20),
            // --- Result Display ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.1),
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