import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../game/game_engine.dart';
import '../game/game_models.dart';
import '../localization/app_localizations.dart';
import '../persistence/save_store.dart';

const _ink = Color(0xFF152A2A);
const _deep = Color(0xFF0F3A3A);
const _mint = Color(0xFFB9E3C6);
const _cream = Color(0xFFFFF8E8);
const _coral = Color(0xFFFF8C69);
const _sun = Color(0xFFF6D365);

class PfsGameApp extends StatefulWidget {
  const PfsGameApp({super.key, required this.initialSave});
  final PlayerSave initialSave;

  @override
  State<PfsGameApp> createState() => _PfsGameAppState();
}

class _PfsGameAppState extends State<PfsGameApp> {
  late PlayerSave _save = widget.initialSave;
  late Locale _locale = Locale(
    widget.initialSave.languageCode ??
        (WidgetsBinding.instance.platformDispatcher.locale.languageCode == 'fr'
            ? 'fr'
            : 'en'),
  );

  Future<void> updateSave(PlayerSave save) async {
    setState(() {
      _save = save;
      if (save.languageCode != null) _locale = Locale(save.languageCode!);
    });
    await SaveStore.save(save);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PFS Game 01',
      locale: _locale,
      supportedLocales: AppLocalizations.supported,
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        DefaultWidgetsLocalizations.delegate,
        DefaultMaterialLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: _cream,
        colorScheme: ColorScheme.fromSeed(seedColor: _mint),
        fontFamily: 'Arial',
      ),
      home: HomePage(save: _save, onSaveChanged: updateSave),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.save, required this.onSaveChanged});
  final PlayerSave save;
  final Future<void> Function(PlayerSave) onSaveChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final levels = buildLevels();
    final next = save.currentLevel.clamp(1, levels.length);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.t('homeEyebrow'),
                    style: const TextStyle(
                      color: _coral,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      letterSpacing: 1.8,
                    ),
                  ),
                  _RoundIconButton(
                    icon: Icons.tune_rounded,
                    label: l10n.t('settings'),
                    onPressed: () => _push(
                      context,
                      SettingsPage(save: save, onSaveChanged: onSaveChanged),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 44),
              const _LandscapeMark(),
              const SizedBox(height: 25),
              Text(
                l10n.t('homeTitle'),
                style: const TextStyle(
                  fontSize: 42,
                  height: .98,
                  fontWeight: FontWeight.w900,
                  color: _ink,
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(height: 17),
              Text(
                l10n.t('homeBody'),
                style: TextStyle(
                  fontSize: 17,
                  height: 1.35,
                  color: _ink.withValues(alpha: .72),
                ),
              ),
              const SizedBox(height: 30),
              _PrimaryButton(
                label: save.completedLevels.isEmpty
                    ? l10n.t('play')
                    : l10n.t('continue'),
                icon: Icons.arrow_forward_rounded,
                onPressed: () => _push(
                  context,
                  GamePage(
                    level: levels[next - 1],
                    save: save,
                    onSaveChanged: onSaveChanged,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _SecondaryButton(
                label: l10n.t('levels'),
                icon: Icons.grid_view_rounded,
                onPressed: () => _push(
                  context,
                  LevelSelectPage(save: save, onSaveChanged: onSaveChanged),
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  const Icon(Icons.cloud_outlined, size: 18, color: _deep),
                  const SizedBox(width: 8),
                  Text(
                    l10n.t('offline'),
                    style: TextStyle(
                      color: _ink.withValues(alpha: .62),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({
    super.key,
    required this.level,
    required this.save,
    required this.onSaveChanged,
  });
  final LevelDefinition level;
  final PlayerSave save;
  final Future<void> Function(PlayerSave) onSaveChanged;

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage>
    with SingleTickerProviderStateMixin {
  late final GameEngine _engine = GameEngine(widget.level);
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  String? _feedbackKey;
  bool _showPause = false;

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _tapBoard(Offset local, Size size) {
    final cellSize = size.width / widget.level.size;
    final cell = Cell(
      (local.dx / cellSize).floor(),
      (local.dy / cellSize).floor(),
    );
    if (cell.x < 0 ||
        cell.y < 0 ||
        cell.x >= widget.level.size ||
        cell.y >= widget.level.size) {
      return;
    }
    final changed = _engine.tap(cell);
    setState(() => _feedbackKey = _engine.snapshot.messageKey);
    if (changed) {
      _pulse.forward(from: 0);
      if (widget.save.haptics) HapticFeedback.selectionClick();
      if (_engine.snapshot.isWon) _completeLevel();
    } else if (widget.save.haptics) {
      HapticFeedback.vibrate();
    }
  }

  Future<void> _completeLevel() async {
    final completed = {...widget.save.completedLevels, widget.level.id};
    final next = math.min(buildLevels().length, widget.level.id + 1);
    await widget.onSaveChanged(
      widget.save.copyWith(completedLevels: completed, currentLevel: next),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final snapshot = _engine.snapshot;
    final activeMessage =
        _feedbackKey ?? (snapshot.moves == 0 ? 'placeHint' : 'rotateHint');
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 4),
                  child: Row(
                    children: [
                      _RoundIconButton(
                        icon: Icons.arrow_back_rounded,
                        label: l10n.t('back'),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${l10n.t('level')} ${widget.level.id} ${l10n.t('of')} ${buildLevels().length}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: _coral,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              l10n.t(widget.level.titleKey),
                              style: const TextStyle(
                                fontSize: 22,
                                color: _ink,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _RoundIconButton(
                        icon: Icons.pause_rounded,
                        label: l10n.t('pause'),
                        onPressed: () => setState(() => _showPause = true),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 7,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.t(widget.level.subtitleKey),
                      style: TextStyle(
                        color: _ink.withValues(alpha: .63),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final side = math.min(
                            constraints.maxWidth,
                            constraints.maxHeight,
                          );
                          final boardSize = Size(side, side);
                          return SizedBox(
                            width: side,
                            height: side,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTapUp: (details) =>
                                  _tapBoard(details.localPosition, boardSize),
                              child: AnimatedBuilder(
                                animation: _pulse,
                                builder: (context, child) => CustomPaint(
                                  painter: MeadowPainter(
                                    snapshot: _engine.snapshot,
                                    pulse: _pulse.value,
                                    reducedMotion: widget.save.reducedMotion,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.spa_rounded,
                            size: 17,
                            color: _coral,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${snapshot.remainingPetals} ${l10n.t('moves')}  •  ${widget.level.buds.length - snapshot.awake.length} ${l10n.t('wake')}',
                            style: const TextStyle(
                              color: _ink,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: Text(
                          l10n.t(activeMessage),
                          key: ValueKey(activeMessage),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _ink.withValues(alpha: .65),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (snapshot.isWon)
              _VictoryCard(
                level: widget.level,
                onNext: () {
                  if (widget.level.id < buildLevels().length) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GamePage(
                          level: buildLevels()[widget.level.id],
                          save: widget.save.copyWith(
                            currentLevel: widget.level.id + 1,
                          ),
                          onSaveChanged: widget.onSaveChanged,
                        ),
                      ),
                    );
                  } else {
                    Navigator.pop(context);
                  }
                },
                onHome: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
              ),
            if (_showPause)
              _PauseCard(
                onResume: () => setState(() => _showPause = false),
                onRestart: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GamePage(
                        level: widget.level,
                        save: widget.save,
                        onSaveChanged: widget.onSaveChanged,
                      ),
                    ),
                  );
                },
                onSettings: () => _push(
                  context,
                  SettingsPage(
                    save: widget.save,
                    onSaveChanged: widget.onSaveChanged,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class MeadowPainter extends CustomPainter {
  MeadowPainter({
    required this.snapshot,
    required this.pulse,
    required this.reducedMotion,
  });
  final GameSnapshot snapshot;
  final double pulse;
  final bool reducedMotion;

  @override
  void paint(Canvas canvas, Size size) {
    final n = snapshot.level.size;
    final cell = size.width / n;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(28)),
      Paint()..color = const Color(0xFFECF4DC),
    );
    final grid = Paint()
      ..color = const Color(0xFFB7D4B6).withValues(alpha: .48)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var y = 0; y < n; y++) {
      for (var x = 0; x < n; x++) {
        final rect = Rect.fromLTWH(
          x * cell + 4,
          y * cell + 4,
          cell - 8,
          cell - 8,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(15)),
          grid,
        );
      }
    }
    final stone = Paint()..color = const Color(0xFF9CB9A1);
    for (final item in snapshot.level.stones) {
      final center = Offset((item.x + .5) * cell, (item.y + .5) * cell);
      canvas.drawCircle(center, cell * .25, stone);
      canvas.drawCircle(
        center.translate(-cell * .08, -cell * .08),
        cell * .08,
        Paint()..color = const Color(0xFFCBE0C3),
      );
    }
    for (final petal in snapshot.placed) {
      _drawPetal(canvas, petal, cell);
    }
    for (final bud in snapshot.level.buds) {
      _drawBud(canvas, bud, cell, snapshot.awake.contains(bud));
    }
    _drawSource(canvas, snapshot.level.source, cell);
  }

  void _drawSource(Canvas canvas, Cell item, double cell) {
    final center = Offset((item.x + .5) * cell, (item.y + .5) * cell);
    final motion = reducedMotion ? 0.0 : pulse;
    canvas.drawCircle(
      center,
      cell * (.32 + motion * .05),
      Paint()..color = _sun.withValues(alpha: .18 + motion * .12),
    );
    canvas.drawCircle(center, cell * .17, Paint()..color = _sun);
    canvas.drawCircle(
      center,
      cell * .23,
      Paint()
        ..color = _deep
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawBud(Canvas canvas, Cell item, double cell, bool awake) {
    final center = Offset((item.x + .5) * cell, (item.y + .5) * cell);
    final color = awake ? _coral : const Color(0xFF6D9C82);
    final petal = Paint()..color = color.withValues(alpha: awake ? .92 : .5);
    for (var i = 0; i < 4; i++) {
      final angle = i * math.pi / 2;
      final point =
          center + Offset(math.cos(angle), math.sin(angle)) * cell * .16;
      canvas.drawOval(
        Rect.fromCenter(center: point, width: cell * .17, height: cell * .29),
        petal,
      );
    }
    canvas.drawCircle(
      center,
      cell * .09,
      Paint()..color = awake ? _sun : _mint,
    );
  }

  void _drawPetal(Canvas canvas, PlacedPetal item, double cell) {
    final center = Offset((item.cell.x + .5) * cell, (item.cell.y + .5) * cell);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(item.direction.index * math.pi / 2);
    final shape = Path()
      ..moveTo(0, -cell * .3)
      ..quadraticBezierTo(cell * .25, -cell * .08, 0, cell * .25)
      ..quadraticBezierTo(-cell * .25, -cell * .08, 0, -cell * .3)
      ..close();
    canvas.drawPath(shape, Paint()..color = _deep);
    canvas.drawCircle(Offset.zero, cell * .055, Paint()..color = _sun);
    final line = Paint()
      ..color = _mint
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, -cell * .18), Offset(0, -cell * .4), line);
    canvas.drawCircle(Offset(0, -cell * .4), 2.5, Paint()..color = _sun);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant MeadowPainter oldDelegate) =>
      oldDelegate.snapshot != snapshot || oldDelegate.pulse != pulse;
}

class _VictoryCard extends StatelessWidget {
  const _VictoryCard({
    required this.level,
    required this.onNext,
    required this.onHome,
  });
  final LevelDefinition level;
  final VoidCallback onNext;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final last = level.id == buildLevels().length;
    return _OverlayCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _LandscapeMark(compact: true),
          const SizedBox(height: 18),
          Text(
            l10n.t('victoryTitle'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: _ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.t('victoryBody'),
            textAlign: TextAlign.center,
            style: TextStyle(color: _ink.withValues(alpha: .7), fontSize: 15),
          ),
          const SizedBox(height: 22),
          _PrimaryButton(
            label: last ? l10n.t('finish') : l10n.t('nextLevel'),
            icon: Icons.arrow_forward_rounded,
            onPressed: onNext,
          ),
          const SizedBox(height: 10),
          TextButton(onPressed: onHome, child: Text(l10n.t('home'))),
        ],
      ),
    );
  }
}

class _PauseCard extends StatelessWidget {
  const _PauseCard({
    required this.onResume,
    required this.onRestart,
    required this.onSettings,
  });
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _OverlayCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.t('pause'),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: _ink,
            ),
          ),
          const SizedBox(height: 20),
          _PrimaryButton(
            label: l10n.t('resume'),
            icon: Icons.play_arrow_rounded,
            onPressed: onResume,
          ),
          const SizedBox(height: 10),
          _SecondaryButton(
            label: l10n.t('restart'),
            icon: Icons.replay_rounded,
            onPressed: onRestart,
          ),
          const SizedBox(height: 4),
          TextButton(onPressed: onSettings, child: Text(l10n.t('settings'))),
        ],
      ),
    );
  }
}

class _OverlayCard extends StatelessWidget {
  const _OverlayCard({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    color: _deep.withValues(alpha: .86),
    alignment: Alignment.center,
    padding: const EdgeInsets.all(28),
    child: Card(
      color: _cream,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Padding(padding: const EdgeInsets.all(26), child: child),
    ),
  );
}

class LevelSelectPage extends StatelessWidget {
  const LevelSelectPage({
    super.key,
    required this.save,
    required this.onSaveChanged,
  });
  final PlayerSave save;
  final Future<void> Function(PlayerSave) onSaveChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final levels = buildLevels();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.t('levels')), backgroundColor: _cream),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
          itemCount: levels.length,
          separatorBuilder: (_, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final level = levels[index];
            final available =
                index == 0 || save.completedLevels.contains(index);
            final completed = save.completedLevels.contains(level.id);
            return Semantics(
              button: true,
              enabled: available,
              label: '${l10n.t('level')} ${level.id}',
              child: Material(
                color: available
                    ? _mint.withValues(alpha: .42)
                    : Colors.black.withValues(alpha: .04),
                borderRadius: BorderRadius.circular(22),
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: available
                      ? () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GamePage(
                              level: level,
                              save: save.copyWith(currentLevel: level.id),
                              onSaveChanged: onSaveChanged,
                            ),
                          ),
                        )
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.all(19),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: available ? _deep : Colors.black12,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${level.id}',
                            style: TextStyle(
                              color: available ? _sun : Colors.black38,
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.t(level.titleKey),
                                style: const TextStyle(
                                  color: _ink,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                available
                                    ? l10n.t('unlocked')
                                    : l10n.t('locked'),
                                style: TextStyle(
                                  color: _ink.withValues(alpha: .6),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          completed
                              ? Icons.check_circle_rounded
                              : available
                              ? Icons.arrow_forward_rounded
                              : Icons.lock_rounded,
                          color: completed ? _coral : _deep,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.save,
    required this.onSaveChanged,
  });
  final PlayerSave save;
  final Future<void> Function(PlayerSave) onSaveChanged;
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late PlayerSave _save = widget.save;

  Future<void> _set(PlayerSave save) async {
    setState(() => _save = save);
    await widget.onSaveChanged(save);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final language = Localizations.localeOf(context).languageCode;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.t('settings')), backgroundColor: _cream),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
        children: [
          _SettingsSection(
            title: l10n.t('language'),
            child: Column(
              children: [
                RadioListTile<String>(
                  value: 'fr',
                  groupValue: language,
                  onChanged: (_) => _set(_save.copyWith(languageCode: 'fr')),
                  title: Text(l10n.t('french')),
                ),
                RadioListTile<String>(
                  value: 'en',
                  groupValue: language,
                  onChanged: (_) => _set(_save.copyWith(languageCode: 'en')),
                  title: Text(l10n.t('english')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SettingsSection(
            title: l10n.t('settings'),
            child: Column(
              children: [
                _SwitchRow(
                  label: l10n.t('music'),
                  value: _save.music,
                  onChanged: (value) => _set(_save.copyWith(music: value)),
                ),
                _SwitchRow(
                  label: l10n.t('effects'),
                  value: _save.effects,
                  onChanged: (value) => _set(_save.copyWith(effects: value)),
                ),
                _SwitchRow(
                  label: l10n.t('haptics'),
                  value: _save.haptics,
                  onChanged: (value) => _set(_save.copyWith(haptics: value)),
                ),
                _SwitchRow(
                  label: l10n.t('reducedMotion'),
                  value: _save.reducedMotion,
                  onChanged: (value) =>
                      _set(_save.copyWith(reducedMotion: value)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SettingsSection(
            title: l10n.t('credits'),
            child: ListTile(
              leading: const Icon(Icons.article_outlined, color: _coral),
              title: Text(l10n.t('credits')),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _push(context, const CreditsPage()),
            ),
          ),
        ],
      ),
    );
  }
}

class CreditsPage extends StatelessWidget {
  const CreditsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('creditsTitle')),
        backgroundColor: _cream,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 30),
        children: [
          const _LandscapeMark(compact: true),
          const SizedBox(height: 18),
          Text(
            l10n.t('appTitle'),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: _ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${l10n.t('version')} 0.1.0 (1)',
            style: TextStyle(color: _ink.withValues(alpha: .7)),
          ),
          const SizedBox(height: 24),
          _CreditBlock(
            title: l10n.t('originalProduction'),
            body: l10n.t('rightsHolderPending'),
          ),
          _CreditBlock(title: l10n.t('audioLink'), body: l10n.t('audioCredit')),
          _CreditBlock(title: l10n.t('visualCredit'), body: ''),
          _CreditBlock(
            title: l10n.t('software'),
            body: l10n.t('softwareCredit'),
          ),
          _CreditBlock(title: l10n.t('support'), body: ''),
          const SizedBox(height: 16),
          Text(
            l10n.t('offline'),
            style: TextStyle(
              color: _deep.withValues(alpha: .78),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CreditBlock extends StatelessWidget {
  const _CreditBlock({required this.title, required this.body});
  final String title;
  final String body;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _ink,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        if (body.isNotEmpty) ...[
          const SizedBox(height: 5),
          Text(
            body,
            style: TextStyle(color: _ink.withValues(alpha: .7), height: 1.35),
          ),
        ],
      ],
    ),
  );
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Card(
    color: Colors.white.withValues(alpha: .62),
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 9, 18, 3),
            child: Text(
              title,
              style: const TextStyle(
                color: _coral,
                fontWeight: FontWeight.w800,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
          ),
          child,
        ],
      ),
    ),
  );
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) => SwitchListTile.adaptive(
    title: Text(label),
    value: value,
    onChanged: onChanged,
    activeThumbColor: _deep,
  );
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: IconButton(
      tooltip: label,
      onPressed: onPressed,
      icon: Icon(icon, color: _deep),
      style: IconButton.styleFrom(
        backgroundColor: _mint.withValues(alpha: .55),
        minimumSize: const Size(46, 46),
      ),
    ),
  );
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: SizedBox(
      width: double.infinity,
      height: 58,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: _deep,
          foregroundColor: _sun,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    ),
  );
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
        style: OutlinedButton.styleFrom(
          foregroundColor: _deep,
          side: const BorderSide(color: _deep, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    ),
  );
}

class _LandscapeMark extends StatelessWidget {
  const _LandscapeMark({this.compact = false});
  final bool compact;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: compact ? 94 : double.infinity,
    height: compact ? 70 : 112,
    child: CustomPaint(painter: MarkPainter()),
  );
}

class MarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    canvas.drawCircle(
      Offset(width * .45, height * .52),
      math.min(width, height) * .28,
      Paint()..color = _deep,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(width * .19, height * .68),
        width: width * .38,
        height: height * .18,
      ),
      Paint()..color = _mint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(width * .73, height * .32),
        width: width * .38,
        height: height * .18,
      ),
      Paint()..color = _coral,
    );
    canvas.drawCircle(
      Offset(width * .45, height * .52),
      math.min(width, height) * .11,
      Paint()..color = _sun,
    );
  }

  @override
  bool shouldRepaint(covariant MarkPainter oldDelegate) => false;
}

void _push(BuildContext context, Widget page) {
  Navigator.push(context, MaterialPageRoute(builder: (_) => page));
}
