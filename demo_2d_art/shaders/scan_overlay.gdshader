shader_type canvas_item;

uniform vec4 scan_color : source_color = vec4(0.16, 0.93, 1.0, 0.18);
uniform float line_density = 380.0;
uniform float sweep_speed = 0.09;

void fragment() {
	vec2 uv = UV;
	float scan_lines = 0.5 + 0.5 * sin(uv.y * line_density + TIME * 2.2);
	float sweep = exp(-36.0 * abs(uv.y - fract(TIME * sweep_speed)));
	float vignette = smoothstep(0.86, 0.18, length(uv - vec2(0.5)));
	float intensity = (scan_lines * 0.06 + sweep * 0.16) * vignette;
	COLOR = vec4(scan_color.rgb * intensity, intensity);
}
