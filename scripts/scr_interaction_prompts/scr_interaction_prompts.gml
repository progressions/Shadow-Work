/// Interaction prompt helper functions for displaying input-aware prompts
///
/// These functions integrate with the Input library's icon system to show
/// the correct button/key based on player's current input device

/// @function show_interaction_prompt_verb(radius, offset_x, offset_y, verb, action)
/// @description Display interaction prompt with Input verb icon (gamepad/keyboard adaptive)
/// @param {real} radius - Distance from object to show prompt
/// @param {real} offset_x - X offset from object position
/// @param {real} offset_y - Y offset from object position (usually negative)
/// @param {Enum.INPUT_VERB} verb - Input verb to display icon for
/// @param {string} action - Action text to display (e.g., "Open", "Talk")
function show_interaction_prompt_verb(_radius, _offset_x, _offset_y, _verb, _action) {
    // Check if player exists and is in range
    if (!instance_exists(obj_player)) {
        // No player, destroy prompt if it exists
        if (instance_exists(interaction_prompt)) {
            instance_destroy(interaction_prompt);
            interaction_prompt = noone;
        }
        return;
    }

    var _dist = point_distance(x, y, obj_player.x, obj_player.y);
    var _in_range = (_dist <= _radius);

    // Create or update prompt if in range
    if (_in_range) {
        if (!instance_exists(interaction_prompt)) {
            // Create new prompt
            interaction_prompt = instance_create_layer(x + _offset_x, y + _offset_y, "Instances", obj_interaction_prompt);
            interaction_prompt.parent_instance = id;
            interaction_prompt.offset_y = _offset_y;
            interaction_prompt.depth = -9999;

            // Set verb mode instead of text mode
            interaction_prompt.use_verb = true;
            interaction_prompt.verb = _verb;
            interaction_prompt.action_text = _action;
        } else {
            // Update existing prompt (in case verb or action changed)
            interaction_prompt.use_verb = true;
            interaction_prompt.verb = _verb;
            interaction_prompt.action_text = _action;
        }
    }
    // Hide prompt if out of range
    else if (instance_exists(interaction_prompt)) {
        instance_destroy(interaction_prompt);
        interaction_prompt = noone;
    }
}

/// @function get_verb_icon_width(verb)
/// @description Get approximate width of a verb icon for layout purposes
/// @param {Enum.INPUT_VERB} verb - Input verb to check
/// @return {real} Width in pixels (16 for sprites, estimated for text)
function get_verb_icon_width(_verb) {
    var _icon = InputIconGet(_verb);

    if (is_struct(_icon) && sprite_exists(_icon.sprite)) {
        return sprite_get_width(_icon.sprite);
    } else if (is_string(_icon)) {
        // Estimate text width (rough approximation)
        return string_width(_icon);
    }

    return 16; // Default fallback
}


// Helper function to create sprite-based icon data
// Makes it easier to define icons that use sprites instead of strings
//
// @param {Asset.GMSprite} sprite - The sprite asset to use
// @param {Real} frame - The frame index of the sprite
// @return {Struct} Icon data struct with sprite and frame

function input_icon_sprite(_sprite, _frame) {
    return {
        sprite: _sprite,
        frame: _frame
    };
}
