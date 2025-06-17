shader_type spatial;
render_mode cull_disabled, depth_draw_opaque, depth_prepass_alpha;

uniform sampler2D leaf_texture;
uniform sampler2D noise_texture;

uniform float sway_speed = 1.0;
uniform float sway_strength = 0.1;
uniform float noise_strength = 0.05;
uniform float noise_scale = 1.5;
uniform float alpha_cutoff = 0.1;

// INSTANCE_CUSTOM: x = sway phase offset, y = height scale, z = unused, w = unused

void vertex() {
    // Billboard quad
    mat3 billboard = mat3(MODELVIEW_MATRIX);
    billboard[1] = vec3(0.0, 1.0, 0.0);
    billboard[0] = normalize(cross(billboard[1], billboard[2]));
    billboard[2] = normalize(cross(billboard[0], billboard[1]));

    VERTEX = billboard * VERTEX;

    // Apply height scale (from INSTANCE_CUSTOM.y)
    VERTEX.y *= INSTANCE_CUSTOM.y;

    // Sway using sine wave + instance phase offset
    float sway_phase = INSTANCE_CUSTOM.x;
    float sway = sin(TIME * sway_speed + sway_phase);
    VERTEX.x += sway * sway_strength;

    // Scrolling wind noise
    vec2 noise_uv = UV * noise_scale + vec2(TIME * 0.1, TIME * 0.1);
    float wind_noise = texture(noise_texture, noise_uv).r;
    VERTEX.x += (wind_noise - 0.5) * noise_strength;
}

void fragment() {
    vec4 tex = texture(leaf_texture, UV);
    ALBEDO = tex.rgb;
    ALPHA = tex.a;
    ALPHA_SCISSOR_THRESHOLD = alpha_cutoff;

    // Fake a hard light direction (e.g. sun from above)
    float light_strength = dot(NORMAL, normalize(vec3(0.3, 1.0, 0.5)));
    light_strength = clamp(light_strength, 0.0, 1.0);
    light_strength = step(0.5, light_strength); // stylized step lighting

    ALBEDO *= light_strength; // simulate shadow
}
