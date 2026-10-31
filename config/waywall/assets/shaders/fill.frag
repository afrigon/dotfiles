precision highp float;

varying vec2 f_src_pos;
varying vec4 f_src_rgba;

uniform sampler2D u_texture;

// Covers the whole mirror in FILL wherever the keyed colour is captured. FILL (r, g, b, a) is
// defined by the Lua that builds this shader.
const float sensitivity = 0.001;

void main() {
    vec3 rgb = texture2D(u_texture, f_src_pos).rgb;

    if (distance(rgb, f_src_rgba.rgb) < sensitivity) {
        gl_FragColor = FILL;
    } else {
        gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
    }
}
