// Clean up ds_list to prevent memory leak
if (ds_exists(hit_enemies, ds_type_list)) {
    ds_list_destroy(hit_enemies);
}
