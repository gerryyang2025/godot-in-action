shader_type canvas_item;

uniform vec4 scan_color : source_color = vec4(0.16, 0.93, 1.0, 0.15);
uniform float line_density = 380.0;
uniform float sweep_speed = 0.09;
uniform float vignette_strength = 0.52;

void fragment() {
	vec2 uv = UV;
	float scan_lines = 0.5 + 0.5 * sin(uv.y * line_density + TIME * 2.2);
	float sweep = exp(-36.0 * abs(uv.y - fract(TIME * sweep_speed)));
	float vignette = smoothstep(0.92, 0.18, length(uv - vec2(0.5))) * vignette_strength;
	float intensity = max(0.0, (scan_lines * 0.05 + sweep * 0.13) * vignette);
	COLOR = vec4(scan_color.rgb * intensity, intensity);
}
