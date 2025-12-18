//lib/utils/ingredient_analyzer.dart
class IngredientAnalyzer {
  // Define danger patterns as static to avoid re-initialization
  // --- V3.3 Regex Logic (Rewe Tested) ---
  static final Map<String, RegExp> _dangerPatterns = {
        "PHOSPHAT/SÄURE": RegExp(r"phosph[a|o]", caseSensitive: false), 
        "E450 (Diphosphat)": RegExp(r"e[\s:.-]*450", caseSensitive: false), 
        "E338": RegExp(r"e[\s:-]*338", caseSensitive: false),
        "E339": RegExp(r"e[\s:-]*339", caseSensitive: false),
        "E340": RegExp(r"e[\s:-]*340", caseSensitive: false),
        "E341": RegExp(r"e[\s:-]*341", caseSensitive: false),
        "E451": RegExp(r"e[\s:-]*451", caseSensitive: false),
        "E452": RegExp(r"e[\s:-]*452", caseSensitive: false),
        "E621 (MSG/Glutamat)": RegExp(r"e[\s:-]*621", caseSensitive: false),
        "KALIUM": RegExp(r"k[a|o]l[i]?um", caseSensitive: false), 
        "HEFEEXTRAKT (Verstecktes Phosphat)": RegExp(r"hefeextrakt", caseSensitive: false),
        "GESCHMACKSVERSTÄRKER": RegExp(r"geschmacks.*(stärker|starter|staerker)", caseSensitive: false),
        "NATRIUMNITRIT": RegExp(r"natriumnitrit", caseSensitive: false),
      };
  static List<String>analyze(String text){
    List<String> found =[];
    _dangerPatterns.forEach((name, pattern) {
      if (pattern.hasMatch(text)) {
        found.add(name);
      }
    });
    return found;
  }
}