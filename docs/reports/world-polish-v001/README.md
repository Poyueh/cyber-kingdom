# World polish v001 — 2026-09-14

Source runtime: 56abfb7. Full tools/check.sh: 1272 behavior assertions, all scene/build/localization/architecture checks, no failures or Godot errors. Mount scene has 10 assertions including both-tier unlock, increased real velocity, rooted first attack, mount art visibility, unchanged checkpoint round-trip, restore and restart, and camera margin at both ends. New rule/transition/tile tests first failed on absent functionality; the extra edge-margin test reproduced the clipped mounted silhouette before correction.

Actual native captures: people.png / mounted.png compare body proportions and mounted hero; edge-left.png / edge-right.png show both map ends with complete horse silhouette and covered terrain; reveal-before/mid/after.png show the same discovered area at 0 / 0.9 / 1.8 seconds. The simulated capture clock freezes gameplay while sampling presentation. Mounted and exploration images are staged checks, not claims of a complete campaign playthrough.

The map is finite; mirrored visual tiles and overscan repair image joins without making gameplay wrap around. Existing NPC drawings and work/idle/walk/hit poses are re-proportioned rather than replaced with another game's artwork. The knight's on-foot proportions and dragon are unchanged. Mounted art: six generated poses, original and prompt preserved under art/characters/mounted-v001.

Limitations: two gallop drawings and three mounted slash drawings remain prototype animation. iPhone real-device touch/performance and full cavalry combat balance need human playtesting. No public Pages, release, or desktop package published this unit.

H5: builds/world-polish-20260914, clean source export 56abfb7. ZIP CRC and SHA256 verified. Same http://127.0.0.1:8797/ origin retained; previous journey list and saved 11/12 wallet loaded correctly. Browser showed the new compact residents, larger payment slots and scene tiles; returned to pause, no warning/error logs. Mounted combat and distant reveal/edge checks were native staged tests, not a browser campaign completion.
