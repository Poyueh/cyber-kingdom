# Knight motion v005

Generated for Cyber Kingdom with OpenAI image generation, 2026-09-14. Original knight identity referenced from this project's combo-v004; no external game sprites copied. Original prompt and RGB source retained.

`tools/prepare_flat_combat.py` performs the user-authorized local transparency cleanup, frame alignment and pose sequencing. `planted.png` contains 3 × 8 frames, each 160 × 128. The generated thrust row was excluded from the game in favor of an overhead heavy cut. Frame timing remains editable in `data/knight_combo_motion.tres`.

`run.png` reuses the existing eight run drawings, replaces the forward exposed blade with a trailing blade, and preserves the original locomotion cells (128 × 96). The visual adapter swaps the atlas without modifying user-edited frame timings.

No claim of legal exclusivity is made for generated art. These are current prototype animations; final hand animation polish remains iterative.
