extends Node
const Cues=preload("res://presentation/campaign_audio_cues.gd")
const SOUNDS={
 "slash1":preload("res://art/audio/campaign-v001/slash1.wav"),"slash2":preload("res://art/audio/campaign-v001/slash2.wav"),"slash3":preload("res://art/audio/campaign-v001/slash3.wav"),
 "hit":preload("res://art/audio/campaign-v001/hit.wav"),"heavy":preload("res://art/audio/campaign-v001/heavy.wav"),"hurt":preload("res://art/audio/campaign-v001/hurt.wav"),"dash":preload("res://art/audio/campaign-v001/dash.wav"),
 "pickup":preload("res://art/audio/campaign-v001/pickup.wav"),"pay":preload("res://art/audio/campaign-v001/pay.wav"),"chest":preload("res://art/audio/campaign-v001/chest.wav"),"recruit":preload("res://art/audio/campaign-v001/recruit.wav"),"build":preload("res://art/audio/campaign-v001/build.wav"),
 "night":preload("res://art/audio/campaign-v001/night.wav"),"seal":preload("res://art/audio/campaign-v001/seal.wav"),"victory":preload("res://art/audio/campaign-v001/victory.wav"),"defeat":preload("res://art/audio/campaign-v001/defeat.wav")}
## Emitted when feedback is accepted; headless validates commands without starting a mixer.
signal cue_requested(kind: String)
@export_range(-40.0,0.0,1.0) var volume_db: float=-10.0
@export var enabled:=true:
 set(value):
  enabled=value
  if not enabled:stop()
var cues=Cues.new()
var voices: Array[AudioStreamPlayer]=[]
var _cooldowns: Dictionary={}
func _ready() -> void:
 for i in range(6):
  var voice=AudioStreamPlayer.new()
  add_child(voice)
  voices.append(voice)
func observe(seconds: float,sim,x: float,paused: bool) -> void:
 for key in _cooldowns:_cooldowns[key]=maxf(0,_cooldowns[key]-seconds)
 var pending: Array[String]=cues.sample(sim,x,paused or not enabled)
 if paused or not enabled:
  stop()
  return
 for kind in pending:_play(kind)
func _play(kind: String) -> void:
 if _cooldowns.get(kind,0.0)>0:return
 var available=voices.filter(func(v):return not v.playing)
 if available.is_empty():
  # Small pickups cannot cut off a sword hit, danger cue, or result.
  if kind in ["pickup","pay"]:return
  available=[voices[0]]
 var voice: AudioStreamPlayer=available[0]
 voice.stop()
 voice.stream=SOUNDS[kind]
 voice.volume_db=volume_db
 if DisplayServer.get_name()!="headless":voice.play()
 voices.erase(voice);voices.append(voice)
 _cooldowns[kind]=0.08 if kind in ["pickup","hit","heavy"] else 0.05
 cue_requested.emit(kind)
func stop() -> void:
 for voice in voices:voice.stop()

func _exit_tree() -> void:
 stop()
 for voice in voices:voice.stream=null
 cues=null
