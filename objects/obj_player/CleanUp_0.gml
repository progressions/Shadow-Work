player_stop_torch_loop();

if (audio_emitter_exists(torch_sound_emitter)) {
    audio_emitter_free(torch_sound_emitter);
}

torch_sound_emitter = -1;
