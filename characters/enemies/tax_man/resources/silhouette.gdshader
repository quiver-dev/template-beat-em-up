shader_type canvas_item;

uniform vec4 color : source_color;
uniform float effect_strength: hint_range(0.0, 1.0) = 0;

void fragment(){
	float inverse_strength = 1.0 - effect_strength;
	
	vec4 sample = texture(TEXTURE, UV);
	COLOR.rgb = (effect_strength * color.rgb) + (inverse_strength * sample.rgb);
	COLOR.a = sample.a;
}
