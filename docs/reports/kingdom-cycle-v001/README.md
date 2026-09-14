# Kingdom cycle delivery evidence

Runtime source commit: `de83023`; source tree `3b561b1f2cd401f3082760c150e8161ae5c7d840`. The next evidence-only commit adds external package tests and these reports; it does not change packaged game code.

- Full check: 1,400 Godot assertions and 10 Python tests, no failures or SCRIPT ERROR.
- Native physics normal-budget routes: seed 1 / knight victory in 1287.6 seconds; seed 7 / residents victory in 999.8 seconds. No grants; knight HP damage 0 on both routes, resident losses 1 and 0. These results expose an easy automated combat profile, not balanced difficulty.
- New packaged-feature harness: 17 assertions passed, loading only the actual macOS PCK from outside the source project. Independent manual save, reopen/load, audio preferences, stamina costs, scenery, source exclusions and platform HUD verified.
- Existing packaged regression harness passed settlement, defense, recruitment, guide, mission reset and autosave checks.
- Actual macOS executable started in native graphics and headless modes. Forced native `--quit-after` exits report two audio objects (AudioStreamWAV / AudioStreamPlaybackWAV) remaining at process teardown; the scene-free/await harness exits cleanly. No runtime script errors observed. This teardown warning remains recorded; it is not evidence of growing gameplay memory usage.
- ZIP integrity and macOS ad-hoc signature verification passed; Windows executable is x86-64 PE. Windows actual gameplay has not been tested on a Windows computer.
- Android ARM64 debug APK passed 16 KB zip alignment and v2/v3 signature verification. This iteration has not been played on an Android device or iPhone. It is not an App Store submission.
- Generated music is original deterministic synthesis. Native mixed recording: 2.763 seconds, peak 0.155, RMS 0.0213 (normalized PCM); actual sword, payment and build cues observed. No claim of subjective music-quality approval.

Screenshots of clearance, equipment and gate births are staged visual fixtures. Playthrough JSON files are the separate normal-budget evidence. Artwork crops remove generated neutral background islands, not third-party art. Equipment tiers are recolors, not new armor silhouettes.
