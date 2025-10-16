/// @function chain_boss_respawn_auxiliaries
/// @description Respawn all auxiliaries in circular formation around boss
/// @self {obj_chain_boss_parent}

function chain_boss_respawn_auxiliaries() {
    auxiliaries = [];
    chain_data = [];
    var _angle_step = 360 / auxiliary_count;
    var _spawn_radius = chain_max_length * 0.5;

    for (var _i = 0; _i < auxiliary_count; _i++) {
        var _angle = _i * _angle_step;
        var _spawn_x = x + lengthdir_x(_spawn_radius, _angle);
        var _spawn_y = y + lengthdir_y(_spawn_radius, _angle);

        var _aux = instance_create_depth(_spawn_x, _spawn_y, depth, auxiliary_object);
        _aux.chain_boss = self;
        _aux.throw_state = "idle";
        _aux.throw_velocity_x = 0;
        _aux.throw_velocity_y = 0;
        _aux.spin_state = "idle";
        _aux.spin_orbit_angle = _angle;

        array_push(auxiliaries, _aux);
        array_push(chain_data, {
            auxiliary: _aux,
            tension: 0.5,
            angle: _angle,
            distance: _spawn_radius
        });
    }

    auxiliaries_alive = auxiliary_count;
    show_debug_message("Chain Boss respawned " + string(auxiliary_count) + " auxiliaries!");
}
