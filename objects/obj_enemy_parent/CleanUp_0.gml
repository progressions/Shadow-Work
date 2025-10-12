// Enemy Parent - Clean Up Event
// Destroy the pathfinding path to prevent memory leaks

if (path_exists(path)) {
    path_delete(path);
}
