import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

// --- FIX: Ensure main calls MaterialApp directly ---
void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false, // Remove the "Debug" banner
    home: OcrScannerScreen()
  ));
}

class OcrScannerScreen extends StatefulWidget {
  const OcrScannerScreen({super.key});

  @override
  State<OcrScannerScreen> createState() => _OcrScannerScreenState();
}

class _OcrScannerScreenState extends State<OcrScannerScreen> {
  // --- UI State Variables ---
  File? _imageFile;
  
  // 1. Status Title
  String _resultTitle = "Bereit zum Scannen"; 
  // 2. Detailed Message
  String _resultBody = "Bitte fotografieren Sie die Zutatenliste.";
  // 3. Debug Info
  String _debugText = "";
  // 4. Color State
  Color _statusColor = Colors.grey;

  // --- Core Function ---
  Future<void> _scanImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);
      
      if (photo == null) return; 

      setState(() {
        _resultTitle = "⏳ Analyse läuft...";
        _resultBody = "Bitte warten...";
        _statusColor = Colors.blue; 
        _imageFile = File(photo.path);
        _debugText = "";
      });

      // OCR Processing
      final inputImage = InputImage.fromFilePath(photo.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      
      String rawText = recognizedText.text.toLowerCase(); 

      // --- V3.0 UPGRADE: Regex Logic (Robustness) ---
      // Instead of simple strings, we use Regex to handle spaces like "E 450"
      final Map<String, RegExp> dangerPatterns = {
        "PHOSPHAT": RegExp(r"phospha[t|d]", caseSensitive: false), // Matches Phosphat/Phosphad
        "E450 (Diphosphat)": RegExp(r"e\s*450", caseSensitive: false), // Matches E450, E 450, E-450
        "E338": RegExp(r"e\s*338", caseSensitive: false),
        "E339": RegExp(r"e\s*339", caseSensitive: false),
        "E340": RegExp(r"e\s*340", caseSensitive: false),
        "E341": RegExp(r"e\s*341", caseSensitive: false),
        "E451": RegExp(r"e\s*451", caseSensitive: false),
        "E452": RegExp(r"e\s*452", caseSensitive: false),
        "KALIUM": RegExp(r"kalium", caseSensitive: false),
        "GESCHMACKSVERSTÄRKER": RegExp(r"geschmacksverstärker", caseSensitive: false),
        "NATRIUMNITRIT": RegExp(r"natriumnitrit", caseSensitive: false),
      };

      List<String> foundDangers = [];

      // Iterate through Regex patterns
      dangerPatterns.forEach((name, pattern) {
        if (pattern.hasMatch(rawText)) {
          foundDangers.add(name);
        }
      });
      
      // --- Result Logic ---
      
      if (foundDangers.isNotEmpty) {
        //  RED: DANGER
        setState(() {
          _statusColor = Colors.red;
          _resultTitle = "ACHTUNG: KRITISCH";
          _resultBody = "Gefundene Risikostoffe:\n ${foundDangers.join(", ")}\n\nNicht geeignet für Nierenpatienten!";
        });
      } else if (rawText.length < 10) {
        //  ORANGE: UNCERTAIN
        setState(() {
          _statusColor = Colors.orange;
          _resultTitle = "Scan unsicher";
          _resultBody = "Zu wenig Text erkannt. Bitte Bild schärfer aufnehmen.";
        });
      } else {
        //  GREEN: SAFE
        setState(() {
          _statusColor = Colors.green;
          _resultTitle = "Unbedenklich";
          _resultBody = "Keine kritischen Phosphate oder Kaliumzusätze erkannt.\n(Scheinbar sicher)";
        });
      }

      setState(() {
        _debugText = "[RAW DATA]:\n$rawText";
      });

      textRecognizer.close();

    } catch (e) {
      setState(() {
        _statusColor = Colors.grey;
        _resultTitle = "Fehler";
        _resultBody = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mobile OCR Tool (Prototyp)"), 
        backgroundColor: Colors.teal, 
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Image Preview
            if (_imageFile != null)
              Image.file(_imageFile!, height: 250, width: double.infinity, fit: BoxFit.cover)
            else
              Container(
                height: 250,
                width: double.infinity,
                color: Colors.grey[200],
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                      SizedBox(height: 10),
                      Text("Bitte Zutatenliste scannen", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 20),
            
            // 2. THE DIAGNOSIS CARD
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
                    const SizedBox(height: 10),
                    Text(
                      _resultTitle,
                      style: TextStyle(
                        fontSize: 22, 
                        fontWeight: FontWeight.bold,
                        color: _statusColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _resultBody,
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 3. Debug Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ExpansionTile(
                title: const Text("Entwickler-Protokoll (Raw Data)", style: TextStyle(fontSize: 12, color: Colors.grey)),
                children: [
                  Text(_debugText, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
            
            const SizedBox(height: 50),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _scanImage,
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.camera_alt),
        label: const Text("Scannen"),
      ),
    );
  }
}