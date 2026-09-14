# Subtle touch controls — 2026-09-14

Root cause: offering_started previously set only interact_held. Releasing before the next physics tick erased the request. In addition, the left half of the screen was hard-coded to movement. Red scene reproduction: fast right swipe loses payment and left swipe is ignored. After the event-latch fix, only the left-side case failed; direction-based gesture ownership then made both pass.

The existing interact_requested signal retains a one-shot request until physics consumes it. A fresh swipe resets the previous order's held state, so consecutive swipes work even without an intervening idle tick. Continuous hold still fills one transaction only; focus/pause clears pending input. No currency or save-schema changes.

Gestures now start on either side below the HUD and outside action buttons. Horizontal intent owns movement, vertical down owns offering; separate fingers remain independent. No joystick disc/base: a small low-opacity chevron follows the fingertip. Small/ambiguous movement does not pay; a payment stays a payment until release.

Full tools/check.sh passed: 1220 behavior assertions and all scene/build/localization/architecture checks, no Godot errors. Mobile scene: 16 assertions including quick release, consecutive opposite-side payments, no stuck motion and focus cancellation. Native preview shows 12 → 11 crystals after a quick left swipe. Screenshots are actual Godot rendering.

Runtime commit: 42d95ee. Local H5 delivery and browser verification recorded in STATUS. Real iPhone Safari multi-touch remains unverified.

Browser verification: reused http://127.0.0.1:8797/, existing journey list present; resumed a saved knight near camp, quick left downward drag reduced crystal count 12 → 11 and filled one visible camp slot. Returned to pause. Browser warning/error log empty. This mouse-emulated touch check does not replace iPhone multi-touch testing.
