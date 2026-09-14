shader_type canvas_item;
render_mode unshaded;
uniform float weapon_tier = 0.0;
uniform float armor_tier = 0.0;
uniform float facing = 1.0;
varying vec2 local_pixel;
void vertex() { local_pixel = VERTEX; }
void fragment() {
	vec4 ink = COLOR;
	float hi = max(ink.r, max(ink.g, ink.b));
	float lo = min(ink.r, min(ink.g, ink.b));
	bool metal = hi-lo < 0.19 && hi > 0.25;
	bool blade = local_pixel.x * facing > 17.0;
	if (metal && armor_tier > 0.0 && !blade) {
		vec3 alloy = armor_tier < 1.5 ? vec3(0.76,0.53,0.30) : armor_tier < 2.5 ? vec3(0.36,0.75,0.79) : vec3(0.95,0.80,0.43);
		ink.rgb = mix(ink.rgb, alloy * (0.35+hi*0.8), 0.72);
	}
	if (metal && blade && weapon_tier > 0.0) {
		vec3 edge = weapon_tier < 1.5 ? vec3(0.35,0.94,0.88) : weapon_tier < 2.5 ? vec3(0.75,0.55,1.0) : vec3(1.0,0.85,0.38);
		ink.rgb = mix(ink.rgb, edge * (0.55+hi*0.65), 0.8);
	}
	// Reactor, visor and joint circuits gain a distinct tier tint on every animation.
	if (ink.g > ink.r*1.2 && ink.b > ink.r*1.1 && armor_tier > 0.0) {
		ink.rgb = mix(ink.rgb, armor_tier > 2.5 ? vec3(1.0,0.82,0.34) : vec3(0.45,0.95,0.94), 0.5);
	}
	COLOR=ink;
}
