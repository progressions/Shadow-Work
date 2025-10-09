// Initialize breakable base state
event_inherited();

hp_total = 1;
hp = hp_total;

state = BreakableState.idle;

idle_anim_speed = 0.15;
break_anim_speed = 0.35;

idle_frame_range = { start_index: 0, end_index: 3 };
break_frame_range = { start_index: 4, end_index: 7 };

idle_anim_timer = 0;
break_anim_timer = 0;

image_speed = 0;

break_sfx = undefined;
break_sfx_volume = 1;

break_particle_sprite = undefined;
break_particle_count = 0;

record_persistence = true;
is_destroyed = false;

/// @desc Transition into the breaking state
begin_break = function(_attack_instance) {
	if (state != BreakableState.idle) return;

	state = BreakableState.breaking;
	break_anim_timer = 0;
	hp = 0;

	image_index = break_frame_range.start_index;

	if (!is_undefined(break_sfx)) {
		play_sfx(break_sfx, break_sfx_volume);
	}

	if (variable_global_exists("debris_system") && break_particle_count > 0 && !is_undefined(break_particle_sprite)) {
		// Create a temporary particle type from the sprite
		var _particle_type = part_type_create();
		part_type_sprite(_particle_type, break_particle_sprite, false, false, true);
		part_type_speed(_particle_type, 1, 3, -0.1, 0);
		part_type_direction(_particle_type, 0, 360, 0, 0);
		part_type_gravity(_particle_type, 0.2, 270);
		part_type_life(_particle_type, 30, 60);
		part_type_alpha2(_particle_type, 1, 0);

		part_particles_create(global.debris_system, x, y, _particle_type, break_particle_count);

		// Clean up temporary particle type
		part_type_destroy(_particle_type);
	}
};

/// @desc Finalize breaking and remove the instance
finish_break = function() {
	if (state != BreakableState.breaking) return;

	state = BreakableState.broken;
	is_destroyed = true;
	instance_destroy();
};
