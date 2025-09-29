global.game_paused = true;
var _video_data = video_draw();
var _video_status = _video_data[0];
if (_video_status == 0) {
	draw_surface(_video_data[1], 50, 50);
}