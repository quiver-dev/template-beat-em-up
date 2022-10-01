shader_type canvas_item;

const vec3 GRAYSCALE_FACTOR = vec3(0.299, 0.587, 0.114);

uniform int number_of_colors: hint_range(2, 256, 1) = 4;
uniform sampler2D gradient: hint_default_white;

// Add booleans for each mask 
uniform bool is_active = true;
uniform bool show_grayscale = false;


void fragment() {
	float active_filter = float(is_active);
	float filter_gray = float(show_grayscale);
	vec4 input_color = texture(TEXTURE, UV);
	
	float band_factor = 1.0 / float(number_of_colors - 1);
	float grayscale = dot(input_color.rgb, GRAYSCALE_FACTOR);
	float banded_color = round(grayscale / band_factor) * band_factor;
	vec3 new_color = 
		texture(gradient, vec2(banded_color, 0.0)).rgb * (1.0 - filter_gray)
		+ vec3(banded_color) * filter_gray
	;
	
	COLOR.rgb = input_color.rgb * (1.0 - active_filter) + new_color * active_filter;
}