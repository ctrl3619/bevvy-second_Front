enum TastyType {
  SWEETNESS,
  STRONG_CARBONATION,
  CITRUS_SCENT,
  GRAIN_SCENT,
  BITTER,
  HIGH_ALCOHOL,
  COFFEE_SCENT,
  CHOCOLATE,
  FLOWER_SCENT,
  NUTS,
  SMOKEY,
  REFRESHING
}

extension TastyTypeExtension on TastyType {
  static const Map<TastyType, String> descriptions = {
    TastyType.SWEETNESS: "단맛",
    TastyType.STRONG_CARBONATION: "강한 탄산",
    TastyType.CITRUS_SCENT: "시트러스향",
    TastyType.GRAIN_SCENT: "곡물향",
    TastyType.BITTER: "쓴맛",
    TastyType.HIGH_ALCOHOL: "높은 알콜",
    TastyType.COFFEE_SCENT: "커피향",
    TastyType.CHOCOLATE: "초콜릿",
    TastyType.FLOWER_SCENT: "꽃향",
    TastyType.NUTS: "견과류",
    TastyType.SMOKEY: "스모키",
    TastyType.REFRESHING: "청량함",
  };

  static Map<TastyType, String> get tastyMap => descriptions;
  static List<TastyType> get valuesList => TastyType.values;
}
