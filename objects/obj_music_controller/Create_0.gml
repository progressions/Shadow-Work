
global.master_volume = 1;
global.music_volume = 1;

song_instance = noone;
song_asset = noone;
target_song_asset = noone;
end_fade_out_time = 0;
start_fade_in_time = 0;
fade_in_instance_volume = 1;

fade_out_instances = array_create(0);
fade_out_instance_volume = array_create(0);
fade_out_instance_time = array_create(0);
