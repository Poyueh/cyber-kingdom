# Dragon frontier v001 verification — 2026-09-14

Runtime/export source: `4e1034a`, tree `cabcbabaa3176ed4aa3fccadc2fd403950753a9b`. Godot 4.7.2 on Apple M3 Pro. Later delivery commits only add evidence and documentation.

- `checks.log`: full tools/check.sh, 1212 behavior assertions plus all scene/build/localization/architecture checks; zero failures or Godot errors.
- New behavior was first observed failing (premature two-gate victory, missing dragon, lost dragon death silhouette), then implemented. Isolated mobile scene uses actual Godot multitouch events, tests independent fingers, payment, crystal toss, cancel on background, rooted attack while dragging, and safe bounds.
- `arrival.png`, `mist.png`, `dragon.png`: real native renderer. Boss screenshot is a staged day-six encounter, not a claim of manually completing an entire journey.
- `balance.log`: fixed simulation with the knight not attacking. Zero guards lose the core after 105.2 s; eight already-positioned guards win after 9.4 s. This tests the value of army support, not difficulty distribution or solo-knight win rate.
- `web-manifest.json`: committed clean export; ZIP CRC and SHA256 verified. Local delivery: builds/dragon-frontier-20260914. Preview: http://127.0.0.1:8797/ .
- H5 browser checks: new-game wilderness arrival, moving spirit, fog rendering, brief drag movement, sword input and pause, opening/closing the in-game guide with the new boss/gesture instructions. 844 × 390 viewport keeps the three combat buttons in bounds, with side letterboxing. Viewport reset afterward. Browser warning/error log empty.

Limitations: no iPhone Safari hardware check, full end-to-end human campaign balancing or performance benchmark. Residents still need recruitment and tools; autonomous hunting requires explored terrain and safe travel time. Four dragon poses are prototype art/animation. Existing checkpoints keep their original map/position; expanded world and wilderness start require a new journey. No online publication or desktop release this unit.
