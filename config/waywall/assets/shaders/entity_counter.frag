precision highp float;

varying vec2 f_src_pos;
varying vec4 f_src_rgba;
varying vec4 f_dst_rgba;

uniform sampler2D u_texture;
uniform vec2 u_src_size;

// Same as Toolscreen's E Counter: keyed text in the output colour with a black outline.
// The capture must match the mirror's src in modes.lua; the outline never reaches outside it.
const vec4 capture = vec4(14.0, 38.0, 23.0, 7.0);
const float sensitivity = 0.001;
const int border_width = 2;
const vec4 border_color = vec4(0.0, 0.0, 0.0, 1.0);

bool matches_at(vec2 texel) {
    if (texel.x < capture.x || texel.y < capture.y || texel.x >= capture.x + capture.z ||
        texel.y >= capture.y + capture.w) {
        return false;
    }

    vec3 rgb = texture2D(u_texture, texel / u_src_size).rgb;
    return distance(rgb, f_src_rgba.rgb) < sensitivity;
}

void main() {
    vec2 texel = f_src_pos * u_src_size;

    if (matches_at(texel)) {
        gl_FragColor = vec4(f_dst_rgba.rgb, 1.0);
        return;
    }

    for (int y = -border_width; y <= border_width; y++) {
        for (int x = -border_width; x <= border_width; x++) {
            if (matches_at(texel + vec2(float(x), float(y)))) {
                gl_FragColor = border_color;
                return;
            }
        }
    }

    gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
}
