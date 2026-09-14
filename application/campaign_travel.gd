extends RefCounted
## Continuous fast running has no invulnerability or dash impulse.
var exhausted:=false
var fast_multiplier:=1.65
var drain_per_second:=18.0
func axis(hero, request: float, seconds: float) -> float:
 if seconds<=0 or not is_finite(seconds) or not hero.is_alive():return 0
 if absf(request)<0.9:
  exhausted=false
  return signf(request)
 if hero.attack_remaining>0:return 0
 if exhausted and hero.stamina<hero.stats.max_stamina*0.3:return signf(request)
 exhausted=false
 # Campaign advance already regenerated this tick; cancel it during fast travel.
 var cost: float=(drain_per_second+hero.stats.stamina_regen)*seconds
 if not hero.spend_stamina(cost):
  exhausted=true
  return signf(request)
 return signf(request)*fast_multiplier
