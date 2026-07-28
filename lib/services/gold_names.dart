import 'package:flutter/material.dart';
import 'localization_service.dart';

class GoldNames {
  static const Map<String, String> names = {
    "GA": "Gram Altın",
    "C": "Çeyrek Altın",
    "Y": "Yarım Altın",
    "T": "Tam Altın",
    "CMR": "Cumhuriyet Altını",
    "ATA": "Ata Altın",
    "GAG": "Gram Gümüş",
    "XAUUSD": "Ons Altın",
    "XHGLD": "Has Altın",
    "14": "14 Ayar Altın",
    "18": "18 Ayar Altın",
    "22": "22 Ayar Bilezik",
    "IKB": "İkibuçuk Altın",
    "BSL": "Beşli Altın",
    "GR": "Gremse Altın",
    "RA": "Reşat Altın",
    "HA": "Hamit Altın",
    "XAUXAG": "Altın/Gümüş Rasyosu",
  };

  static String getName(BuildContext context, String code) {
    return LocalizationService.translate(context, 'code_$code');
  }

  static String getCategory(String code) {
    if (code == "14" || code == "18" || code == "22") return "karat";
    if (code == "BSL") return "stack_5";
    if (code == "IKB") return "stack_2_5";
    if (code == "GAG") return "silver";
    if (code == "XAUXAG") return "ratio";
    if (code == "C" || code == "Y" || code == "T" || code == "CMR" || code == "ATA" || code == "GR" || code == "RA" || code == "HA") return "coin";
    return "pure_gold";
  }

  static String getIcon(String code) {
    if (code == "GAG") return "🥈"; // Silver
    return "🟡"; // Gold
  }
}
