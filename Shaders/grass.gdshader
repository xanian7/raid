shader_type spatial;
render_mode cull_disabled, depth_draw_opaque, depth_prepass_alpha;

uniform sampler2D grass_texture;


void vertex() {
	mat4 modified_model_view = VIEW_MATRIX * mat4(
		INV_VIEW_MATRIX[0],
		INV_VIEW_MATRIX[1],
		INV_VIEW_MATRIX[2],
		MODEL_MATRIX[3]
	);
	MODELVIEW_MATRIX = modified_model_view;
}

void fragment() {
	vec4 tex = texture(grass_texture, UV);
	if (tex.a < 0.1) discard;
	ALBEDO = vec3(0.0, 0.1, 0.0);;
	ALPHA = tex.a;
}

void light() {
    float shadow = ATTENUATION;
    DIFFUSE_LIGHT = shadow * ALBEDO * LIGHT_COLOR;
}