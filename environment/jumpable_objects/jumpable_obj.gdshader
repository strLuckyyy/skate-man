shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float outline_thickness : hint_range(0.0, 32.0) = 4.0;
uniform float blur_amount : hint_range(0.0, 16.0) = 2.0;

void fragment() {
    vec2 size = TEXTURE_PIXEL_SIZE * outline_thickness;
    float alpha_accumulator = 0.0;
    float sample_count = 0.0;
    
    // Amostragem em círculo/área ao redor para criar o efeito de expansão e blur
    int samples = 16;
    float radial_steps = 4.0;
    
    for (float r = 1.0; r <= radial_steps; r++) {
        float current_radius = (r / radial_steps) * outline_thickness;
        float angle_step = 6.28318530718 / float(samples);
        
        for (int i = 0; i < samples; i++) {
            float angle = float(i) * angle_step;
            vec2 offset = vec2(cos(angle), sin(angle)) * TEXTURE_PIXEL_SIZE * current_radius * (1.0 + blur_amount * 0.1);
            
            float sampled_alpha = texture(TEXTURE, UV + offset).a;
            alpha_accumulator += sampled_alpha;
            sample_count += 1.0;
        }
    }
    
    float outer_alpha = clamp(alpha_accumulator / sample_count, 0.0, 1.0);
    vec4 original_tex = texture(TEXTURE, UV);
    
    // Remove o miolo interno para sobrar apenas o contorno externo, se desejar, 
    // ou mantém a sprite original por cima. Aqui focamos no contorno expandido:
    float final_alpha = clamp(outer_alpha - original_tex.a, 0.0, 1.0);
    
    // Aplicação da cor e atenuação suave baseada na distância (blur)
    vec3 final_rgb = outline_color.rgb;
    
    // Opcional: Atenua o alfa conforme afasta para dar o efeito "fade out"
    final_alpha *= outline_color.a;

    COLOR = vec4(final_rgb, final_alpha);
    
    // Mistura o contorno por trás da sprite original
    // (Comente a linha abaixo se quiser ver só o contorno)
    COLOR = mix(original_tex, COLOR, 1.0 - original_tex.a);
}