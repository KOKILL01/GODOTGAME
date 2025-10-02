shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    vec4 screen_color = texture(screen_texture, SCREEN_UV);

    // Calcula el brillo del pixel actual en pantalla
    float brightness = dot(screen_color.rgb, vec3(0.299, 0.587, 0.114));

    // Si está oscuro, hazlo transparente
    if (brightness < 0.2) {
        COLOR.a = 0.0;
    } else {
        COLOR = color;
    }
}