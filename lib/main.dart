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
  String _extractedText = "点击下方按钮开始扫描...";
  File? _imageFile;

  // --- 核心功能：拍照并智能分析 ---
  Future<void> _scanImage() async {
    try {
      // 1. 打开相机
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);
      
      if (photo == null) return; 

      setState(() {
        _extractedText = "🤖 AI 正在分析配料表...";
        _imageFile = File(photo.path);
      });

      // 2. 准备图片
      final inputImage = InputImage.fromFilePath(photo.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      
      // 3. 识别文字
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      String rawText = recognizedText.text.toLowerCase(); // 转小写

      // --- 4. 智能过滤算法 (Project LifeGuard V2) ---
      
      // 定义高危关键词库 (CKD 肾病黑名单)
      final List<String> dangerKeywords = [
        "phosphat", // 磷酸盐 (通用)
        "diphosphat", "triphosphat", "polyphosphat", // 多聚磷酸盐
        "e338", "e339", "e340", "e341", // 磷酸类 E代码
        "e450", "e451", "e452",         // 聚磷酸盐 (高危!)
        "kalium", "potassium",          // 钾
        "natriumnitrit",                // 亚硝酸钠 (常见于火腿)
        "geschmacksverstärker"          // 增味剂
      ];

      List<String> foundDangers = [];

      // 扫描每一个关键词
      for (var keyword in dangerKeywords) {
        if (rawText.contains(keyword)) {
          // 如果找到了，加入警告名单
          foundDangers.add(keyword.toUpperCase());
        }
      }
      
      String statusMessage = "";
      
      if (foundDangers.isNotEmpty) {
        // 🔴 发现危险
        statusMessage = "\n\n🚨 严重警告 (WARNUNG) 🚨\n\n检测到高危成分:\n👉 ${foundDangers.join(", ")}\n\n建议：CKD患者请避免食用！";
      } else if (rawText.length < 5) {
        // ⚪ 没拍到文字
        statusMessage = "\n\n🤔 未识别到有效文字，请对准配料表重试。";
      } else {
        // 🟢 看起来安全
        statusMessage = "\n\n✅ 看起来安全 (SICHER)\n\n未检测到明显的磷/钾添加剂。\n(结果仅供参考)";
      }

      // 调试信息 (正式发布时可删掉)
      String debugInfo = "\n\n-------------------\n[原始数据]:\n$rawText";

      setState(() {
        _extractedText = statusMessage + debugInfo;
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
        title: const Text("MedicalSnap (Prototype)"),
        backgroundColor: Colors.teal, // 医疗风格配色
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_imageFile != null)
              Image.file(_imageFile!, height: 300, fit: BoxFit.cover)
            else
              Container(
                height: 300,
                color: Colors.grey[200],
                child: const Center(
                  child: Text("请拍摄食品背面的【配料表】", 
                    style: TextStyle(color: Colors.grey)),
                ),
              ),
            
            const SizedBox(height: 20),
            
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _scanImage,
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.camera_alt),
        label: const Text("扫描配料表"),
      ),
    );
  }
}