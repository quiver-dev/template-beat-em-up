shader_type canvas_item;

// 0 to 1 is in transition, 1 to 2 is out transition
uniform float cutoff : hint_range(0,2.0);
uniform float smooth_size : hint_range(0.01,1.0);
uniform sampler2D mask : hint_default_black;

void fragment(){
	float value = texture(mask, UV).r;
	
	// step will return 0 if we are in an "in" transition and 1 if it is an "out" transition
	float is_out_transition = float(cutoff > 1.0);
	
	// This will keep the actual cutoff value between 0 and 1, always
	float translated_cutoff = cutoff - (1.0 * is_out_transition);
	
	// if we are in an "in" transition smooth size will zero out
	float initial_value = translated_cutoff + smooth_size * is_out_transition;
//	float initial_value = translated_cutoff - 0.1;
	
	// if we are in an "out" transition smooth size will zero out
	float final_value = translated_cutoff + smooth_size * (1.0 - is_out_transition);
//	float final_value = translated_cutoff;
	
	// The first line is to scale factor to take smooth size into account and have 
	// no gaps when fully transitioned, and the second one to offset the proportional factor
	// so that we have no gaps at the beggining of the transition. The actual factor must be 
	// a number between smooth_size and 1.0 - smooth_size, so without any smoothing it will 0 and 1
	float factor = value * (1.0 - smooth_size) + smooth_size;
	
	float alpha = 1.0 - smoothstep(initial_value, final_value, factor);
	COLOR.a *= alpha;
}