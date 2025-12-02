class AvatarHelper {
  static const List<String> availableAvatars = [
    'androide',
    'ainara',
    'cientifico',
    'timida',
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
    
    return 'assets/avatars/$name/$name.$state.png';
  }
}
