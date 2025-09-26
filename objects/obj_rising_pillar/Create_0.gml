
y_offset = (1 + height) * 4; // 4, 8, or 12 pixels

// Set sprite based on height
switch(height) {
    case 0: 
        sprite_index = spr_rising_pillar_low;
        break;
    case 1: 
        sprite_index = spr_rising_pillar_med;
        break;
    case 2: 
        sprite_index = spr_rising_pillar_high;
        break;
}

depth = -bbox_bottom;