import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siawi_app/app/data/api_service.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TagihanView extends StatefulWidget {
  final VoidCallback signOut;
  const TagihanView(this.signOut, {super.key});

  @override
  State<TagihanView> createState() => _TagihanViewState();
}

class _TagihanViewState extends State<TagihanView> {
  WebViewController? _controller;
  String? nis;
  String? _namaSiswa;
  String? _kelasSiswa;
  bool isLoading = true; // Track loading state
  String? linkTagihan;

  Future<void> _loadStudentData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? nisVal = preferences.getString('nis');
    String? idSiswa = preferences.getString('idSiswa');
    String? namaVal;
    String? kelasVal;

    if (idSiswa != null) {
      String? cached = preferences.getString('cached_student_header_$idSiswa');
      if (cached != null) {
        try {
          final data = json.decode(cached);
          namaVal = data['nama_siswa']?.toString() ?? data['namaSiswa']?.toString();
          kelasVal = data['kelas']?['nama_kelas']?.toString() ?? data['nama_kelas']?.toString();
        } catch (_) {}
      }
    }

    if (mounted) {
      setState(() {
        nis = nisVal;
        _namaSiswa = namaVal;
        _kelasSiswa = kelasVal;
      });
    }
  }

  Future<void> _fetchTagihan() async {
    try {
      final tagihan = await ApiService.get('/tagihan');
      if (tagihan != null && tagihan['data'] != null) {
        var tagihanData = tagihan['data'];
        if (mounted) {
          setState(() {
            linkTagihan = tagihanData['link'].toString();
          });
        }
      }
    } catch (e) {
      debugPrint('Failed to load tagihan: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
    await _loadStudentData();
    await _fetchTagihan();

    if (nis != null && linkTagihan != null) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {},
            onPageStarted: (String url) {
              if (mounted) {
                setState(() {
                  isLoading = true;
                });
              }
            },
            onPageFinished: (String url) {
              if (mounted) {
                setState(() {
                  isLoading = false;
                });
              }
            },
            onWebResourceError: (WebResourceError error) {},
            onNavigationRequest: (NavigationRequest request) {
              if (request.url.startsWith('https://www.youtube.com/')) {
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(Uri.parse('$linkTagihan$nis'));
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF4C3EC7),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tagihan Pembayaran',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: -0.2,
              ),
            ),
            Text(
              _namaSiswa != null
                  ? '$_namaSiswa${_kelasSiswa != null ? ' • $_kelasSiswa' : (nis != null ? ' • NIS: $nis' : '')}'
                  : (nis != null
                      ? 'NIS: $nis • Portal SPP & Keuangan'
                      : 'Portal SPP & Pembayaran Siswa'),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 22),
            tooltip: 'Segarkan Halaman',
            onPressed: () {
              if (_controller != null) {
                _controller!.reload();
              } else {
                _initController();
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: Image.asset(
                'assets/logo/logo-splash.png',
                width: 28,
                height: 28,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_controller != null)
            WebViewWidget(controller: _controller!)
          else
            const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF4C3EC7),
                strokeWidth: 2.8,
              ),
            ),
          if (isLoading)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                color: Color(0xFF6366F1),
                backgroundColor: Color(0xFFEDE9FE),
                minHeight: 3,
              ),
            ),
        ],
      ),
    );
  }
}
