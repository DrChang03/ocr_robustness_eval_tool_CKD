import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

void main() {
  runApp(const MyApp());
}

// 这里就是之前报错找不到的 MyApp，我现在把它加回来了
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // 去掉右上角的 debug 标签
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      home: const OcrScannerScreen(),
    );
  }
}

class OcrScannerScreen extends StatefulWidget {
  const OcrScannerScreen({super.key});

  @override
  State<OcrScannerScreen> createState() => _OcrScannerScreenState();
}

class _OcrScannerScreenState extends State<OcrScannerScreen> {
  String _extractedText = "点击下方相机按钮开始扫描...";
  File? _imageFile;

  Future<void> _scanImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);
      
      if (photo == null) return;

      setState(() {
        _extractedText = "正在 AI 识别中...";
        _imageFile = File(photo.path);
      });

      final inputImage = InputImage.fromFilePath(photo.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

      String rawText = recognizedText.text;
      
      // --- 简单的关键词检测逻辑 ---
      String statusMessage = "";
      // 只要包含这些词，就报警 (这里不区分大小写)
      if (rawText.toLowerCase().contains("phosphat") || 
          rawText.toLowerCase().contains("phosphoric")) {
        statusMessage = "\n\n⚠️ 警告：检测到磷添加剂！\n(High Phosphate Detected)";
      } else if (rawText.isNotEmpty) {
        statusMessage = "\n\n✅ 初步检测安全\n(Safe based on OCR)";
      }
      // -----------------------

      setState(() {
        _extractedText = "识别结果:\n$rawText$statusMessage";
      });

      textRecognizer.close();

    } catch (e) {
      setState(() {
        _extractedText = "出错了: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("OCR 评估工具 (Demo)"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_imageFile != null)
              Image.file(_imageFile!, height: 300, width: double.infinity, fit: BoxFit.cover)
            else
              Container(
                height: 300,
                width: double.infinity,
                color: Colors.grey[200],
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_search, size: 50, color: Colors.grey),
                    SizedBox(height: 10),
                    Text("请拍摄配料表"),
                  ],
                ),
              ),
            
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  _extractedText,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _scanImage,
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.camera_alt, color: Colors.white),
        label: const Text("扫描配料表", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}