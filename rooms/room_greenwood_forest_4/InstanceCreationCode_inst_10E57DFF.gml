
spawn_mode = SpawnerMode.continuous;
spawn_period = 60;
max_total_spawns = -1;
max_concurrent_enemies = 4;
proximity_enabled = false;
spawn_table = [
    { enemy_object: obj_fire_spitter, weight: 1 },
	{ enemy_object: obj_fire_imp, weight: 10 },
];
