import 'package:flutter_test/flutter_test.dart';
import 'package:pfs_game_01/src/persistence/save_store.dart';
import 'package:pfs_game_01/src/ui/app.dart';

void main() {
  testWidgets('home exposes play, levels and settings in English', (
    tester,
  ) async {
    await tester.pumpWidget(
      const PfsGameApp(initialSave: PlayerSave(languageCode: 'en')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Wake the landscape.'), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);
    expect(find.text('Levels'), findsOneWidget);
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsWidgets);
    expect(find.text('Credits & licences'), findsWidgets);
    await tester.tap(find.text('Credits & licences').last);
    await tester.pumpAndSettle();
    expect(
      find.text('Original game produced by Puzzle Force Studio.'),
      findsOneWidget,
    );
  });
}
