// Configure burglar spawner for continuous combat testing
spawn_mode = SpawnerMode.continuous;
spawn_period = 75; // roughly 1.25 seconds between spawns
max_total_spawns = -1;
max_concurrent_enemies = 4;
proximity_enabled = false;
spawn_table = [
    { enemy_object: obj_burglar, weight: 1 }
];
