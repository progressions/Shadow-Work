// ============================================
// LIGHTING SYSTEM - Torch and light source functions
// ============================================

function player_play_torch_sfx(_asset_name) {
    var _sound = asset_get_index(_asset_name);
    if (_sound != -1) {
        play_sfx(_sound, 1, false);
    }
}

function player_start_torch_loop() {
    if (!audio_emitter_exists(torch_sound_emitter)) {
        torch_sound_emitter = audio_emitter_create();
    }

    if (torch_looping) return;

    var _loop_sound = asset_get_index("snd_torch_burning_loop");
    if (_loop_sound != -1) {
        audio_emitter_position(torch_sound_emitter, x, y, 0);
        torch_sound_loop_instance = audio_play_sound_on(torch_sound_emitter, _loop_sound, 0, true);
        torch_looping = true;
    }
}

function player_stop_torch_loop() {
    if (torch_sound_loop_instance != -1) {
        audio_stop_sound(torch_sound_loop_instance);
        torch_sound_loop_instance = -1;
    }
    torch_looping = false;
}

function player_supply_companion_torch() {
    return inventory_consume_item_id("torch", 1);
}

function player_has_torch_in_inventory() {
    return inventory_has_item_id("torch");
}

function player_has_equipped_torch() {
    if (equipped.left_hand != undefined && equipped.left_hand.definition != undefined) {
        return (equipped.left_hand.definition.item_id == "torch");
    }
    return false;
}

function player_get_torch_light_radius() {
    var _radius = 100;

    if (equipped.left_hand != undefined) {
        var _def = equipped.left_hand.definition;
        if (_def != undefined) {
            var _stats = _def.stats;
            if (_stats != undefined && variable_struct_exists(_stats, "light_radius")) {
                _radius = _stats[$ "light_radius"];
            }
        }
    }

    if (_radius <= 0) {
        var _torch_stats = global.item_database.torch.stats;
        if (_torch_stats != undefined && variable_struct_exists(_torch_stats, "light_radius")) {
            _radius = _torch_stats[$ "light_radius"];
        }
    }

    return max(0, _radius);
}

function player_remove_torch_from_loadouts() {
    if (equipped.left_hand != undefined && equipped.left_hand.definition != undefined && equipped.left_hand.definition.item_id == "torch") {
        equipped.left_hand = undefined;
    }

    if (is_struct(loadouts)) {
        var _loadout_keys = variable_struct_get_names(loadouts);
        for (var _li = 0; _li < array_length(_loadout_keys); _li++) {
            var _key = _loadout_keys[_li];
            if (_key == "active") continue;

            var _loadout_struct = loadouts[$ _key];
            if (!is_struct(_loadout_struct)) continue;
            if (!variable_struct_exists(_loadout_struct, "left_hand")) continue;

            var _left_entry = _loadout_struct.left_hand;
            if (_left_entry != undefined && _left_entry.definition != undefined && _left_entry.definition.item_id == "torch") {
                _loadout_struct.left_hand = undefined;
            }
        }
    }
}

function player_can_receive_torch() {
    if (equipped.left_hand != undefined) return false;

    if (equipped.right_hand != undefined) {
        var _right_def = equipped.right_hand.definition;
        if (_right_def != undefined && _right_def.handedness == WeaponHandedness.two_handed) {
            return false;
        }
    }

    return true;
}

function player_receive_torch_from_companion(_time_remaining, _light_radius) {
    if (!player_can_receive_torch()) return false;

    player_stop_torch_loop();

    var _torch_def = global.item_database.torch;
    if (_torch_def == undefined) return false;

    var _entry = {
        definition: _torch_def,
        count: 1,
        durability: 100
    };

    equipped.left_hand = _entry;

    var _active_key = loadouts_get_active_key();
    if (_active_key != undefined) {
        var _struct = loadouts_get_struct(_active_key);
        if (_struct != undefined) {
            _struct.left_hand = _entry;
        }
    }

    torch_active = true;
    torch_time_remaining = clamp(_time_remaining, 1, torch_duration);

    player_play_torch_sfx("snd_torch_equip");
    player_start_torch_loop();
    set_torch_carrier("player");

    return true;
}

function player_handle_torch_burnout() {
    player_play_torch_sfx("snd_torch_burnout");
    player_stop_torch_loop();
    player_remove_torch_from_loadouts();

    torch_active = false;
    torch_time_remaining = 0;
    set_torch_carrier("none");

    var _inventory_index = inventory_find_item_id("torch");
    if (_inventory_index != -1) {
        if (equip_item(_inventory_index, "left_hand")) {
            torch_active = true;
            torch_time_remaining = torch_duration;
            player_play_torch_sfx("snd_torch_equip");
            player_start_torch_loop();
            set_torch_carrier("player");
        }
    }
}

function player_update_torch_state() {
    var _torch_equipped = false;
    if (equipped.left_hand != undefined) {
        var _def = equipped.left_hand.definition;
        if (_def != undefined && _def.item_id == "torch") {
            _torch_equipped = true;
        }
    }

    if (_torch_equipped) {
        if (!torch_active) {
            torch_active = true;
            if (torch_time_remaining <= 0) {
                torch_time_remaining = torch_duration;
            }
            player_play_torch_sfx("snd_torch_equip");
            set_torch_carrier("player");
        }

        player_start_torch_loop();

        if (audio_emitter_exists(torch_sound_emitter)) {
            audio_emitter_position(torch_sound_emitter, x, y, 0);
        }

        torch_time_remaining = max(0, torch_time_remaining - 1);

        if (torch_time_remaining <= 0) {
            player_handle_torch_burnout();
        }
    } else if (torch_active) {
        torch_active = false;
        torch_time_remaining = 0;
        player_stop_torch_loop();
        set_torch_carrier("none");
    }
}
