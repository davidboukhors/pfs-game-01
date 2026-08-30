# Release manifest — PFS Game 01

Status: prototype/vertical-slice draft; not a publication candidate.

| Field | Value |
| --- | --- |
| Repository | `git@github.com:davidboukhors/pfs-game-01.git` |
| Branch | `codex/game-01-foundation` |
| Version/build | `0.1.0+1` |
| Flutter/Dart | 3.38.9 / 3.10.8 stable |
| Platforms | iOS no-code-sign build passed; Android debug APK build passed |
| Content | Six levels, FR/EN, local save, settings, credits |
| Audio ledger | No embedded audio; ZapSplat integration deferred |
| Known-good rollback | `foundation-v0.1.0` after clean commit; branch remains isolated |
| Publication | Not authorized; no store upload or release push |

## Rollback note

The working branch remains isolated from `main`. A candidate regression must be
handled from a recorded clean tag or commit; no reset-hard, force push or
rebase is allowed.
