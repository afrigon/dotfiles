precision highp float;

varying vec2 f_src_pos;
varying vec4 f_src_rgba;
varying vec4 f_dst_rgba;

uniform sampler2D u_texture;
uniform vec2 u_src_size;

const float threshold = 0.01;
// The capture starts at the first digit of the F3 entity line ("E: " is
// 14px wide); every glyph from there advances 6px until the comma after
// the total.
const float text_left = 14.0;
const float text_top = 37.0;

bool keyed_at(vec2 texel) {
    vec3 rgb = texture2D(u_texture, texel / u_src_size).rgb;
    return all(lessThan(abs(rgb - f_src_rgba.rgb), vec3(threshold)));
}

int cell_pixel_count(int cell) {
    int count = 0;
    for (int y = 0; y < 9; y++) {
        for (int x = 0; x < 6; x++) {
            vec2 texel = vec2(
                text_left + float(cell * 6 + x) + 0.5,
                text_top + float(y) + 0.5);
            if (keyed_at(texel)) {
                count++;
            }
        }
    }
    return count;
}

// Digits have 12+ lit pixels per 6px cell and '/' has 7, but the comma that
// ends "12/64, B: ..." has only 2. Everything from the comma cell rightward
// is masked so the mirror always shows exactly "count/total".
void main() {
    vec2 texel = f_src_pos * u_src_size;
    int cell = int(floor((texel.x - text_left) / 6.0));

    for (int j = 0; j < 8; j++) {
        if (j > cell) {
            break;
        }
        if (cell_pixel_count(j) <= 4) {
            gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
            return;
        }
    }

    if (keyed_at(texel)) {
        gl_FragColor = vec4(f_dst_rgba.rgb, 1.0);
    } else {
        gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
    }
}
