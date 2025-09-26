
// === DRAW GUI EVENT ===
if (is_open) {
    // Calculate dimensions
    var _slot_size = 64;
    var _padding = 8;
    var _columns = 6;
    var _rows = 2;
    var _border = 8; // Border thickness of your nine-slice
    
    // Content area (just the slots and inner padding)
    var _content_width = (_columns * _slot_size) + ((_columns - 1) * _padding);
    var _content_height = (_rows * _slot_size) + ((_rows - 1) * _padding);
    
    // Total size including borders and outer padding
    var _width = _content_width + (_padding * 2) + (_border * 2);
    var _height = _content_height + (_padding * 2) + (_border * 2);
    
    // Try fixed position first to test
    var _x = 100;
    var _y = 100;
    
    // Draw the nine-slice background
    draw_sprite_stretched(spr_box_frame, 0, _x, _y, _width, _height);
    
    // Get player reference
    var _player = instance_find(obj_player, 0);
    if (_player == noone) exit;
    
    // Draw inventory slots and items
    for (var i = 0; i < _columns * _rows; i++) {
        var _col = i % _columns;
        var _row = floor(i / _columns);
        
        var _slot_x = _x + _border + _padding + (_col * (_slot_size + _padding));
        var _slot_y = _y + _border + _padding + (_row * (_slot_size + _padding));
        
        // Draw slot background
        draw_set_color(c_dkgray);
        draw_set_alpha(0.5);
        draw_rectangle(_slot_x, _slot_y, _slot_x + _slot_size, _slot_y + _slot_size, false);
        draw_set_alpha(1);
        
        // Draw item if it exists
        if (i < array_length(_player.inventory) && _player.inventory[i] != undefined) {
            var _item = _player.inventory[i];
            
// Scale up the item sprite and center it properly
            var _scale = 2; // Scale up 2x for better visibility
			show_debug_message("inventory item " + string(_item));
			
			
            draw_sprite_ext(spr_items, _item.definition.world_sprite_frame, 
                           _slot_x + _slot_size/2, 
                           _slot_y + _slot_size,
                           _scale, _scale, 0, c_white, 1);
            
            
            // Draw stack count if > 1
            if (_item.count > 1) {
                draw_set_color(c_white);
                draw_set_halign(fa_right);
                draw_set_valign(fa_bottom);
                draw_text(_slot_x + _slot_size - 2, _slot_y + _slot_size - 2, string(_item.count));
                draw_set_halign(fa_left);
                draw_set_valign(fa_top);
            }
        }
    }
}