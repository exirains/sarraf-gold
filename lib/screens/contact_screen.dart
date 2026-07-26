import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/update_service.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  final String telegramUrl = "https://t.me/PoolMoneyExchange";
  final String phoneNumber = "+905000000000"; // Dummy number
  final String address = "Kapalıçarşı, İstanbul, Türkiye";
  final String googleMapsUrl = "https://maps.google.com/?q=Kapalıçarşı,İstanbul";

  Future<void> _launchUrl(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bağlantı açılamadı: $urlString')),
        );
      }
    }
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Panoya kopyalandı!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kurumsal"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            const Text(
              "Hizmetlerimiz",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildServices(),
            const SizedBox(height: 32),
            const Text(
              "İletişim Kanalları",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _ContactItem(
              icon: FontAwesomeIcons.telegram,
              title: "Telegram Grubu",
              subtitle: "Canlı sinyaller ve duyurular",
              onTap: () => _launchUrl(context, telegramUrl),
              iconColor: Colors.blue,
            ),
            _ContactItem(
              icon: FontAwesomeIcons.whatsapp,
              title: "WhatsApp",
              subtitle: "Hızlı destek hattı",
              onTap: () => _launchUrl(context, "https://wa.me/${phoneNumber.replaceAll('+', '')}"),
              iconColor: Colors.green,
            ),
            _ContactItem(
              icon: Icons.phone_rounded,
              title: "Telefon",
              subtitle: phoneNumber,
              onTap: () => _launchUrl(context, "tel:$phoneNumber"),
              onLongPress: () => _copyToClipboard(context, phoneNumber),
              iconColor: Colors.orange,
            ),
            _ContactItem(
              icon: Icons.location_on_rounded,
              title: "Adres",
              subtitle: address,
              onTap: () => _launchUrl(context, googleMapsUrl),
              iconColor: Colors.redAccent,
            ),
            const SizedBox(height: 40),
            Center(
              child: Column(
                children: [
                  const Text(
                    "Sarraf Gold © 2026",
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    "Versiyon ${UpdateService.localInfo?.version ?? '...'}",
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade700, Colors.amber.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Icon(Icons.account_balance_rounded, size: 40, color: Colors.amber),
          ),
          SizedBox(height: 16),
          Text(
            "Sarraf Gold",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            "Güvenilir Yatırımın Adresi",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildServices() {
    final services = [
      {"icon": Icons.compare_arrows_rounded, "label": "Döviz Takas"},
      {"icon": Icons.auto_graph_rounded, "label": "Altın Analiz"},
      {"icon": Icons.public_rounded, "label": "Global Kur"},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: services.map((s) => _buildServiceIcon(s["icon"] as IconData, s["label"] as String)).toList(),
    );
  }

  Widget _buildServiceIcon(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.amber.shade800),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _ContactItem extends StatelessWidget {
  final dynamic icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Color iconColor;

  const _ContactItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.onLongPress,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget iconWidget;
    if (icon is IconData) {
      iconWidget = Icon(icon, color: iconColor, size: 20);
    } else if (icon is FaIconData) {
      iconWidget = FaIcon(icon, color: iconColor, size: 20);
    } else {
      iconWidget = Icon(Icons.error, color: iconColor, size: 20);
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        onTap: onTap,
        onLongPress: onLongPress,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: iconWidget,
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      ),
    );
  }
}
