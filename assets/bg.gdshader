shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;

void fragment() {
    COLOR = textureLod(screen_texture, SCREEN_UV, 1.2);
	COLOR = vec4(COLOR.x*.6,COLOR.y*.6,COLOR.z*.6,COLOR.a);
}
