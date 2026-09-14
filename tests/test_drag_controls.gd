extends RefCounted
func test_drag_fingers_are_independent_and_cancelable(t):
 var path="res://presentation/drag_state.gd"
 t.truth(ResourceLoader.exists(path),"drag controls have a testable gesture owner")
 if not ResourceLoader.exists(path):return
 var state=load(path).new()
 state.begin(1,Vector2(100,300),true)
 state.drag(1,Vector2(160,300))
 t.equal(state.axis,1.0,"rightward drag moves right")
 state.begin(2,Vector2(700,220),false)
 t.truth(state.drag(2,Vector2(700,275)),"downward drag begins offering")
 t.equal(state.axis,1.0,"offering does not cancel movement finger")
 t.truth(not state.drag(2,Vector2(700,300)),"same drag cannot repeatedly fire new offerings")
 state.finish(2);t.equal(state.axis,1.0,"lifting offering finger preserves movement")
 state.drag(1,Vector2(45,300));t.equal(state.axis,-1.0,"same finger can reverse direction")
 state.cancel();t.equal(state.axis,0.0,"pause or focus loss releases movement")
 t.truth(not state.drag(1,Vector2(160,300)),"old finger cannot resume after cancellation")
