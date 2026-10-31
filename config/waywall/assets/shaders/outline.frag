#extension GL_OES_standard_derivatives : enable

precision highp float;

varying vec2 f_src_pos;
varying vec4 f_src_rgba;
varying vec4 f_dst_rgba;

uniform sampler2D u_texture;
uniform vec2 u_src_size;

// Keyed pixels in the output colour with an outline measured in screen pixels, so the mirror's
// scale does not thicken it. CAPTURE (x, y, w, h) is defined by the Lua that builds this shader;
// only pixels inside it are keyed, so the mirror's padding shows outline but never other text.
const float sensitivity = 0.001;
const int border_width = 2;
const vec4 border_color = vec4(0.0, 0.0, 0.0, 1.0);

bool matches_at(vec2 texel) {
    if (texel.x < CAPTURE.x || texel.y < CAPTURE.y || texel.x >= CAPTURE.x + CAPTURE.z ||
        texel.y >= CAPTURE.y + CAPTURE.w) {
        return false;
    }

    vec3 rgb = texture2D(u_texture, texel / u_src_size).rgb;
    return distance(rgb, f_src_rgba.rgb) < sensitivity;
}

void main() {
    vec2 texel = f_src_pos * u_src_size;
    vec2 screen_pixel = vec2(abs(dFdx(texel.x)), abs(dFdy(texel.y)));

    if (matches_at(texel)) {
        gl_FragColor = vec4(f_dst_rgba.rgb, 1.0);
        return;
    }

    for (int y = -border_width; y <= border_width; y++) {
        for (int x = -border_width; x <= border_width; x++) {
            if (matches_at(texel + vec2(float(x), float(y)) * screen_pixel)) {
                gl_FragColor = border_color;
                return;
            }
        }
    }

    gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
}
