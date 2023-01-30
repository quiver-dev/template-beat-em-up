// blending mode functions come from 
// https://godotshaders.com/snippet/blending-modes/
shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

vec4 hard_light(vec4 base, vec4 blend){
	vec4 limit = step(0.5, blend);
	return mix(
			2.0 * base * blend, 1.0 - 2.0 * (1.0 - base) * (1.0 - blend), limit
	);
}

void fragment() {
	vec4 base = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec4 blend = texture(TEXTURE,UV);
	vec4 new_color = hard_light(base, blend);
	COLOR.rgb = new_color.rgb;
	
}
