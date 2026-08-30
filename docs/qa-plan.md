# QA plan and verification report

## Automated checks

- `flutter analyze` — executed 2026-08-30; no errors, four deprecation/info
  notices from current Flutter APIs.
- `flutter test` — executed 2026-08-30; 8 tests passed after fixes.
- Pure rules: placement, rotation, invalid cells, inventory cap and victory.
- Save codec: completed levels, settings and locale round-trip.
- Localization: principal keys exist in FR and EN.
- Widget smoke: home → settings → credits in English.

## Manual/device checks

- Mac host: code and tests executed; no physical-device claim.
- iPhone small screen: home smoke run on iPhone 16e Simulator; screenshot saved
  as `docs/evidence-iphone-home.png`. Complete touch session on iOS remains
  pending.
- Android mid-range: not yet run in an emulator or on hardware.
- Airplane mode: no network dependency in the game core, but device-level
  airplane-mode smoke remains pending.
- Audio: no audio file to verify; settings controls are present.
- Web evidence: `docs/evidence-home-web.png`, `evidence-game-start-web.png`,
  `evidence-victory-web.png`, `evidence-settings-web.png` and
  `evidence-credits-web.png`; `evidence-gameplay-web.mov` records the visible
  local session and `evidence-gameplay-web-final.mov` records the corrected
  action → victory → settings/credits sequence. These are web proof, not
  mobile-device proof.

## Before vertical-slice approval

1. Run iOS simulator small form factor and Android emulator compact form factor.
2. Capture first action, rotation, victory animation and credits path.
3. Run a complete session in FR and EN with manual language switch.
4. Verify dynamic text, semantics tree, reduced motion and back/pause behavior.
5. Add only rights-cleared audio, then update the register and credits.
