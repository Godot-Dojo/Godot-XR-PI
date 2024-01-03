// Courtesey of https://www.reddit.com/r/godot/comments/14j0i8g/quick_custom_shader_in_6_lines_of_code_screenshot/
shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled;
void fragment() {
	ALPHA = 0.5;
	vec3 curve = vec3(3.0, 20.0, 7.0);
	ALBEDO = pow(vec3(1.0 - abs(dot(VIEW, NORMAL))), curve) * 1.5;

}
