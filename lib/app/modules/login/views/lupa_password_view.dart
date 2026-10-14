import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LupaPasswordView extends StatefulWidget {
  const LupaPasswordView({super.key});

  @override
  State<LupaPasswordView> createState() => _LupaPasswordViewState();
}

class _LupaPasswordViewState extends State<LupaPasswordView> {
  final TextEditingController nisController = TextEditingController();
  final TextEditingController namaController = TextEditingController();

  final String adminPhoneNumber = "6285172331507"; // Nomor admin sekolah
  String? _nisError;
  String? _namaError;

  @override
  void dispose() {
    nisController.dispose();
    namaController.dispose();
    super.dispose();
  }

  // WIDGET KAPSUL INPUT PERSIS SEPERTI DI FORM LOGIN
  Widget _buildFieldBox({
    required IconData icon,
    required Widget child,
    bool hasError = false,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: hasError ? const Color(0xFFEF4444) : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          // Blok sekat lavender kiri persis seperti form login
          Container(
            width: 58,
            height: double.infinity,
            color: const Color(0xFFEDE9FE),
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: const Color(0xFF6366F1),
              size: 22,
            ),
          ),
          // Input field
          Expanded(child: child),
        ],
      ),
    );
  }

  void _kirimKeWhatsApp() async {
    String nis = nisController.text.trim();
    String nama = namaController.text.trim();

    setState(() {
      _nisError = nis.isEmpty ? "Harap masukkan NIS siswa" : null;
      _namaError = nama.isEmpty ? "Harap masukkan Nama Lengkap siswa" : null;
    });

    if (nis.isEmpty || nama.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Harap lengkapi NIS dan Nama Siswa terlebih dahulu",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    String message =
        "Halo Admin SMK Wisata Indonesia,\nSaya ingin mengajukan reset password akun SIAWI saya.\n\n• NIS: $nis\n• Nama Lengkap: $nama\n\nMohon bantuannya untuk reset password. Terima kasih.";

    final Uri url = Uri.parse(
      "https://wa.me/$adminPhoneNumber?text=${Uri.encodeFull(message)}",
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Gagal membuka aplikasi WhatsApp"),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // 1. LATAR BELAKANG ELEGAN GRADASI ATAS (PERSIS FORM LOGIN)
          Container(
            height: size.height * 0.40,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF4C3EC7),
                  Color(0xFF6B5DE8),
                  Color(0xFF7E72EE),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
            ),
            child: Stack(
              children: [
                // Lingkaran ornamen aksen 1
                Positioned(
                  top: -40,
                  right: -30,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ),
                // Lingkaran ornamen aksen 2
                Positioned(
                  bottom: 40,
                  left: -50,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. KONTEN FORM LUPA KATA SANDI
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                children: [
                  // TOMBOL BACK ELEGAN DI KIRI ATAS
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Material(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => Navigator.of(context).maybePop(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: 15,
                              ),
                              SizedBox(width: 6),
                              Text(
                                "Kembali",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // LOGO & IDENTITAS SEKOLAH
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/logo/logo-splash.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          "SIAWI",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          "SMK WISATA INDONESIA",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withValues(alpha: 0.9),
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            "Bantuan Reset Kata Sandi",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  // CARD UTAMA FORM (PERSIS FORM LOGIN)
                  Container(
                    padding: const EdgeInsets.fromLTRB(22, 26, 22, 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF5B4BD1).withValues(alpha: 0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Lupa Kata Sandi",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "Masukkan data siswa untuk mengajukan reset kata sandi ke admin",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // FIELD 1: NIS
                        const Text(
                          "Nomor Induk Siswa (NIS)",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildFieldBox(
                          icon: Icons.badge_outlined,
                          hasError: _nisError != null,
                          child: TextField(
                            controller: nisController,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F172A),
                            ),
                            decoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 16,
                              ),
                              hintText: "Contoh: 243223",
                              hintStyle: TextStyle(
                                fontSize: 13.5,
                                color: Color(0xFF94A3B8),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                        if (_nisError != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 14, top: 5),
                            child: Text(
                              _nisError!,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFFEF4444),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                        const SizedBox(height: 18),

                        // FIELD 2: NAMA SISWA
                        const Text(
                          "Nama Lengkap Siswa",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildFieldBox(
                          icon: Icons.person_outline_rounded,
                          hasError: _namaError != null,
                          child: TextField(
                            controller: namaController,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _kirimKeWhatsApp(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F172A),
                            ),
                            decoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 16,
                              ),
                              hintText: "Contoh: Nabil Rozikin Maulana",
                              hintStyle: TextStyle(
                                fontSize: 13.5,
                                color: Color(0xFF94A3B8),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                        if (_namaError != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 14, top: 5),
                            child: Text(
                              _namaError!,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFFEF4444),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                        const SizedBox(height: 24),

                        // TOMBOL KIRIM DENGAN GRADASI (PERSIS GAYA FORM LOGIN)
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _kirimKeWhatsApp,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 4,
                              shadowColor:
                                  const Color(0xFF5B4BD1).withValues(alpha: 0.35),
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF4C3EC7),
                                    Color(0xFF6B5DE8),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Container(
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.chat_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "HUBUNGI ADMIN VIA WHATSAPP",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // INFO HINT PETUNJUK (PERSIS SEPERTI DI FORM LOGIN)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.info_outline_rounded,
                                size: 16,
                                color: Color(0xFF64748B),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: RichText(
                                  text: const TextSpan(
                                    style: TextStyle(
                                      fontSize: 11.2,
                                      color: Color(0xFF64748B),
                                      height: 1.35,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: "Catatan: ",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF334155),
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            "Pesan konfirmasi reset akan otomatis terformat rapi dan diteruskan ke Helpdesk resmi SMK Wisata Indonesia.",
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // TOMBOL KEMBALI KE LOGIN & FOOTER (PERSIS GAYA FORM LOGIN)
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      size: 18,
                      color: Color(0xFF475569),
                    ),
                    label: const Text(
                      "Kembali ke Halaman Login",
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF475569),
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(
                          color: Color(0xFFE2E8F0),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),
                  const Text(
                    "© 2024 SMK Wisata Indonesia Jakarta",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
