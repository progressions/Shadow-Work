player_stop_torch_loop();

if (variable_instance_exists(self, "dash_hit_enemies") && ds_exists(dash_hit_enemies, ds_type_list)) {
    ds_list_destroy(dash_hit_enemies);
}
dash_hit_enemies = -1;
