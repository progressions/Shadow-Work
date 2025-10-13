player_stop_torch_loop();

if (audio_emitter_exists(torch_sound_emitter)) {
    audio_emitter_free(torch_sound_emitter);
}

torch_sound_emitter = -1;

if (variable_instance_exists(self, "dash_hit_enemies") && ds_exists(dash_hit_enemies, ds_type_list)) {
    ds_list_destroy(dash_hit_enemies);
}
dash_hit_enemies = -1;
