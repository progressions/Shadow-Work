// Configure burglar spawner for continuous combat testing
exit;
spawn_mode = SpawnerMode.continuous;
spawn_period = 150; // roughly 1.25 seconds between spawns
max_total_spawns = -1;
max_concurrent_enemies = 6;
proximity_enabled = false;
spawn_table = [
    { enemy_object: obj_fire_imp, weight: 1 }
];
