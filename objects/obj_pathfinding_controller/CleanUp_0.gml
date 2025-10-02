// Pathfinding Controller - Clean Up Event
// Destroy the pathfinding grid to prevent memory leaks

if (variable_instance_exists(id, "grid") && grid != -1) {
    mp_grid_destroy(grid);
    grid = -1;
    show_debug_message("Pathfinding grid destroyed");
}
