companion_stop_torch_loop();

// Clean up pathfinding path
if (path_exists(companion_path)) {
    path_delete(companion_path);
}
