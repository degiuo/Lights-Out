shader_type spatial;

// Цвета
uniform vec3 body_color : source_color = vec3(0.15, 0.16, 0.18);   // Тёмный корпус
uniform vec3 panel_color : source_color = vec3(0.55, 0.57, 0.60);   // Светлая панель
uniform float panel_height : hint_range(0.0, 1.0) = 0.35;          // Положение панели
uniform float scratch_amount : hint_range(0.0, 1.0) = 0.15;        // Сила царапин

// Простая псевдослучайная функция и шум
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

void fragment() {
    vec2 uv = UV;
    vec3 col = body_color;

    // Лёгкие царапины
    float scratches = noise(uv * 150.0) * scratch_amount;
    col += scratches * 0.08;

    // Светлая панель в верхней части
    float panel_top = 1.0 - panel_height;
    if (uv.y > panel_top) {
        col = panel_color;
        // Тёмная линия-разделитель под панелью
        if (uv.y < panel_top + 0.02) {
            col = vec3(0.25, 0.25, 0.27);
        }
    }

    // Лёгкое затемнение по краям для объёма
    float edge_dist = distance(uv, vec2(0.5));
    col *= 1.0 - edge_dist * 0.25;

    ALBEDO = col;
    METALLIC = 0.7;   // Металлический
    ROUGHNESS = 0.4;  // Слегка глянцевый
}