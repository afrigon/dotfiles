precision highp float;

varying vec2 f_src_pos;
varying vec4 f_src_rgba;
varying vec4 f_dst_rgba;

uniform sampler2D u_texture;
uniform vec2 u_src_size;

const float threshold = 0.01;
// Border thickness in destination pixels; the mirrors render at 8x scale.
const float border_px = 3.0;
const float mirror_scale = 8.0;

// Text color of the blockEntities percentage entry in the profiler list;
// its presence identifies the expected profiler section (same gate as the
// pie shader), so the numbers hide on any other section.
const vec3 orange_text = vec3(0.914, 0.427, 0.302);

bool on_expected_section() {
    for (int row = 0; row < 4; row++) {
        for (int y = 0; y < 7; y++) {
            for (int x = 0; x < 11; x++) {
                vec2 texel = vec2(
                    u_src_size.x - 92.0 + float(x) + 0.5,
                    u_src_size.y - 220.0 + float(row) * 8.0 + float(y) + 0.5);
                vec3 rgb = texture2D(u_texture, texel / u_src_size).rgb;
                if (all(lessThan(abs(rgb - orange_text), vec3(threshold)))) {
                    return true;
                }
            }
        }
    }
    return false;
}

// The mirror captures the first profiler list row's percentage window
// (x = width - 92, w = 11, 8px row pitch, 7px of glyphs), padded by one
// texel on every side to leave room for the border. The entry can sit in
// any of the four list rows, so each sample also tests the same position
// 8/16/24 rows further down; the row that holds the entry's color renders
// at the same output position regardless.
bool keyed(vec2 texel) {
    float column = texel.x - (u_src_size.x - 92.0);
    float row = texel.y - (u_src_size.y - 221.0);
    if (!(column >= 0.0 && column < 11.0 && row >= 1.0 && row < 8.0)) {
        return false;
    }
    for (int band = 0; band < 4; band++) {
        vec2 t = vec2(texel.x, texel.y + float(band) * 8.0);
        vec3 rgb = texture2D(u_texture, t / u_src_size).rgb;
        if (all(lessThan(abs(rgb - f_src_rgba.rgb), vec3(threshold)))) {
            return true;
        }
    }
    return false;
}

void main() {
    if (!on_expected_section()) {
        gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
        return;
    }

    vec2 texel = f_src_pos * u_src_size;

    if (keyed(texel)) {
        gl_FragColor = vec4(f_dst_rgba.rgb, 1.0);
        return;
    }

    float r = border_px / mirror_scale;
    bool edge = keyed(texel + vec2(r, 0.0)) || keyed(texel + vec2(-r, 0.0)) ||
                keyed(texel + vec2(0.0, r)) || keyed(texel + vec2(0.0, -r)) ||
                keyed(texel + vec2(r, r)) || keyed(texel + vec2(-r, r)) ||
                keyed(texel + vec2(r, -r)) || keyed(texel + vec2(-r, -r));

    if (edge) {
        gl_FragColor = vec4(f_dst_rgba.rgb * 0.35, 1.0);
    } else {
        gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
    }
}
