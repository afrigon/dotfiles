precision highp float;

varying vec2 f_src_pos;

uniform sampler2D u_texture;
uniform vec2 u_src_size;

// Bright top-face colors of the F3 profiler pie slices; the darker 3D rim
// and the background key out to transparent.
const float threshold = 0.01;
const vec3 green = vec3(0.275, 0.808, 0.400);
const vec3 orange = vec3(0.925, 0.431, 0.306);
const vec3 pink = vec3(0.894, 0.275, 0.769);
const vec3 brown = vec3(0.800, 0.424, 0.275);
const vec3 gray = vec3(0.275, 0.298, 0.275);

// Text color of the blockEntities percentage entry in the profiler list;
// its presence identifies the expected profiler section.
const vec3 orange_text = vec3(0.914, 0.427, 0.302);

bool near(vec3 a, vec3 b) {
    return all(lessThan(abs(a - b), vec3(threshold)));
}

vec4 keyed(vec2 texel) {
    vec3 rgb = texture2D(u_texture, texel / u_src_size).rgb;

    if (near(rgb, green) || near(rgb, orange) || near(rgb, pink) ||
        near(rgb, brown) || near(rgb, gray)) {
        return vec4(rgb, 1.0);
    }
    return vec4(0.0, 0.0, 0.0, 0.0);
}

// The pie only renders when the blockEntities percentage text is present in
// one of the four profiler list rows; on any other profiler section the
// whole mirror stays transparent instead of showing a partial pie.
bool on_expected_section() {
    for (int row = 0; row < 4; row++) {
        for (int y = 0; y < 7; y++) {
            for (int x = 0; x < 11; x++) {
                vec2 texel = vec2(
                    u_src_size.x - 92.0 + float(x) + 0.5,
                    u_src_size.y - 220.0 + float(row) * 8.0 + float(y) + 0.5);
                if (near(texture2D(u_texture, texel / u_src_size).rgb, orange_text)) {
                    return true;
                }
            }
        }
    }
    return false;
}

// Keying is done per game texel; the four texels around this output pixel
// are then blended bilinearly (premultiplied) so scaled edges come out
// anti-aliased instead of stair-stepped.
void main() {
    if (!on_expected_section()) {
        gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
        return;
    }

    vec2 texel = f_src_pos * u_src_size - 0.5;
    vec2 corner = floor(texel);
    vec2 blend = texel - corner;

    vec4 premultiplied = mix(
        mix(keyed(corner + vec2(0.5, 0.5)), keyed(corner + vec2(1.5, 0.5)), blend.x),
        mix(keyed(corner + vec2(0.5, 1.5)), keyed(corner + vec2(1.5, 1.5)), blend.x),
        blend.y);

    gl_FragColor = vec4(premultiplied.rgb / max(premultiplied.a, 0.001), premultiplied.a);
}
