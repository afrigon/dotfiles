precision highp float;

varying vec2 f_src_pos;

uniform sampler2D u_texture;

// Same matching as Toolscreen's Pie mirror: exact slice colours pass through, everything else is transparent.
const float sensitivity = 0.001;
const vec3 green = vec3(70.0, 206.0, 102.0) / 255.0;
const vec3 orange = vec3(236.0, 110.0, 78.0) / 255.0;
const vec3 pink = vec3(228.0, 70.0, 196.0) / 255.0;
const vec3 brown = vec3(204.0, 108.0, 70.0) / 255.0;
const vec3 gray = vec3(70.0, 76.0, 70.0) / 255.0;

bool is_slice(vec3 rgb) {
    return distance(rgb, green) < sensitivity || distance(rgb, orange) < sensitivity ||
           distance(rgb, pink) < sensitivity || distance(rgb, brown) < sensitivity ||
           distance(rgb, gray) < sensitivity;
}

void main() {
    vec3 rgb = texture2D(u_texture, f_src_pos).rgb;

    if (is_slice(rgb)) {
        gl_FragColor = vec4(rgb, 1.0);
    } else {
        gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
    }
}
