extends SceneTree
## Native rendered/audio capture using actual controls; opponent placement is a fixture.
var scene
var recorder: AudioEffectRecord
var recorded: Array[String]=[]
func _initialize() -> void:
 ProjectSettings.set_setting("campaign/persistence_enabled",false)
 call_deferred("review")
func frames(count: int) -> void:
 for i in range(count):await physics_frame
func press(action: String) -> void:
 Input.action_press(action)
 await frames(1)
 Input.action_release(action)
func review() -> void:
 if DisplayServer.get_name()=="headless":
  printerr("Use native graphics and audio for capture")
  quit(1);return
 scene=load("res://scenes/frontier.tscn").instantiate()
 root.add_child(scene)
 root.size=Vector2i(1440,810)
 await frames(10)
 scene.paused=false
 scene.audio.cue_requested.connect(func(kind):recorded.append(kind))
 recorder=AudioEffectRecord.new()
 var effect_index:=AudioServer.get_bus_effect_count(0)
 AudioServer.add_bus_effect(0,recorder)
 recorder.set_recording_active(true)
 for i in range(2):
  scene.hud.interact_button.button_down.emit()
  await frames(1)
  scene.hud.interact_button.button_up.emit()
  await frames(20)
 # A stationary opponent demonstrates real hit feedback, not a synthetic hit event.
 var enemy=scene.sim._spawn_raider()
 enemy.x=scene.knight.position.x+45
 enemy.speed=0
 enemy.fighter.hp=500
 scene.sim.raiders.append(enemy)
 for i in range(8):
  await press("attack")
  await frames(10)
 await press("dash")
 await frames(35)
 scene.paused=true
 scene.sim.raiders.clear()
 await frames(2)
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/tmp/campaign-audio-pause.png")
 recorder.set_recording_active(false)
 var sound=recorder.get_recording()
 assert(sound!=null and sound.data.size()>1000)
 assert(sound.save_to_wav("/tmp/campaign-audio-native.wav")==OK)
 AudioServer.remove_bus_effect(0,effect_index)
 print("PLAYED ",recorded)
 scene.queue_free()
 await frames(3)
 quit()
