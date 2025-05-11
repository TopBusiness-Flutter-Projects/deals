import 'dart:convert';
import 'dart:typed_data';
import 'dart:io'; // لإضافة التعامل مع الملفات
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:top_sale/core/preferences/preferences.dart';
import 'package:top_sale/core/utils/circle_progress.dart';

import 'package:top_sale/core/utils/app_strings.dart';
import 'package:share_plus/share_plus.dart'; // استيراد مكتبة المشاركة
import 'package:path_provider/path_provider.dart'; // للتعامل مع الملفات المؤقتة

class PdfViewerPage extends StatefulWidget {
  const PdfViewerPage({super.key, required this.baseUrl});
  final String baseUrl;

  @override
  _PdfViewerPageState createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  late Uint8List pdfBytes;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPdfWithSession();
  }

  // Function to convert hex string to bytes
  Uint8List hexToBytes(String hex) {
    final bytes = <int>[];
    for (int i = 0; i < hex.length; i += 2) {
      bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    return Uint8List.fromList(bytes);
  }

Future<void> fetchPdfWithSession() async {
  // String? sessionId = await Preferences.instance.getSessionId();
  String? sessionId =
      "e511dafb2f7d05fc6e15501bdb1ba3ebebc641be"; // Replace with actual session ID retrieval
  String odooUrl =
      await Preferences.instance.getOdooUrl() ?? AppStrings.demoBaseUrl;
  String cookie = 'frontend_lang=ar_001;session_id=$sessionId';

  try {
    final dio = Dio();
    final response = await dio.get(
      odooUrl + widget.baseUrl,
      options: Options(
        headers: {
          'Cookie': cookie, // Pass the session cookie
        },
        responseType: ResponseType.plain, // Change to plain to handle hex string
      ),
    );

    print('Fetching PDF from: ${odooUrl + widget.baseUrl}');

    if (response.statusCode == 200) {
      String responseData = response.data;

      // Check if the response is HTML
      if (responseData.contains('<html>')) {
        print('Received HTML response instead of PDF: $responseData');
        setState(() {
          isLoading = false; // Stop loading if the response is HTML
        });
        return;
      }

      // Convert the hex string to bytes
      if (isHexString(responseData)) {
        pdfBytes = hexToBytes(responseData);
        setState(() {
          isLoading = false;
        });
      } else {
        print('Invalid hex string received: $responseData');
        setState(() {
          isLoading = false; // Stop loading if the format is invalid
        });
      }
    } else {
      print('Failed to load PDF: ${response.statusCode}');
      print('Response body: ${response.data}'); // Log the response body
      setState(() {
        isLoading = false; // Stop loading if there's an error
      });
    }
  } catch (e) {
    print('Error fetching PDF: $e');
    setState(() {
      isLoading = false; // Stop loading if there's an error
    });
  }
}

// Function to check if a string is a valid hex string
bool isHexString(String hex) {
  final hexPattern = RegExp(r'^[0-9a-fA-F]+$');
  return hexPattern.hasMatch(hex);
}

// // Function to convert hex string to bytes
// Uint8List hexToBytes(String hex) {
//   final bytes = <int>[];
//   for (int i = 0; i < hex.length; i += 2) {
//     bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
//   }
//   return Uint8List.fromList(bytes);
// }
  // Future<void> fetchPdfWithSession() async {
  //   // String? sessionId = await Preferences.instance.getSessionId();
  //   String? sessionId = "e511dafb2f7d05fc6e15501bdb1ba3ebebc641be";
  //   String odooUrl =
  //       await Preferences.instance.getOdooUrl() ?? AppStrings.demoBaseUrl;
  //   String cookie = 'frontend_lang=ar_001;session_id=$sessionId';

  //   try {
  //     final dio = Dio();
  //     final response = await dio.get(
  //       odooUrl + widget.baseUrl,
  //       options: Options(
  //         headers: {
  //           'Cookie': cookie, // Pass the session cookie
  //           // 'Accept': '*/*',
  //           // 'Accept-Encoding': 'gzip, deflate, br'
  //         },
  //         responseType:
  //             ResponseType.bytes, // Ensure response is in bytes for PDF
  //       ),
  //     );
  //     print(
  //       odooUrl + widget.baseUrl,
  //     );
  //     print(response.data.toString());
  //     if (response.statusCode == 200) {
  //       setState(() {
  //         pdfBytes = response.data;
  //         isLoading = false;
  //       });
  //     } else {
  //       print('Failed to load PDF');
  //     }
  //   } catch (e) {
  //     print('Error fetching PDF: $e');
  //   }
  // }

  // وظيفة المشاركة
  void sharePdf() async {
    final tempDir = await getTemporaryDirectory(); // الحصول على المسار المؤقت
    final file = File('${tempDir.path}/document.pdf');
    await file.writeAsBytes(pdfBytes); // كتابة ملف PDF مؤقت

    // تحويل المسار إلى XFile
    final xFile = XFile(file.path);

    // مشاركة الملف باستخدام share_plus
    await Share.shareXFiles([xFile], text: 'Check out this PDF document!');
  }

  void printPdf() async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
        actions: [
          IconButton(
            icon: Icon(Icons.print),
            onPressed: isLoading ? null : printPdf, // تعطيل الزر أثناء التحميل
          ),
          SizedBox(width: 5),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: isLoading ? null : sharePdf, // مشاركة PDF
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CustomLoadingIndicator())
          : SfPdfViewer.memory(pdfBytes),
    );
  }
}
