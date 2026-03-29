shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float glow_size : hint_range(1.0, 20.0) = 6.0;
uniform float glow_intensity : hint_range(0.5, 5.0) = 2.0;
uniform float glow_falloff : hint_range(1.0, 6.0) = 2.0;

void fragment() {
    vec2 uv = UV;
    vec4 tex = texture(TEXTURE, uv);
    
    float glow = 0.0;
    vec2 tex_size = vec2(textureSize(TEXTURE, 0));
    vec2 pixel = 1.0 / tex_size;
    
    int steps = int(glow_size);
    float total_weight = 0.0;
    
    for (int x = -steps; x <= steps; x++) {
        for (int y = -steps; y <= steps; y++) {
            vec2 offset = vec2(float(x), float(y)) * pixel;
            float dist = length(vec2(float(x), float(y)));
            if (dist <= glow_size) {
                float weight = pow(1.0 - (dist / glow_size), glow_falloff);
                glow += texture(TEXTURE, uv + offset).a * weight;
                total_weight += weight;
            }
        }
    }
    
    glow = clamp(glow / max(total_weight * 0.3, 0.001), 0.0, 1.0);
    glow *= glow_intensity;
    
    float glow_mask = glow * (1.0 - tex.a);

    vec4 sprite = tex * COLOR;
    
    vec3 final_rgb = mix(glow_color.rgb * glow_intensity, sprite.rgb, tex.a);
    float final_a = clamp(tex.a + glow_mask * glow_color.a, 0.0, 1.0);
    
    COLOR = vec4(final_rgb, final_a);
}
