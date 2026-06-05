shader_type spatial;
render_mode unshaded, fog_disabled;

uniform sampler2D screen_texture : hint_screen_texture;
uniform float pixel_size : hint_range(0.0, 20.0, 1.0);
uniform bool enabled = true;

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	vec4 color;

	if (enabled && pixel_size > 0.0) {
		vec2 text_size = vec2(textureSize(screen_texture, 0));
		vec2 pixel_count = text_size / (pixel_size * 2.0);
		vec2 pixelated_uv = floor(SCREEN_UV * pixel_count) / pixel_count;
		color = texture(screen_texture, pixelated_uv);
	} else {
		color = texture(screen_texture, SCREEN_UV);
	}

	ALBEDO = color.rgb;
	ALPHA = color.a;
}