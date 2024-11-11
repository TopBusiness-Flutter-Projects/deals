import 'dart:typed_data';
import 'dart:io'; // لإضافة التعامل مع الملفات
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:top_sale/core/preferences/preferences.dart';
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

  Future<void> fetchPdfWithSession() async {
  String? sessionId = await Preferences.instance.getSessionId();
  String odooUrl = await Preferences.instance.getOdooUrl() ?? AppStrings.demoBaseUrl;
  String cookie = 'session_id=$sessionId';

  try {
    final dio = Dio();
    final response = await dio.get(
      odooUrl + widget.baseUrl,
      options: Options(
        headers: {
          'Cookie': cookie, // Pass the session cookie
        },
        responseType: ResponseType.bytes, // Ensure response is in bytes for PDF
      ),
    );

    if (response.statusCode == 200) {
      setState(() {
        pdfBytes = response.data;
        isLoading = false;
      });
    } else {
      print('Failed to load PDF');
    }
  } catch (e) {
    print('Error fetching PDF: $e');
  }
}

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
          ? Center(child: CircularProgressIndicator())
          : SfPdfViewer.memory(pdfBytes),
    );
  }
}
