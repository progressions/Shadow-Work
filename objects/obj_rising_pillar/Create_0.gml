
y_offset = -(4 + (height * 2));

// Set sprite based on height
switch(height) {
    case 0: 
        sprite_index = spr_simple_pillar_low;
		image_index = 0;
        break;
    case 1: 
        sprite_index = spr_simple_pillar_med;
		image_index = 1;
        break;
    case 2: 
        sprite_index = spr_simple_pillar_high;
		image_index = 2;
        break;
}


image_speed = 0 ;
depth = -bbox_bottom;depth = -bbox_bottom;


just_stepped_up = false;