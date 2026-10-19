shader_type canvas_item;

uniform sampler2D screen_tex : hint_screen_texture, filter_nearest;

// === ПИКСЕЛИЗАЦИЯ (основной эффект) ===
uniform float pixel_size : hint_range(1.0, 8.0) = 3.0; // Чем больше — тем крупнее пиксели

// === ЛЁГКИЙ VHS (едва заметный) ===
uniform float noise_strength : hint_range(0.0, 0.1) = 0.015;  // Легкое зерно
uniform float vignette_strength : hint_range(0.0, 0.8) = 0.35; // Затемнение по краям
uniform float scanline_strength : hint_range(0.0, 0.05) = 0.008; // Едва заметные полосы
uniform float chroma_offset : hint_range(0.0, 0.01) = 0.0015; // Очень слабое цветное смещение

float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    // 1. Пикселизация: округляем UV до ближайшего "пикселя"
    vec2 pixelated_uv = floor(SCREEN_UV / (pixel_size * SCREEN_PIXEL_SIZE)) 
                       * (pixel_size * SCREEN_PIXEL_SIZE);
    
    // 2. Лёгкое хроматическое смещение (VHS)
    vec2 offset = (pixelated_uv - 0.5) * chroma_offset;
    float r = texture(screen_tex, pixelated_uv + offset).r;
    float g = texture(screen_tex, pixelated_uv).g;
    float b = texture(screen_tex, pixelated_uv - offset).b;
    vec3 col = vec3(r, g, b);
    
    // 3. Лёгкие сканлайны
    float scanline = sin(pixelated_uv.y * 800.0) * 0.5 + 0.5;
    col *= 1.0 - scanline * scanline_strength;
    
    // 4. Лёгкое зерно
    float noise = (rand(pixelated_uv * TIME * 30.0) - 0.5) * 2.0 * noise_strength;
    col += noise;
    
    // 5. Виньетка
    float dist = distance(pixelated_uv, vec2(0.5));
    float vignette = smoothstep(0.55, 0.95, dist);
    col *= 1.0 - vignette * vignette_strength;
    
    COLOR = vec4(col, 1.0);
}