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

break_particle_leaf_count = 0;
break_particle_leaf_type = undefined;
break_particle_wood_count = 0;
break_particle_wood_type = undefined;

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

	if (variable_global_exists("debris_system")) {
		if (break_particle_leaf_count > 0) {
			var _leaf_type = break_particle_leaf_type;
			if (is_undefined(_leaf_type) && variable_global_exists("part_leaf")) {
				_leaf_type = global.part_leaf;
			}
			if (!is_undefined(_leaf_type)) {
				part_particles_create(global.debris_system, x, y, _leaf_type, break_particle_leaf_count);
			}
		}

		if (break_particle_wood_count > 0) {
			var _wood_type = break_particle_wood_type;
			if (is_undefined(_wood_type) && variable_global_exists("part_wood")) {
				_wood_type = global.part_wood;
			}
			if (!is_undefined(_wood_type)) {
				part_particles_create(global.debris_system, x, y, _wood_type, break_particle_wood_count);
			}
		}
	}
};

/// @desc Finalize breaking and remove the instance
finish_break = function() {
	if (state != BreakableState.breaking) return;

	state = BreakableState.broken;
	is_destroyed = true;
	instance_destroy();
};
