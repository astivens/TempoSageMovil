class StringSimilarity {
  /// Calcula la distancia de Levenshtein entre dos strings
  static int levenshteinDistance(String s1, String s2) {
    if (s1 == s2) return 0;
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    List<int> v0 = List<int>.filled(s2.length + 1, 0);
    List<int> v1 = List<int>.filled(s2.length + 1, 0);

    for (int i = 0; i < v0.length; i++) {
      v0[i] = i;
    }

    for (int i = 0; i < s1.length; i++) {
      v1[0] = i + 1;

      for (int j = 0; j < s2.length; j++) {
        int cost = (s1[i] == s2[j]) ? 0 : 1;
        v1[j + 1] = [v1[j] + 1, v0[j + 1] + 1, v0[j] + cost].reduce(min);
      }

      for (int j = 0; j < v0.length; j++) {
        v0[j] = v1[j];
      }
    }

    return v1[s2.length];
  }

  /// Calcula la similitud entre dos strings (0 a 1)
  static double similarity(String s1, String s2) {
    s1 = s1.toLowerCase();
    s2 = s2.toLowerCase();

    int maxLength = s1.length > s2.length ? s1.length : s2.length;
    if (maxLength == 0) return 1.0;

    return (maxLength - levenshteinDistance(s1, s2)) / maxLength.toDouble();
  }

  /// Encuentra la mejor coincidencia en una lista de strings
  static String? findBestMatch(String query, List<String> candidates) {
    if (candidates.isEmpty) return null;

    double bestScore = 0.0;
    String? bestMatch;

    for (String candidate in candidates) {
      double score = similarity(query, candidate);
      if (score > bestScore) {
        bestScore = score;
        bestMatch = candidate;
      }
    }

    // Solo retornar coincidencias con un score mayor a 0.5
    return bestScore > 0.5 ? bestMatch : null;
  }
}

int min(int a, int b) => a < b ? a : b;
