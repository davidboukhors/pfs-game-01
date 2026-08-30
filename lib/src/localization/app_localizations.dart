import 'package:flutter/widgets.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const supported = [Locale('fr'), Locale('en')];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  String t(String key) =>
      _copy[locale.languageCode]?[key] ?? _copy['en']![key] ?? key;

  static const _copy = <String, Map<String, String>>{
    'fr': {
      'appTitle': 'PFS Game 01',
      'homeEyebrow': 'PUZZLE FORCE STUDIO',
      'homeTitle': 'Réveille le paysage.',
      'homeBody':
          'Pose des pétales de brise et compose un chemin de lumière douce jusqu’aux bourgeons.',
      'play': 'Jouer',
      'continue': 'Continuer',
      'levels': 'Niveaux',
      'settings': 'Réglages',
      'credits': 'Crédits & licences',
      'back': 'Retour',
      'pause': 'Pause',
      'resume': 'Reprendre',
      'restart': 'Recommencer',
      'home': 'Accueil',
      'level': 'Niveau',
      'of': 'sur',
      'placeHint': 'Touche une clairière pour poser un pétale.',
      'rotateHint': 'Touche un pétale pour le faire pivoter.',
      'allBuds': 'Tous les bourgeons sont éveillés.',
      'invalid': 'Cette clairière ne peut pas accueillir de pétale.',
      'noMoves': 'Plus de pétales disponibles.',
      'victoryTitle': 'Le paysage respire.',
      'victoryBody': 'Une nouvelle clairière vient de s’ouvrir.',
      'nextLevel': 'Clairière suivante',
      'finish': 'Finir la promenade',
      'moves': 'pétales',
      'wake': 'à éveiller',
      'music': 'Musique',
      'effects': 'Effets sonores',
      'haptics': 'Retour tactile',
      'reducedMotion': 'Réduire les mouvements',
      'language': 'Langue',
      'french': 'Français',
      'english': 'English',
      'creditsTitle': 'Crédits & licences',
      'originalProduction': 'Jeu original produit par Puzzle Force Studio.',
      'audioCredit':
          'Audio : aucun fichier audio tiers n’est intégré dans ce build. Les effets prévus seront ajoutés uniquement avec une fiche de droits complète ZapSplat.',
      'audioLink': 'Source de référence : zapsplat.com',
      'visualCredit':
          'Visuels : illustrations et rendu générés pour ce projet par Puzzle Force Studio.',
      'software': 'Logiciels et polices tiers',
      'softwareCredit':
          'Flutter 3.38.9 et Dart 3.10.8 — licence BSD-3-Clause — flutter.dev',
      'rightsHolderPending':
          'Titulaire légal : à confirmer avant toute publication.',
      'support':
          'Support et confidentialité : puzzleforce.fr (lien prévu pour la publication).',
      'version': 'Version',
      'offline': 'Le cœur du jeu fonctionne hors ligne.',
      'locked': 'À découvrir',
      'unlocked': 'Disponible',
      'close': 'Fermer',
      'selectLanguage': 'Choisir la langue',
      'level1Title': 'Le premier souffle',
      'level1Subtitle': 'Un pétale, une direction, une clairière éveillée.',
      'level2Title': 'Deux chemins doux',
      'level2Subtitle': 'Un même souffle peut se diviser.',
      'level3Title': 'Le détour des fougères',
      'level3Subtitle': 'Les pierres anciennes demandent un détour.',
      'level4Title': 'Au bord du matin',
      'level4Subtitle': 'Réveille les bourgeons dans le bon rythme.',
      'level5Title': 'Le jardin suspendu',
      'level5Subtitle': 'Chaque pétale compte maintenant.',
      'level6Title': 'La clairière complète',
      'level6Subtitle': 'Un dernier mouvement pour tout relier.',
    },
    'en': {
      'appTitle': 'PFS Game 01',
      'homeEyebrow': 'PUZZLE FORCE STUDIO',
      'homeTitle': 'Wake the landscape.',
      'homeBody':
          'Place breeze petals and shape a soft light path to the sleeping buds.',
      'play': 'Play',
      'continue': 'Continue',
      'levels': 'Levels',
      'settings': 'Settings',
      'credits': 'Credits & licences',
      'back': 'Back',
      'pause': 'Pause',
      'resume': 'Resume',
      'restart': 'Restart',
      'home': 'Home',
      'level': 'Level',
      'of': 'of',
      'placeHint': 'Tap a clearing to place a petal.',
      'rotateHint': 'Tap a petal to rotate it.',
      'allBuds': 'Every bud is awake.',
      'invalid': 'This clearing cannot hold a petal.',
      'noMoves': 'No petals left.',
      'victoryTitle': 'The landscape breathes.',
      'victoryBody': 'A new clearing has opened.',
      'nextLevel': 'Next clearing',
      'finish': 'Finish the walk',
      'moves': 'petals',
      'wake': 'to wake',
      'music': 'Music',
      'effects': 'Sound effects',
      'haptics': 'Haptics',
      'reducedMotion': 'Reduce motion',
      'language': 'Language',
      'french': 'Français',
      'english': 'English',
      'creditsTitle': 'Credits & licences',
      'originalProduction': 'Original game produced by Puzzle Force Studio.',
      'audioCredit':
          'Audio: no third-party audio file is integrated in this build. Planned effects will only be added with a complete ZapSplat rights record.',
      'audioLink': 'Reference source: zapsplat.com',
      'visualCredit':
          'Visuals: illustrations and rendering generated for this project by Puzzle Force Studio.',
      'software': 'Third-party software and fonts',
      'softwareCredit':
          'Flutter 3.38.9 and Dart 3.10.8 — BSD-3-Clause licence — flutter.dev',
      'rightsHolderPending':
          'Legal rights holder: to be confirmed before any publication.',
      'support':
          'Support and privacy: puzzleforce.fr (link planned for publication).',
      'version': 'Version',
      'offline': 'The game core works offline.',
      'locked': 'Discover later',
      'unlocked': 'Available',
      'close': 'Close',
      'selectLanguage': 'Choose language',
      'level1Title': 'The first breath',
      'level1Subtitle': 'One petal, one direction, one waking clearing.',
      'level2Title': 'Two gentle paths',
      'level2Subtitle': 'One breath can divide.',
      'level3Title': 'The fern detour',
      'level3Subtitle': 'Old stones ask for a detour.',
      'level4Title': 'At the edge of morning',
      'level4Subtitle': 'Wake the buds in the right rhythm.',
      'level5Title': 'The hanging garden',
      'level5Subtitle': 'Every petal counts now.',
      'level6Title': 'The full clearing',
      'level6Subtitle': 'One final movement to connect everything.',
    },
  };
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();
  @override
  bool isSupported(Locale locale) => ['fr', 'en'].contains(locale.languageCode);
  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);
  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
