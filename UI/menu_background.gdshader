shader_type canvas_item;

// Variáveis que você pode controlar pelo painel (Inspector)
uniform float aspect = 1.0;
uniform float velocidade = 0.5; 
uniform vec2 direcao = vec2(1.0, 0.0); // 1.0 no X faz a textura ir da direita para a esquerda

void fragment() {
    // Desloca as coordenadas da textura (UV) ao longo do tempo
    vec2 movimento = direcao * TIME * velocidade;
	
    COLOR = texture(TEXTURE, UV + movimento);
	COLOR.a = aspect;
}