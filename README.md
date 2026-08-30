# PFS Game 01

Premier prototype de Puzzle Force Studio : un puzzle de planification visuelle
original, jouable hors ligne en portrait. Le nom marketing final reste à
choisir ; le produit utilise volontairement le label neutre `PFS Game 01`.

## Jouer

```bash
flutter pub get
flutter run
flutter test
flutter analyze
```

Depuis l’accueil, choisissez **Jouer**. Touchez une clairière pour poser un
pétale de brise, puis touchez-le à nouveau pour le faire pivoter. Le souffle
part du noyau doré et suit les pétales jusqu’aux bourgeons. Six niveaux courts
progressent par ajouts de pierres et de chemins multiples.

## Structure

- `lib/src/game/` contient les règles pures et les six définitions de niveaux.
- `lib/src/ui/` contient l’accueil, le plateau CustomPainter, la pause, les niveaux,
  les réglages et les crédits hors ligne.
- `lib/src/localization/` contient les chaînes FR/EN.
- `lib/src/persistence/` contient la sauvegarde locale versionnée.
- `docs/` contient la fiche concept, l’audit d’originalité, le QA, les droits et
  le manifest de release.

## État des droits

Les visuels sont dessinés/générés par le code du projet. Aucun fichier audio
tiers n’est embarqué dans ce build ; aucun fichier ZapSplat non vérifié n’est
utilisé. Voir [`docs/rights-register.md`](docs/rights-register.md).

## Limites connues

Le slice n’inclut ni compte, ni réseau, ni monétisation, ni audio livré. Les
contrôles musique/effets sont présents dans Réglages afin de stabiliser le
contrat d’interface avant l’ajout éventuel d’effets licenciés.
