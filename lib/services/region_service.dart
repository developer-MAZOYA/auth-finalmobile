import '../models/region_model.dart';

class RegionService {
  static final List<Region> regions = [
    Region(
      id: '1',
      name: 'Arusha',
      councils: [
        Council(id: '1', name: 'Arusha City Council', regionId: '1'),
        Council(id: '2', name: 'Arusha District Council', regionId: '1'),
        Council(id: '3', name: 'Karatu District Council', regionId: '1'),
        Council(id: '4', name: 'Longido District Council', regionId: '1'),
        Council(id: '5', name: 'Meru District Council', regionId: '1'),
        Council(id: '6', name: 'Monduli District Council', regionId: '1'),
        Council(id: '7', name: 'Ngorongoro District Council', regionId: '1'),
      ],
    ),
    Region(
      id: '2',
      name: 'Dodoma',
      councils: [
        Council(id: '8', name: 'Bahi District Council', regionId: '2'),
        Council(id: '9', name: 'Chamwino District Council', regionId: '2'),
        Council(id: '10', name: 'Chemba District Council', regionId: '2'),
        Council(id: '11', name: 'Dodoma Municipal Council', regionId: '2'),
        Council(id: '12', name: 'Kondoa District Council', regionId: '2'),
        Council(id: '13', name: 'Kongwa District Council', regionId: '2'),
        Council(id: '14', name: 'Mpwapwa District Council', regionId: '2'),
      ],
    ),
    Region(
      id: '3',
      name: 'Kilimanjaro',
      councils: [
        Council(id: '45', name: 'Hai District Council', regionId: '3'),
        Council(id: '46', name: 'Moshi District Council', regionId: '3'),
        Council(id: '47', name: 'Moshi Municipal Council', regionId: '3'),
        Council(id: '48', name: 'Mwanga District Council', regionId: '3'),
        Council(id: '49', name: 'Rombo District Council', regionId: '3'),
        Council(id: '50', name: 'Same District Council', regionId: '3'),
        Council(id: '51', name: 'Siha District Council', regionId: '3'),
      ],
    ),
    // Add more regions here following the same pattern
    Region(
      id: '4',
      name: 'Morogoro',
      councils: [
        Council(id: '77', name: 'Gairo District Council', regionId: '4'),
        Council(id: '78', name: 'Kilombero District Council', regionId: '4'),
        Council(id: '79', name: 'Kilosa District Council', regionId: '4'),
        Council(id: '80', name: 'Morogoro District Council', regionId: '4'),
        Council(id: '81', name: 'Morogoro Municipal Council', regionId: '4'),
        Council(id: '82', name: 'Mvomero District Council', regionId: '4'),
        Council(id: '83', name: 'Ulanga District Council', regionId: '4'),
      ],
    ),
    Region(
      id: '5',
      name: 'Mbeya',
      councils: [
        Council(id: '71', name: 'Chunya District Council', regionId: '5'),
        Council(id: '72', name: 'Kyela District Council', regionId: '5'),
        Council(id: '73', name: 'Mbarali District Council', regionId: '5'),
        Council(id: '74', name: 'Mbeya City Council', regionId: '5'),
        Council(id: '75', name: 'Mbeya District Council', regionId: '5'),
        Council(id: '76', name: 'Rungwe District Council', regionId: '5'),
      ],
    ),
    // You can continue adding all other regions from the list I provided earlier
  ];

  static List<Region> getAllRegions() {
    return regions;
  }

  static List<Council> getCouncilsByRegionId(String regionId) {
    final region = regions.firstWhere(
      (region) => region.id == regionId,
      orElse: () => Region(id: '', name: '', councils: []),
    );
    return region.councils;
  }

  static List<Council> getCouncilsByRegionName(String regionName) {
    final region = regions.firstWhere(
      (region) => region.name == regionName,
      orElse: () => Region(id: '', name: '', councils: []),
    );
    return region.councils;
  }
}
