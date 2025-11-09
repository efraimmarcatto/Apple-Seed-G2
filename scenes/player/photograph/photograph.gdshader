shader_type canvas_item;

// O GDScript vai mandar o 'Rect2' do seu frame para esta variável
uniform vec4 hole_rect;
// A cor escura da máscara
uniform vec4 base_color = vec4(0.0, 0.0, 0.0, 0.7);

void fragment() {
    // Pega a coordenada de pixel da tela atual
    vec2 screen_pos = FRAGCOORD.xy;

    // Checa se o pixel está DENTRO do retângulo (do "buraco")
    bool inside_x = screen_pos.x > hole_rect.x && screen_pos.x < hole_rect.x + hole_rect.z;
    bool inside_y = screen_pos.y > hole_rect.y && screen_pos.y < hole_rect.y + hole_rect.w;

    if (inside_x && inside_y) {
        // Se estiver DENTRO, fica 100% transparente
        COLOR.a = 0.0;
    } else {
        // Se estiver FORA, usa a cor escura da máscara
        COLOR = base_color;
    }
}