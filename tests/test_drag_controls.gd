extends RefCounted
func test_drag_fingers_are_independent_and_cancelable(t):
 var path="res://presentation/drag_state.gd"
 t.truth(ResourceLoader.exists(path),"drag controls have a testable gesture owner")
 if not ResourceLoader.exists(path):return
 var state=load(path).new()
 state.begin(1,Vector2(100,300))
 state.drag(1,Vector2(160,300))
 t.equal(state.axis,0.65,"rightward drag moves right")
 state.begin(2,Vector2(700,220))
 t.truth(state.drag(2,Vector2(700,275)),"downward drag begins offering")
 t.equal(state.axis,0.65,"offering does not cancel movement finger")
 t.truth(not state.drag(2,Vector2(700,300)),"same drag cannot repeatedly fire new offerings")
 state.finish(2);t.equal(state.axis,0.65,"lifting offering finger preserves movement")
 state.drag(1,Vector2(45,300));t.equal(state.axis,-0.65,"same finger can reverse direction")
 state.cancel();t.equal(state.axis,0.0,"pause or focus loss releases movement")
 t.truth(not state.drag(1,Vector2(160,300)),"old finger cannot resume after cancellation")

func test_direction_selects_intent_on_either_side(t):
 var state=load("res://presentation/drag_state.gd").new()
 state.begin(1,Vector2(160,220))
 t.truth(not state.drag(1,Vector2(166,232)),"small diagonal movement is not payment")
 t.truth(state.drag(1,Vector2(168,252)),"left-side downward intent pays without lateral drift")
 t.equal(state.axis,0.0,"vertical intent does not move knight")
 state.drag(1,Vector2(240,270))
 t.equal(state.axis,0.0,"payment cannot turn into movement before release")
 state.begin(2,Vector2(700,220));state.drag(2,Vector2(640,220))
 t.equal(state.axis,-0.65,"right-side horizontal swipe moves left independently")
 state.finish(1);t.equal(state.axis,-0.65,"payment release keeps second thumb moving")
 state.drag(2,Vector2(696,270))
 t.equal(state.axis,0.0,"turning movement into deliberate down swipe stops its movement")
 t.equal(state.offer_finger,2,"movement thumb can become payment thumb")
