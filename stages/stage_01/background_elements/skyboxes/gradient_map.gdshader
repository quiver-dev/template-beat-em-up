shader_type canvas_item;

const vec3 GRAYSCALE_FACTOR = vec3(0.299, 0.587, 0.114);

uniform sampler2D gradient: hint_default_white;

// Add booleans for each mask 
uniform bool is_active = true;
uniform bool show_grayscale = false;


void fragment() {
	float active_filter = float(is_active);
	float filter_gray = float(show_grayscale);
	vec4 input_color = texture(TEXTURE, UV);
	
	vec2 map_value = vec2(dot(input_color.rgb, GRAYSCALE_FACTOR), 0.0);
//	vec2 map_value = vec2(min(input_color.r,min(input_color.g,input_color.b)), 0.0);
	vec3 new_color = 
		texture(gradient, map_value).rgb * (1.0 - filter_gray)
		+ vec3(map_value.x) * filter_gray
	;
	
	COLOR.rgb = input_color.rgb * (1.0 - active_filter) + new_color * active_filter;
}