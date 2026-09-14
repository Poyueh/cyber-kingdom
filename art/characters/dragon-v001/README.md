# Dragon v001

Original art generated with the built-in image generation tool for Cyber Kingdom on 2026-09-14. The retained source is a transparent 1254 × 1254 PNG with four poses of one side-view dragon: dark purple wings, brass mechanical armour, cyan dragon-crystal channels and orange breath. No third-party game artwork was used as an input.

`source.png` retains the generated image. `dragon.png` is the runtime sheet: four 256 × 208 frames. `tools/prepare_dragon_art.py` extracts the four connected silhouettes, removes stray pixels, scales with nearest-neighbour, limits each pose to 48 colours and aligns feet at y=204. Pillow/numpy are development-only dependencies; original preservation and local processing were authorized by the user.

Presentation selects breathing/wing poses from the paused simulation clock and uses the fourth pose for charged breath. These are four prototype poses, not a finished locomotion animation set. Death and hit flashes preserve the dragon silhouette independently of combat invulnerability.
