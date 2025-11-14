shader_type canvas_item;

uniform vec2 scroll_speed = vec2(10.0, 20.0); // pixels por segundo

void vertex() {
	// quanto a textura deve mover em pixels
	float t = TIME;

	// deslocamento contínuo (pixel-based)
	vec2 pixel_offset = scroll_speed * t;

	// converte para deslocamento em UV
	// TEXTURE_PIXEL_SIZE = 1 / tamanho da textura em px
	vec2 uv_offset = pixel_offset * TEXTURE_PIXEL_SIZE;

	// UV que se move apenas em múltiplos de 1 pixel → SUAVE EM PIXEL ART
	UV = UV + uv_offset;
}