shader_type spatial;
render_mode skip_vertex_transform, diffuse_lambert_wrap, specular_disabled, ambient_light_disabled;

uniform vec2 jitter_resolution = vec2(640.0, 480.0);
uniform float affine_texture_intensity: hint_range(0.0, 1.0) = 1.0;
uniform sampler2D albedo_texture: source_color, filter_nearest;
uniform vec4 colot_tint: source_color = vec4(1.0);

varying float vertex_distance;


void vertex() {
	// Called for every vertex the material is visible on.
	vec4 clip_position = PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
	vec2 transformed_pos = clip_position.xy / clip_position.w;
	transformed_pos = floor(transformed_pos * jitter_resolution) / jitter_resolution;
	clip_position.xy = transformed_pos * clip_position.w;

	POSITION = clip_position;

	vertex_distance = clip_position.w;
	UV *= vertex_distance * affine_texture_intensity;
}

void fragment() {
	// Called for every pixel the material is visible on.

	vec2 affine_uv = UV / (vertex_distance * affine_texture_intensity);

	vec4 tex_color = texture(albedo_texture, affine_uv);
	ALBEDO = tex_color.rgb * colot_tint.rgb;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
