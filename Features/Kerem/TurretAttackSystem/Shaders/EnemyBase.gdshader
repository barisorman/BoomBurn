shader_type canvas_item;

uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0); // Hedef renk (Beyaz)
uniform float flash_modifier : hint_range(0.0, 1.0) = 0.0; // 0 = Normal, 1 = Tamamen Boyalı

void fragment() {
    // Resmin kendi rengini al
    vec4 color = texture(TEXTURE, UV);

    // Resmin rengi ile bizim hedef rengi "karıştır" (mix)
    // mix fonksiyonu, çarpma yapmaz, direkt boyayı üzerine döker.
    color.rgb = mix(color.rgb, flash_color.rgb, flash_modifier);

    // Sonucu ekrana bas
    COLOR = color;
}