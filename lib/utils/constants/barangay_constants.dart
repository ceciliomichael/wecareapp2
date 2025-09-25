class LocationConstants {
  // Tagbilaran City Barangays (capital of Bohol)
  static const List<String> tagbilaranBarangays = [
    'Bool',
    'Booy',
    'Cabawan',
    'Cogon',
    'Dampas',
    'Dao',
    'Manga',
    'Mansasa',
    'Poblacion I',
    'Poblacion II',
    'Poblacion III',
    'San Isidro',
    'Taloto',
    'Tiptip',
    'Ubujan',
  ];

  // All Bohol Municipalities and City
  static const List<String> boholMunicipalities = [
    'Alburquerque',
    'Alicia',
    'Anda',
    'Antequera',
    'Baclayon',
    'Balilihan',
    'Batuan',
    'Bien Unido',
    'Bilar',
    'Buenavista',
    'Calape',
    'Candijay',
    'Carmen',
    'Catigbian',
    'Clarin',
    'Corella',
    'Cortes',
    'Dagohoy',
    'Danao',
    'Dauis',
    'Dimiao',
    'Duero',
    'Garcia Hernandez',
    'Getafe',
    'Guindulman',
    'Inabanga',
    'Jagna',
    'Lila',
    'Loay',
    'Loboc',
    'Loon',
    'Mabini',
    'Maribojoc',
    'Panglao',
    'Pilar',
    'President Carlos P. Garcia',
    'Sagbayan',
    'San Isidro',
    'San Miguel',
    'Sevilla',
    'Sierra Bullones',
    'Sikatuna',
    'Tagbilaran',
    'Talibon',
    'Trinidad',
    'Tubigon',
    'Ubay',
    'Valencia',
  ];

  // Major urban barangays across Bohol (for enhanced location selection)
  static const List<String> majorBoholBarangays = [
    // Tagbilaran City
    'Bool', 'Booy', 'Cogon', 'Dao', 'Manga', 'Mansasa', 'Poblacion I', 'Poblacion II', 'Poblacion III',
    
    // Panglao (tourist area)
    'Poblacion', 'Doljo', 'Tangnan', 'Tawala', 'Bolod', 'Danao', 'Libaong', 'Lourdes', 'Tangen', 'Looc',
    
    // Dauis
    'Bingag', 'Biking', 'Catarman', 'Dao', 'Mariveles', 'Mayacabac', 'Poblacion', 'San Agustin', 'Tinago', 'Totolan',
    
    // Baclayon
    'Banlasan', 'Boyog Norte', 'Boyog Sur', 'Daorong', 'Landican', 'Laya', 'Liboron', 'Poblacion', 'Tanday', 'Taguihon',
    
    // Tubigon
    'Bagacay', 'Batasan', 'Bilangbilangan Este', 'Bilangbilangan Weste', 'Bosque', 'Cabulihan', 'Cahayag', 'Centro Poblacion',
    
    // Loon
    'Biasong', 'Cabol', 'Cambane', 'Campatud', 'Canlubang', 'Canmano', 'Cantaguic', 'Cayacay', 'Guinobatan', 'Huanh',
    
    // Loay
    'Alegria', 'Bogo', 'Canangca-an', 'Canayaon', 'Entice', 'La Union', 'Lobogon', 'Looc', 'Napo', 'Poblacion Weste',
  ];

  // Get all available locations for dropdowns
  static List<String> getAllLocations() {
    return [...boholMunicipalities];
  }

  // Get locations sorted alphabetically
  static List<String> getSortedLocations() {
    final allLocations = getAllLocations().toSet().toList();
    allLocations.sort();
    return allLocations;
  }
}

// For backward compatibility
@Deprecated('Use LocationConstants instead')
class BarangayConstants {
  static const List<String> tagbilaranBarangays = LocationConstants.tagbilaranBarangays;
}
