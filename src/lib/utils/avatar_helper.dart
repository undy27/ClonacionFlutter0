class AvatarHelper {
  static const List<String> availableAvatars = [
    'ainara',
    'amy',
    'androide',
    'cientifico',
    'fx',
  ];

  static String getAvatarPath(String avatarName, int state) {
    // state: 0=default/ranking, 1=winning, 2=neutral, 3=losing
    // Normalize avatar name just in case
    String name = avatarName;
    if (!availableAvatars.contains(name)) {
      // Try to find case-insensitive match
      final match = availableAvatars.firstWhere(
        (a) => a.toLowerCase() == name.toLowerCase(),
        orElse: () => 'cientifico',
      );
      name = match;
    }
    
    // Special case for FX avatar (files are uppercase)
    String fileName = name;
    if (name == 'fx') {
      fileName = 'FX';
    }
    
    return 'assets/avatars/$name/$fileName.$state.png';
  }
}
