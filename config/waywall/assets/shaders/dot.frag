precision highp float;

varying vec2 f_src_pos;
varying vec4 f_src_rgba;

uniform sampler2D u_texture;
uniform vec2 u_src_size;

// A FILL dot wherever the keyed colour is captured, drawn as the ninbot line's boat dot: a 4x4
// pixel square without its corners. CAPTURE (x, y, w, h) and FILL (r, g, b, a) are defined by
// the Lua that builds this shader.
const float sensitivity = 0.001;
const float grid_size = 4.0;

void main() {
    vec3 rgb = texture2D(u_texture, f_src_pos).rgb;
    vec2 quad_pos = (f_src_pos * u_src_size - CAPTURE.xy) / CAPTURE.zw;
    vec2 cell = floor(quad_pos * grid_size);
    bool corner = (cell.x == 0.0 || cell.x == grid_size - 1.0) &&
                  (cell.y == 0.0 || cell.y == grid_size - 1.0);

    if (distance(rgb, f_src_rgba.rgb) < sensitivity && !corner) {
        gl_FragColor = FILL;
    } else {
        gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
    }
}
