#extension GL_OES_standard_derivatives : enable

precision highp float;

varying vec2 f_src_pos;
varying vec4 f_src_rgba;

uniform sampler2D u_texture;
uniform vec2 u_src_size;

// A FILL circle inscribed in the mirror wherever the keyed colour is captured. CAPTURE (x, y, w, h)
// and FILL (r, g, b, a) are defined by the Lua that builds this shader.
const float sensitivity = 0.001;
const float radius = 0.5;

void main() {
    vec3 rgb = texture2D(u_texture, f_src_pos).rgb;

    if (distance(rgb, f_src_rgba.rgb) >= sensitivity) {
        gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
        return;
    }

    vec2 quad_pos = (f_src_pos * u_src_size - CAPTURE.xy) / CAPTURE.zw;
    float center_distance = distance(quad_pos, vec2(0.5));
    float edge = fwidth(center_distance);
    float coverage = 1.0 - smoothstep(radius - edge, radius, center_distance);

    gl_FragColor = vec4(FILL.rgb, FILL.a * coverage);
}
