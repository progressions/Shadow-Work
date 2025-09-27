
// Set sprite based on height
switch(height) {
    case 0: 
        // sprite_index = spr_simple_pillar_low;
		image_index = 0;
        break;
    case 1: 
        // sprite_index = spr_simple_pillar_med;
		image_index = 1;
        break;
    case 2: 
        // sprite_index = spr_simple_pillar_high;
		image_index = 2;
        break;
}

if (highlight_timer > 0) {
    var blend_amount = highlight_timer / highlight_length; // 1 → 0
    image_blend = merge_color(c_white, highlight_color, blend_amount);
    highlight_timer--;
} else {
    image_blend = c_white; // back to normal
}
