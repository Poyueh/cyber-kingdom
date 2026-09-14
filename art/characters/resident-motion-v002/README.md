# Resident motion v002

Original project characters; costume study generated using the built-in image_gen tool, with prosthetic-v001/citizens-atlas.png as an identity reference. Complete prompt: sources/prompt.txt. Raw generated study: sources/walk-study.png. The tool produced a baked checkerboard and repeated poses; these were not accepted as a finished animation.

The project owner previously explicitly authorized local Python background cleanup and animation-cell correction. tools/prepare_resident_motion.py preserves the source, removes the connected checkerboard, retains costume pixels and articulates new planted-foot leg and free-arm motion. Engineer costume uses the existing project engineer atlas. No external recordings or downloaded third-party sprite packs.

Runtime: residents.png, 512 × 768, 64 × 64 cells; eight columns, walk then idle row for wanderer/citizen/farmer/hunter/guard/engineer. Lossless, no mipmaps, project nearest-neighbor filter. sources/walk-contact.png and sources/walk-preview.gif are art inspection artifacts; the actual game capture is in docs/reports/frontier-life-v001/residents.mp4.

Requires local Pillow and numpy only for rebuilding the atlas. Runtime uses Godot alone. Idle has eight timing positions but deliberately repeats a small number of breathing poses. Specialized engineer work/haul/climb uses the earlier atlas. This is a revision for playtesting, not a claim of final animation quality.
