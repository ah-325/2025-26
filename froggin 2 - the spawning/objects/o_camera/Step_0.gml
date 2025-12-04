//fullsreen toggle
if keyboard_check_pressed(vk_f11) 
{
	if window_get_fullscreen()
    {
        window_set_fullscreen(false);
    }
	else
    {
        window_set_fullscreen(true);
    }
}

//exit if theres no player
if !instance_exists(o_player) exit;

//get camera size
var _camWidth = camera_get_view_width(view_camera[0]);
var _camHeight = camera_get_view_height(view_camera[0]);

//get camera target coords
var _camX = o_player.x - _camWidth/2;
var _camY = o_player.y - _camHeight/2;

//constrain to room borders
_camX = clamp(_camX, 0, room_width - _camWidth);
_camY = clamp(_camY, 0, room_height - _camHeight);

//set cam coord variables
finalCamX += (_camX - finalCamX) * camTrailSpd;
finalCamX += (_camY - finalCamY) * camTrailSpd;

//set camera coords
camera_set_view_pos(view_camera[0], _camX, _camY);
