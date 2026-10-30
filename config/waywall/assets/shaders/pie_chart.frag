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

// FXAA 3.11 quality tuning. Edges are searched in game pixels because the
// stair-steps come from the game drawing the pie without anti-aliasing.
const float edge_threshold_min = 0.0312;
const float edge_threshold_max = 0.125;
const float subpixel_quality = 0.75;
const int edge_search_steps = 12;
const vec3 luma_weights = vec3(0.299, 0.587, 0.114);

// Keying is done per game texel; the four texels around a position are then
// blended bilinearly (premultiplied) so the keyed edge has partial coverage.
vec4 bilinear(vec2 position) {
    vec2 texel = position - 0.5;
    vec2 corner = floor(texel);
    vec2 blend = texel - corner;

    return mix(
        mix(keyed(corner + vec2(0.5, 0.5)), keyed(corner + vec2(1.5, 0.5)), blend.x),
        mix(keyed(corner + vec2(0.5, 1.5)), keyed(corner + vec2(1.5, 1.5)), blend.x),
        blend.y);
}

// Premultiplied, so the circle's edge against the transparent background
// reads as contrast just like the edges between slices.
float luma(vec2 position) {
    return dot(bilinear(position).rgb, luma_weights);
}

float edge_search_step(int index) {
    if (index < 5) {
        return 1.0;
    }

    if (index == 5) {
        return 1.5;
    }

    if (index < 10) {
        return 2.0;
    }

    if (index == 10) {
        return 4.0;
    }

    return 8.0;
}

vec4 fxaa(vec2 position) {
    float luma_center = luma(position);
    float luma_down = luma(position + vec2(0.0, -1.0));
    float luma_up = luma(position + vec2(0.0, 1.0));
    float luma_left = luma(position + vec2(-1.0, 0.0));
    float luma_right = luma(position + vec2(1.0, 0.0));

    float luma_min = min(luma_center, min(min(luma_down, luma_up), min(luma_left, luma_right)));
    float luma_max = max(luma_center, max(max(luma_down, luma_up), max(luma_left, luma_right)));
    float luma_range = luma_max - luma_min;

    if (luma_range < max(edge_threshold_min, luma_max * edge_threshold_max)) {
        return bilinear(position);
    }

    float luma_down_left = luma(position + vec2(-1.0, -1.0));
    float luma_up_right = luma(position + vec2(1.0, 1.0));
    float luma_up_left = luma(position + vec2(-1.0, 1.0));
    float luma_down_right = luma(position + vec2(1.0, -1.0));

    float luma_down_up = luma_down + luma_up;
    float luma_left_right = luma_left + luma_right;
    float luma_left_corners = luma_down_left + luma_up_left;
    float luma_down_corners = luma_down_left + luma_down_right;
    float luma_right_corners = luma_down_right + luma_up_right;
    float luma_up_corners = luma_up_right + luma_up_left;

    float edge_horizontal = abs(-2.0 * luma_left + luma_left_corners) +
                            abs(-2.0 * luma_center + luma_down_up) * 2.0 +
                            abs(-2.0 * luma_right + luma_right_corners);
    float edge_vertical = abs(-2.0 * luma_up + luma_up_corners) +
                          abs(-2.0 * luma_center + luma_left_right) * 2.0 +
                          abs(-2.0 * luma_down + luma_down_corners);
    bool is_horizontal = edge_horizontal >= edge_vertical;

    float luma_negative = is_horizontal ? luma_down : luma_left;
    float luma_positive = is_horizontal ? luma_up : luma_right;
    float gradient_negative = luma_negative - luma_center;
    float gradient_positive = luma_positive - luma_center;
    float gradient_scaled = 0.25 * max(abs(gradient_negative), abs(gradient_positive));

    vec2 across = is_horizontal ? vec2(0.0, 1.0) : vec2(1.0, 0.0);
    vec2 along = is_horizontal ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    float luma_local_average = 0.5 * (luma_positive + luma_center);

    if (abs(gradient_negative) >= abs(gradient_positive)) {
        across = -across;
        luma_local_average = 0.5 * (luma_negative + luma_center);
    }

    vec2 edge = position + across * 0.5;
    vec2 end_negative = edge - along;
    vec2 end_positive = edge + along;
    float luma_end_negative = luma(end_negative) - luma_local_average;
    float luma_end_positive = luma(end_positive) - luma_local_average;
    bool reached_negative = abs(luma_end_negative) >= gradient_scaled;
    bool reached_positive = abs(luma_end_positive) >= gradient_scaled;

    for (int i = 1; i < edge_search_steps; i++) {
        if (reached_negative && reached_positive) {
            break;
        }

        if (!reached_negative) {
            end_negative -= along * edge_search_step(i);
            luma_end_negative = luma(end_negative) - luma_local_average;
            reached_negative = abs(luma_end_negative) >= gradient_scaled;
        }

        if (!reached_positive) {
            end_positive += along * edge_search_step(i);
            luma_end_positive = luma(end_positive) - luma_local_average;
            reached_positive = abs(luma_end_positive) >= gradient_scaled;
        }
    }

    float distance_negative = dot(position - end_negative, along);
    float distance_positive = dot(end_positive - position, along);
    bool negative_closer = distance_negative < distance_positive;
    float distance_closest = min(distance_negative, distance_positive);
    float edge_length = distance_negative + distance_positive;
    float luma_end = negative_closer ? luma_end_negative : luma_end_positive;
    bool center_darker = luma_center < luma_local_average;
    float edge_offset = (luma_end < 0.0) != center_darker ? 0.5 - distance_closest / edge_length : 0.0;

    float luma_average = (2.0 * (luma_down_up + luma_left_right) + luma_left_corners + luma_right_corners) / 12.0;
    float subpixel_contrast = clamp(abs(luma_average - luma_center) / luma_range, 0.0, 1.0);
    float subpixel_smooth = (-2.0 * subpixel_contrast + 3.0) * subpixel_contrast * subpixel_contrast;
    float subpixel_offset = subpixel_smooth * subpixel_smooth * subpixel_quality;

    return bilinear(position + across * max(edge_offset, subpixel_offset));
}

void main() {
    if (!on_expected_section()) {
        gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
        return;
    }

    vec4 premultiplied = fxaa(f_src_pos * u_src_size);
    gl_FragColor = vec4(premultiplied.rgb / max(premultiplied.a, 0.001), premultiplied.a);
}
