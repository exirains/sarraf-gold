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


  static String getName(String code){

    return names[code] ?? code;

  }

}