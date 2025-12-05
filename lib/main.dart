import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

void main() {
  runApp(const MaterialApp(home: OcrScannerScreen()));
}

class OcrScannerScreen extends StatefulWidget {
  const OcrScannerScreen({super.key});

  @override
  State<OcrScannerScreen> createState() => _OcrScannerScreenState();
}

class _OcrScannerScreenState extends State<OcrScannerScreen> {
  // Initial UI state (German for local user context)
  String _extractedText = "Bitte scannen Sie die Zutatenliste..."; 
  File? _imageFile;

  // --- Core Function: Image Capture & Intelligent Analysis ---
  Future<void> _scanImage() async {
    try {
      // 1. Initialize Camera
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);
      
      if (photo == null) return; // User cancelled

      setState(() {
        _extractedText = " Analyse läuft..."; // "Analysis running..."
        _imageFile = File(photo.path);
      });

      // 2. Prepare Input Image for ML Kit
      final inputImage = InputImage.fromFilePath(photo.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      
      // 3. Perform OCR (On-Device)
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      
      // Convert to lowercase for case-insensitive matching
      String rawText = recognizedText.text.toLowerCase(); 

      // --- 4. Filtering Algorithm (Project LifeGuard Logic) ---
      // Detection of CKD-relevant keywords in German context
      final List<String> dangerKeywords = [
        // Phosphates
        "phosphat",       // Generic root
        "diphosphat",     // E450
        "triphosphat",    // E451
        "polyphosphat",   // E452
        "phosphorsäure",  // Phosphoric acid
        
        // E-Numbers (Critical for German market)
        "e338", "e339", "e340", "e341", 
        "e450", "e451", "e452",
        
        // Potassium (Kalium)
        "kalium", 
        "kaliumchlorid",  
        "kaliumcitrat",
        
        // Others
        "geschmacksverstärker", // Flavor enhancers (often contain phosphate)
        "natriumnitrit"         // Sodium nitrite
      ];

      List<String> foundDangers = [];

      // Iterate through keywords
      for (var keyword in dangerKeywords) {
        if (rawText.contains(keyword)) {
          foundDangers.add(keyword.toUpperCase());
        }
      }
      
      String statusMessage = "";
      
      if (foundDangers.isNotEmpty) {
        // CRITICAL WARNING (UI: German)
        statusMessage = 
          "\n\n ACHTUNG: KRITISCHE INHALTSSTOFFE \n" 
          "\nGefundene Risikostoffe:\n"                 
          " ${foundDangers.join(", ")}\n"             
          "\n Empfehlung: Für Nierenpatienten nicht geeignet."; 
      } else if (rawText.length < 5) {
        //  ERROR: No text detected
        statusMessage = "\n\n Fehler: Kein Text erkannt.\nBitte versuchen Sie es erneut.";
      } else {
        //  SAFE: No keywords found
        statusMessage = 
          "\n\n Unbedenklich (Scheinbar sicher)\n" 
          "\nKeine kritischen Phosphate oder Kaliumzusätze erkannt.\n"
          "(Hinweis: Diese Analyse ersetzt keinen ärztlichen Rat.)"; 
      }

      // Debug Info (Hidden in production, visible for Thesis evaluation)
      String debugInfo = "\n\n-------------------\n[RAW OCR DATA]:\n$rawText";

      setState(() {
        _extractedText = statusMessage + debugInfo;
      });

      textRecognizer.close();

    } catch (e) {
      setState(() {
        _extractedText = "Ein Fehler ist aufgetreten: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MedicalSnap (Prototyp)"), 
        backgroundColor: Colors.teal, 
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image Preview Area
            if (_imageFile != null)
              Image.file(_imageFile!, height: 300, fit: BoxFit.cover)
            else
              Container(
                height: 300,
                color: Colors.grey[200],
                child: const Center(
                  child: Text("Bitte Zutatenliste scannen", 
                    style: TextStyle(color: Colors.grey, fontSize: 18)),
                ),
              ),
            
            const SizedBox(height: 20),
            
            // Result Text Area
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _extractedText,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      // Scan Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _scanImage,
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.camera_alt),
        label: const Text("Scannen"),
      ),
    );
  }
}