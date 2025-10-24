class Region {
  final String id;
  final String name;
  final List<Council> councils;

  Region({
    required this.id,
    required this.name,
    required this.councils,
  });
}

class Council {
  final String id;
  final String name;
  final String regionId;

  Council({
    required this.id,
    required this.name,
    required this.regionId,
  });
}
